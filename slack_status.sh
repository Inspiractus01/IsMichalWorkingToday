#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

[[ ! -f "$ENV_FILE" ]] && echo "Missing $ENV_FILE" && exit 1

# shellcheck disable=SC1090
source "$ENV_FILE"
[[ -z "${SLACK_TOKEN:-}" ]] && echo "SLACK_TOKEN not set" && exit 1

usage() {
  echo "Usage: $0 <working|offline|clear|set>"
  echo "  $0 working            # Set Working :computer:"
  echo "  $0 offline           # Set Offline :crescent_moon:"
  echo "  $0 clear             # Clear status"
  echo "  $0 set \"Text\" :emoji:  # Set custom status"
  exit 1
}

MODE="${1:-}"
[[ -z "$MODE" ]] && usage

case "$MODE" in
  working)
    text="Working"
    emoji=":computer:"
    ;;
  offline)
    text="Not working"
    emoji=":crescent_moon:"
    ;;
  clear)
    text=""
    emoji=""
    ;;
  set)
    text="${2:-}"
    emoji="${3:-}"
    [[ -z "$text" || -z "$emoji" ]] && usage
    ;;
  *)
    usage
    ;;
esac

resp="$(curl -sS https://slack.com/api/users.profile.set \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "{\"profile\":{\"status_text\":\"$text\",\"status_emoji\":\"$emoji\",\"status_expiration\":0}}")"

[[ "$(echo "$resp" | jq -r '.ok')" != "true" ]] && echo "Failed: $resp" && exit 1
echo "Done!"
