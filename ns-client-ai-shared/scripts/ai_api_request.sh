#!/bin/sh
set -eu

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

url_encode() {
  printf '%s' "$1" | sed \
    -e 's/%/%25/g' \
    -e 's/ /%20/g' \
    -e 's/+/%2B/g' \
    -e 's/&/%26/g' \
    -e 's/=/%3D/g' \
    -e 's/?/%3F/g' \
    -e 's/#/%23/g'
}

user_config_path() {
  case "${OSTYPE:-}" in
    msys*|cygwin*|win32*) printf '%s/.ns-client/ai-api.json' "$HOME" ;;
    *) printf '%s/.config/ns-client/ai-api.json' "$HOME" ;;
  esac
}

repo_config_path() {
  current="$(pwd)"
  while :; do
    if [ -f "$current/.ns-client-ai.local.json" ] || [ -d "$current/.git" ]; then
      printf '%s/.ns-client-ai.local.json' "$current"
      return
    fi
    [ "$current" = "/" ] && break
    current="$(dirname "$current")"
  done
  printf '%s/.ns-client-ai.local.json' "$(pwd)"
}

json_value() {
  file="$1"
  key="$2"
  [ -f "$file" ] || return 0
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$file" | head -n 1
}

read_config_value() {
  file="$1"
  lower_key="$2"
  upper_key="$3"
  value="$(json_value "$file" "$lower_key")"
  if [ -z "$value" ]; then
    value="$(json_value "$file" "$upper_key")"
  fi
  printf '%s' "$value"
}

try_config() {
  label="$1"
  file="$2"
  if [ -z "${BASE_URL:-}" ]; then
    value="$(read_config_value "$file" base_url NS_CLIENT_AI_BASE_URL)"
    if [ -n "$value" ]; then BASE_URL="$value"; BASE_URL_SOURCE="config:$label:$file"; fi
  fi
  if [ -z "${ACCESS_KEY_ID:-}" ]; then
    value="$(read_config_value "$file" access_key_id NS_CLIENT_AI_ACCESS_KEY_ID)"
    if [ -n "$value" ]; then ACCESS_KEY_ID="$value"; ACCESS_KEY_ID_SOURCE="config:$label:$file"; fi
  fi
  if [ -z "${SECRET:-}" ]; then
    value="$(read_config_value "$file" secret NS_CLIENT_AI_SECRET)"
    if [ -n "$value" ]; then SECRET="$value"; SECRET_SOURCE="config:$label:$file"; fi
  fi
}

resolve_credentials() {
  BASE_URL="${NS_CLIENT_AI_BASE_URL:-}"
  ACCESS_KEY_ID="${NS_CLIENT_AI_ACCESS_KEY_ID:-}"
  SECRET="${NS_CLIENT_AI_SECRET:-}"
  BASE_URL_SOURCE=""
  ACCESS_KEY_ID_SOURCE=""
  SECRET_SOURCE=""
  [ -n "$BASE_URL" ] && BASE_URL_SOURCE='env:NS_CLIENT_AI_BASE_URL'
  [ -n "$ACCESS_KEY_ID" ] && ACCESS_KEY_ID_SOURCE='env:NS_CLIENT_AI_ACCESS_KEY_ID'
  [ -n "$SECRET" ] && SECRET_SOURCE='env:NS_CLIENT_AI_SECRET'

  if [ -n "${NS_CLIENT_AI_CONFIG:-}" ]; then
    try_config 'NS_CLIENT_AI_CONFIG' "$NS_CLIENT_AI_CONFIG"
  fi
  try_config 'repo' "$(repo_config_path)"
  try_config 'user' "$(user_config_path)"
}

missing_json() {
  items=''
  if [ -z "${BASE_URL:-}" ]; then items='"base_url"'; fi
  if [ -z "${ACCESS_KEY_ID:-}" ]; then [ -n "$items" ] && items="$items,"; items="$items\"access_key_id\""; fi
  if [ -z "${SECRET:-}" ]; then [ -n "$items" ] && items="$items,"; items="$items\"secret\""; fi
  printf '[%s]' "$items"
}

sources_json() {
  items=''
  if [ -n "${BASE_URL_SOURCE:-}" ]; then items='"base_url":"'"$(json_escape "$BASE_URL_SOURCE")"'"'; fi
  if [ -n "${ACCESS_KEY_ID_SOURCE:-}" ]; then [ -n "$items" ] && items="$items,"; items="$items\"access_key_id\":\"$(json_escape "$ACCESS_KEY_ID_SOURCE")\""; fi
  if [ -n "${SECRET_SOURCE:-}" ]; then [ -n "$items" ] && items="$items,"; items="$items\"secret\":\"$(json_escape "$SECRET_SOURCE")\""; fi
  printf '{%s}' "$items"
}

path_json_item() {
  label="$1"
  file="$2"
  exists=false
  [ -f "$file" ] && exists=true
  printf '{"label":"%s","path":"%s","exists":%s}' "$(json_escape "$label")" "$(json_escape "$file")" "$exists"
}

config_paths_json() {
  items=''
  if [ -n "${NS_CLIENT_AI_CONFIG:-}" ]; then
    items="$(path_json_item 'NS_CLIENT_AI_CONFIG' "$NS_CLIENT_AI_CONFIG")"
  fi
  repo_item="$(path_json_item 'repo' "$(repo_config_path)")"
  user_item="$(path_json_item 'user' "$(user_config_path)")"
  [ -n "$items" ] && items="$items,"
  items="$items$repo_item,$user_item"
  printf '[%s]' "$items"
}

status() {
  resolve_credentials
  resolved=false
  if [ -n "${BASE_URL:-}" ] && [ -n "${ACCESS_KEY_ID:-}" ] && [ -n "${SECRET:-}" ]; then resolved=true; fi
  printf '{\n  "resolved": %s,\n  "missing": %s,\n  "sources": %s,\n  "config_paths": %s\n}\n' "$resolved" "$(missing_json)" "$(sources_json)" "$(config_paths_json)"
}

set_from_env() {
  scope=user
  config=''
  while [ $# -gt 0 ]; do
    case "$1" in
      --scope) scope="$2"; shift 2 ;;
      --config) config="$2"; shift 2 ;;
      *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
  done
  [ -n "${NS_CLIENT_AI_BASE_URL:-}" ] || { echo 'Missing environment values: base_url' >&2; exit 1; }
  [ -n "${NS_CLIENT_AI_ACCESS_KEY_ID:-}" ] || { echo 'Missing environment values: access_key_id' >&2; exit 1; }
  [ -n "${NS_CLIENT_AI_SECRET:-}" ] || { echo 'Missing environment values: secret' >&2; exit 1; }
  if [ -n "$config" ]; then path="$config"; elif [ "$scope" = "repo" ]; then path="$(repo_config_path)"; else path="$(user_config_path)"; fi
  mkdir -p "$(dirname "$path")"
  umask 077
  cat > "$path" <<EOF
{
  "base_url": "$(json_escape "$NS_CLIENT_AI_BASE_URL")",
  "access_key_id": "$(json_escape "$NS_CLIENT_AI_ACCESS_KEY_ID")",
  "secret": "$(json_escape "$NS_CLIENT_AI_SECRET")"
}
EOF
  printf '{"saved":true,"path":"%s","scope":"%s"}\n' "$(json_escape "$path")" "$(json_escape "$scope")"
}

request() {
  [ $# -ge 1 ] || { echo 'Missing endpoint' >&2; exit 1; }
  endpoint="$1"
  shift
  case "$endpoint" in /api/ai/v1/*) ;; *) echo 'Endpoint must start with /api/ai/v1/' >&2; exit 1 ;; esac
  resolve_credentials
  if [ -z "${BASE_URL:-}" ] || [ -z "${ACCESS_KEY_ID:-}" ] || [ -z "${SECRET:-}" ]; then
    printf '{"error":"missing_credentials","missing":%s}\n' "$(missing_json)" >&2
    exit 2
  fi
  url="${BASE_URL%/}$endpoint"
  query=''
  timeout=30
  while [ $# -gt 0 ]; do
    case "$1" in
      --param)
        key=${2%%=*}
        value=${2#*=}
        [ "$key" != "$2" ] || { echo "Invalid --param value, expected key=value: $2" >&2; exit 1; }
        pair="$(url_encode "$key")=$(url_encode "$value")"
        [ -n "$query" ] && query="$query&"
        query="$query$pair"
        shift 2
        ;;
      --timeout) timeout="$2"; shift 2 ;;
      *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
  done
  [ -n "$query" ] && url="$url?$query"
  curl -sS --max-time "$timeout" -H "Authorization: Bearer $ACCESS_KEY_ID.$SECRET" -H 'Accept: application/json' "$url"
}

case "${1:-help}" in
  status) shift; status "$@" ;;
  set-from-env) shift; set_from_env "$@" ;;
  request) shift; request "$@" ;;
  -h|--help|help)
    cat <<'EOF'
Usage:
  sh ai_api_request.sh status
  sh ai_api_request.sh set-from-env [--scope user|repo] [--config path]
  sh ai_api_request.sh request /api/ai/v1/orders --param page=1 --param per_page=50 [--timeout 30]
EOF
    ;;
  *) echo "Unknown command: $1" >&2; exit 1 ;;
esac