#!/usr/bin/env bash

# Usage:
#   source elastic-env.sh set
#   source elastic-env.sh unset
#
# NOTE: You MUST use 'source' so that exports affect your current shell:
#   source ./elastic-env.sh set

ACTION="$1"
ENV_FILE="${ENV_FILE:-.env}"

# Helper: handle return vs exit depending on whether script is sourced
_die() {
  echo "$1" >&2
  # If sourced, 'return' is valid; if executed directly, 'exit' is needed
  return 1 2>/dev/null || exit 1
}

if [[ ! -f "$ENV_FILE" ]]; then
  _die "Environment file '$ENV_FILE' not found. Create it from .env.example."
fi

case "$ACTION" in
  set)
    # Load EC_API_KEY and EC_ORG_ID from .env
    # shellcheck disable=SC1090
    source "$ENV_FILE"

    if [[ -z "$EC_API_KEY" || -z "$EC_ORG_ID" ]]; then
      _die "EC_API_KEY or EC_ORG_ID is empty. Please fill them in '$ENV_FILE'."
    fi

    # Export Terraform-compatible variables
    export TF_VAR_ec_api_key="$EC_API_KEY"
    export TF_VAR_ec_organization_id="$EC_ORG_ID"

    echo "Exported:"
    echo "  TF_VAR_ec_api_key"
    echo "  TF_VAR_ec_organization_id"
    ;;

  unset)
    unset EC_API_KEY
    unset EC_ORG_ID
    unset TF_VAR_ec_api_key
    unset TF_VAR_ec_organization_id

    echo "Unset:"
    echo "  EC_API_KEY"
    echo "  EC_ORG_ID"
    echo "  TF_VAR_ec_api_key"
    echo "  TF_VAR_ec_organization_id"
    ;;

  *)
    echo "Usage:"
    echo "  source ./elastic-env.sh set   # load secrets into env"
    echo "  source ./elastic-env.sh unset # remove secrets from env"
    _die "Invalid action '$ACTION'"
    ;;
esac
