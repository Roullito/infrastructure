#!/usr/bin/env bash
# Pre-commit hook: refuse to commit a secrets.enc.yaml which has not been encrypted with SOPS.
#
# SOPS adds a top-level `sops:` mapping to every encrypted file, holding the wrapped data key and metadata.
# We use its presence as a "proof" of encryption: `grep -q "^sops:"` matches the unindented top-level key only

set -euo pipefail

return_code=0

for file in "$@"; do
    if ! grep -q "^sops:" "$file"; then
        echo "Not SOPS-encrypted: $file" >&2

        # Best-effort: we assume regularly nested modules (<service>/terraform/secrets.enc.yaml) to suggest
        # the idiomatic make target. Fallback to the raw sops command otherwise.
        if [ "$(basename "$(dirname "$file")")" = "terraform" ]; then
            service="$(dirname "$(dirname "$file")")"
            echo "  -> Run: make sops-encrypt SERVICE=$service" >&2
        else
            echo "  -> Run: sops -e -i $file" >&2
        fi

        return_code=1
    fi
done

exit "$return_code"
