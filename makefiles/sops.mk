##@ SOPS

SOPS_FILE = $(SERVICE)/terraform/secrets.enc.yaml


.PHONY: sops-edit
sops-edit: guard-SERVICE  ## Edit encrypted secrets in $EDITOR (SERVICE=xxx)
	@printf "%b[%s] Edit %s%b\n" "$(OK_COLOR)" "$(BANNER)" "$(SOPS_FILE)" "$(NO_COLOR)"
	@sops $(SOPS_FILE)

.PHONY: sops-encrypt
sops-encrypt: guard-SERVICE  ## Encrypt secrets file in place (SERVICE=xxx)
	@printf "%b[%s] Encrypt %s%b\n" "$(OK_COLOR)" "$(BANNER)" "$(SOPS_FILE)" "$(NO_COLOR)"
	@sops -e -i $(SOPS_FILE)

.PHONY: sops-decrypt
sops-decrypt: guard-SERVICE  ## Decrypt secrets file to stdout (SERVICE=xxx)
	@sops -d $(SOPS_FILE)

.PHONY: sops-rotate-keys
sops-rotate-keys:  ## Re-wrap data key on every encrypted file (run after editing .sops.yaml)
	@printf "%b[%s] Rotate keys on all secrets.enc.yaml%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@set -e; \
	find . -type f -name "secrets.enc.yaml" -not -path "*/.terraform/*" \
		| sort -u \
		| while read f; do \
			echo "Updating keys in $$f"; \
			sops updatekeys --yes "$$f"; \
		done
