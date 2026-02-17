#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
CONF_FILE="$SCRIPT_DIR/schedule.conf"

log() { echo "[$(date '+%F %T')] $*"; }

check_files() {
  [[ ! -f "$ENV_FILE" ]] && log "Missing $ENV_FILE" && exit 1
  [[ ! -f "$CONF_FILE" ]] && log "Missing $CONF_FILE" && exit 1
}

load_env() {
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  [[ -z "${SLACK_TOKEN:-}" ]] && log "Missing SLACK_TOKEN in $ENV_FILE" && exit 1
}

load_conf() {
  WORK_TEXT="Working"
  WORK_EMOJI=":computer:"
  OFF_TEXT="Not working"
  OFF_EMOJI=":crescent_moon:"
  TIMEZONE="Europe/Amsterdam"

  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    key="${line%%=*}"
    val="${line#*=}"
    case "$key" in
      WORK_TEXT) WORK_TEXT="$val" ;;
      WORK_EMOJI) WORK_EMOJI="$val" ;;
      OFF_TEXT) OFF_TEXT="$val" ;;
      OFF_EMOJI) OFF_EMOJI="$val" ;;
      TIMEZONE) TIMEZONE="$val" ;;
    esac
  done < "$CONF_FILE"
}

is_work_time() {
  local day time schedule
  day="$(TZ="$TIMEZONE" date +%a)"
  time="$(TZ="$TIMEZONE" date +%H:%M)"

  schedule="$(grep "^${day}=" "$CONF_FILE" 2>/dev/null | cut -d= -f2)"
  [[ -z "$schedule" ]] && return 1

  IFS=',' read -ra intervals <<< "$schedule"
  for interval in "${intervals[@]}"; do
    start="${interval%-*}"
    end="${interval#*-}"
    [[ "$end" == "24:00" ]] && end="23:59"
    [[ ! "$time" < "$start" && ! "$time" > "$end" ]] && return 0
  done
  return 1
}

set_status() {
  local text="$1" emoji="$2"
  local resp ok

  resp="$(curl -sS https://slack.com/api/users.profile.set \
    -H "Authorization: Bearer $SLACK_TOKEN" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d "{\"profile\":{\"status_text\":\"$text\",\"status_emoji\":\"$emoji\",\"status_expiration\":0}}")"

  ok="$(echo "$resp" | jq -r '.ok' 2>/dev/null)"
  [[ "$ok" != "true" ]] && log "API error: $resp" && return 1
  return 0
}

get_current_status() {
  local resp
  resp="$(curl -sS https://slack.com/api/users.profile.get \
    -H "Authorization: Bearer $SLACK_TOKEN")"

  local current_text current_emoji
  current_text="$(echo "$resp" | jq -r '.profile.status_text' 2>/dev/null)"
  current_emoji="$(echo "$resp" | jq -r '.profile.status_emoji' 2>/dev/null)"

  if [[ "$current_text" == "$WORK_TEXT" && "$current_emoji" == "$WORK_EMOJI" ]]; then
    echo "work"
  elif [[ "$current_text" == "$OFF_TEXT" && "$current_emoji" == "$OFF_EMOJI" ]]; then
    echo "off"
  else
    echo "mismatch"
  fi
}

main() {
  check_files
  load_env
  log "started"

  while true; do
    load_conf
    export TZ="$TIMEZONE"

    if is_work_time; then
      target="work"
    else
      target="off"
    fi

    current="$(get_current_status)"

    if [[ "$current" != "$target" ]]; then
      if [[ "$target" == "work" ]]; then
        set_status "$WORK_TEXT" "$WORK_EMOJI" && log "-> WORK"
      else
        set_status "$OFF_TEXT" "$OFF_EMOJI" && log "-> OFF"
      fi
    fi

    sleep 60
  done
}

main
