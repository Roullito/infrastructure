locals {
  strongswan_public_gateway_ip = {
    id = "fr-par-1/e54df15d-fdbf-40bb-bc04-0957a450a65b" # FIXME: This should be dynamically fetched. SW Ticket 1518441
  }
  vpn_config             = jsondecode(base64decode(data.scaleway_secret_version.cnav_vpn_config.data))
  private_network_subnet = one(data.scaleway_vpc_private_network.strongswan_private_network.ipv4_subnet).subnet

  instance_user_data = {
    manage_resolv_conf = true
    resolv_conf = {
      nameservers = [
        "1.1.1.1",         # CF DNS
        "1.0.0.1",         # CF DNS
        "169.254.169.254", # Scaleway private DNS
      ]
    }
    packages = [
      "strongswan",
      "iptables",
      "iptables-persistent"
    ]
    write_files = [
      {
        path = "/etc/ipsec.conf"
        content = base64encode(
          templatefile("${path.module}/templates/ipsec.conf.tpl", {
            public_gateway_ip = data.scaleway_vpc_public_gateway_ip.strongswan_public_gateway_ip
            vpn_config        = local.vpn_config
          })
        )
        encoding = "b64"
      },
      {
        path = "/etc/ipsec.secrets"
        content = base64encode(
          templatefile("${path.module}/templates/ipsec.secrets.tpl", {
            public_gateway_ip = data.scaleway_vpc_public_gateway_ip.strongswan_public_gateway_ip
            vpn_config        = local.vpn_config
          })
        )
        encoding = "b64"
      },
    ]
    runcmd = [
      # =============================================================================
      # Kernel: enable IP forwarding (needed for routing between pods and VPN)
      # =============================================================================
      "sysctl -w net.ipv4.ip_forward=1",
      "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf",

      # =============================================================================
      # Network: configure secondary IPs on private network interface
      # These dedicated IPs (one per environment) are the SNAT exit points for
      # K8s pods reaching CNAV. Scaleway Kapsule does not expose Cilium Egress
      # Gateway, so we use this VM as a NAT gateway.
      # Detect private network interface dynamically (interface name may vary)
      # =============================================================================
      "PN_IFACE=$(ip -4 addr show | grep -B2 '10.251' | grep -oP '^\\d+: \\K[^:]+') && ip addr add ${local.vpn_config.local_ip_integration}/32 dev $PN_IFACE && ip addr add ${local.vpn_config.local_ip_production}/32 dev $PN_IFACE",

      # =============================================================================
      # Firewall: base rules (stateful tracking + loopback)
      # =============================================================================
      "iptables -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT",
      "iptables -A INPUT  -i lo -j ACCEPT",
      "iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT",
      "iptables -A OUTPUT -o lo -j ACCEPT",

      # =============================================================================
      # Firewall: ingress (IPsec only, from CNAV peers)
      # =============================================================================
      # IPsec from CNAV peers
      "iptables -A INPUT -p udp --dport 500  -s ${local.vpn_config.remote_ip} -j ACCEPT",
      "iptables -A INPUT -p udp --dport 4500 -s ${local.vpn_config.remote_ip} -j ACCEPT",
      "iptables -A INPUT -p esp              -s ${local.vpn_config.remote_ip} -j ACCEPT",
      "iptables -A INPUT -p udp --dport 500  -s ${local.vpn_config.remote_backup_ip} -j ACCEPT",
      "iptables -A INPUT -p udp --dport 4500 -s ${local.vpn_config.remote_backup_ip} -j ACCEPT",
      "iptables -A INPUT -p esp              -s ${local.vpn_config.remote_backup_ip} -j ACCEPT",

      # Scaleway private network (between VMs / cluster nodes)
      "iptables -A INPUT -s ${local.private_network_subnet} -j ACCEPT",

      # =============================================================================
      # Firewall: egress (system updates, DNS, IPsec, CNAV)
      # =============================================================================
      # System updates, DNS and VPC traffic
      "iptables -A OUTPUT -p udp --dport 53 -d 1.1.1.1 -j ACCEPT",          # Cloudflare DNS
      "iptables -A OUTPUT -p udp --dport 53 -d 1.0.0.1 -j ACCEPT",          # Cloudflare DNS (secondary)
      "iptables -A OUTPUT -p tcp --dport 80 -d 169.254.42.42 -j ACCEPT",    # Scaleway Metadata API
      "iptables -A OUTPUT -p udp --dport 67 -d 169.254.169.254 -j ACCEPT",  # Scaleway VPC DHCP
      "iptables -A OUTPUT -p udp --dport 53 -d 169.254.169.254 -j ACCEPT",  # Scaleway VPC DNS
      "iptables -A OUTPUT -p udp --dport 123 -d 169.254.169.254 -j ACCEPT", # Scaleway VPC NTP
      "iptables -A OUTPUT -p tcp --dport 443 -d 151.101.0.0/16 -j ACCEPT",  # Fastly (Debian apt)
      "iptables -A OUTPUT -p tcp --dport 80  -d 185.125.190.80 -j ACCEPT",  # Scaleway PPA on Launchpad (preinstalled apt source)

      # IPsec to CNAV peers
      "iptables -A OUTPUT -p udp --dport 500  -d ${local.vpn_config.remote_ip} -j ACCEPT",
      "iptables -A OUTPUT -p udp --dport 4500 -d ${local.vpn_config.remote_ip} -j ACCEPT",
      "iptables -A OUTPUT -p esp              -d ${local.vpn_config.remote_ip} -j ACCEPT",
      "iptables -A OUTPUT -p udp --dport 500  -d ${local.vpn_config.remote_backup_ip} -j ACCEPT",
      "iptables -A OUTPUT -p udp --dport 4500 -d ${local.vpn_config.remote_backup_ip} -j ACCEPT",
      "iptables -A OUTPUT -p esp              -d ${local.vpn_config.remote_backup_ip} -j ACCEPT",

      # Scaleway private network (between VMs / cluster nodes)
      "iptables -A OUTPUT -d ${local.private_network_subnet} -j ACCEPT",

      # Allow HTTPS to CNAV subnet for local debugging (curl/openssl from this VM).
      # Production traffic from K8s pods uses FORWARD chain via DNAT, not OUTPUT.
      "iptables -A OUTPUT -d ${local.vpn_config.remote_subnet} -p tcp --dport 443 -j ACCEPT",

      # =============================================================================
      # Firewall: NAT rules for K8s pods → CNAV via VPN tunnel
      # Pods have IPs in Cilium CIDR. The IPsec tunnel only accepts traffic
      # from leftsubnet. We use DNAT+SNAT:
      #   1. DNAT redirects pod traffic (destined to local_ip_*) to actual CNAV IP
      #   2. SNAT changes source IP to match IPsec tunnel selector
      # Conntrack handles return traffic transparently.
      #
      # Flow: Pod -> strongswan (local_ip_*) -> DNAT -> SNAT -> tunnel -> CNAV
      # =============================================================================
      # DNAT: Redirect traffic destined to strongswan IPs to actual CNAV endpoints
      "iptables -t nat -A PREROUTING  -s 10.252.0.0/20 -d ${local.vpn_config.local_ip_integration} -j DNAT --to-destination ${local.vpn_config.remote_ip_integration}",
      "iptables -t nat -A PREROUTING  -s 10.252.0.0/20 -d ${local.vpn_config.local_ip_production}  -j DNAT --to-destination ${local.vpn_config.remote_ip_production}",

      # SNAT: Change source IP so traffic matches IPsec tunnel selectors (leftsubnet)
      # We use conntrack to remember the original destination (before DNAT) and apply the matching source IP
      # This ensures integration pods exit with integration IP, production pods with production IP
      # Conntrack also handles return traffic (CNAV responses): it remembers the original pod IP
      # and automatically reverses the NAT to route responses back to the correct pod
      "iptables -t nat -A POSTROUTING -m conntrack --ctorigdst ${local.vpn_config.local_ip_integration} -j SNAT --to-source ${local.vpn_config.local_ip_integration}",
      "iptables -t nat -A POSTROUTING -m conntrack --ctorigdst ${local.vpn_config.local_ip_production}  -j SNAT --to-source ${local.vpn_config.local_ip_production}",

      # =============================================================================
      # Firewall: log and drop
      # Rate-limited LOG before DROP for observability without flooding journals
      # =============================================================================
      "iptables -A INPUT  -m limit --limit 10/min -j LOG --log-prefix 'DROP-IN: '  --log-level 4",
      "iptables -A OUTPUT -m limit --limit 10/min -j LOG --log-prefix 'DROP-OUT: ' --log-level 4",
      "iptables -A INPUT  -j DROP",
      "iptables -A OUTPUT -j DROP",

      # =============================================================================
      # Persist iptables rules
      # =============================================================================
      "netfilter-persistent save",

      # =============================================================================
      # Start strongswan
      # =============================================================================
      "systemctl enable strongswan-starter",
      "systemctl restart strongswan-starter",
    ]
  }
}
