# Refer to the CNAV network convention (Excel file), and documentation:
# https://wiki.strongswan.org/projects/strongswan/wiki/ConfigSetupSection
# https://wiki.strongswan.org/projects/strongswan/wiki/connsection

config setup
  # Per-subsystem debug verbosity (ike, knl=kernel, cfg=config); keep level 1
  # by default (the commented line below bumps to peak for ad-hoc deep dives)
  # charondebug="ike 2, knl 2, cfg 2, net 2"
  charondebug="ike 1, knl 1, cfg 1"
  # Allow multiple IKE_SAs sharing the same peer ID to coexist (prevents races
  # during rekey where the new SA would prematurely kill the live one)
  uniqueids=no

conn vpn-bcrs
  # Bring the tunnel up at boot without waiting for traffic to trigger it
  auto=start
  # Site-to-site tunnel mode (encapsulate full IP packets)
  type=tunnel

  # Use IKEv2 (as required by CNAV peers)
  keyexchange=ikev2

  # IKE (phase 1) suite required by CNAV: AES-256-CBC / SHA-256 / DH group 14.
  # Trailing '!' = strict, no fallback proposal accepted
  ike=aes256-sha256-modp2048!
  # ESP (phase 2) suite required by CNAV: AES-256-GCM (AEAD) + DH group 14 for PFS
  esp=aes256gcm16-modp2048!

  # IKE_SA lifetime (12h) — a rekey (not a reauth, see below) happens at this point
  ikelifetime=43200s
  # Child_SA (ESP) lifetime (1h) — ESP keys rotate hourly for forward secrecy
  keylife=3600s
  # Use IKEv2 rekey instead of full reauth: avoids "no CHILD_SA to recreate" failure
  # that left the tunnel down with no retry every ~12h
  reauth=no
  # Re-establish the tunnel if the peer sends a DELETE (ex: CNAV-side reset)
  closeaction=restart
  # Never give up retrying a failed negotiation
  keyingtries=%forever

  # PDI side. Use %any rather than a hardcoded IP, so we let charon pick the correct
  # source during negociation
  left=%any
  # PDI authentication method
  leftauth=psk
  # PDI identity sent to CNAV (their firewall whitelists this exact IP)
  leftid=${public_gateway_ip.address}
  # PDI subnet announced into the tunnel (traffic selector)
  leftsubnet=${vpn_config.local_subnet}

  # CNAV public endpoint on which we initiate the tunnel
  right=${vpn_config.remote_ip}
  # CNAV authentication method
  rightauth=psk
  # Expected CNAV identity (according to the network convention, must match exactly)
  rightid=${vpn_config.remote_id}
  # CNAV subnet reachable through the tunnel (traffic selector)
  rightsubnet=${vpn_config.remote_subnet}

  # On Dead Peer Detection failure, tear down and restart the connection
  dpdaction=restart
  # Short interval to keep the tunnel established: warms the NAT-T binding and
  # catches a silently-dead peer fast (paired with dpdaction=restart above)
  dpddelay=30s
  # Declare the peer dead if no DPD response within 120s
  dpdtimeout=120s
