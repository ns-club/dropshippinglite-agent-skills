#!/bin/sh
set -eu

REPO_OWNER="${DROPSHIPPINGLITE_AGENT_SKILLS_OWNER:-ns-club}"
REPO_NAME="${DROPSHIPPINGLITE_AGENT_SKILLS_REPO:-dropshippinglite-agent-skills}"
REPO_REF="main"
DRY_RUN=0
LOCAL_SOURCE_DIR=""
SELECTED_TOOLS=""

TOOLS=$(cat <<EOF
claude_code|Claude Code|$HOME/.claude|$HOME/.claude/skills|verified
codex|Codex|$HOME/.codex|$HOME/.codex/skills|verified
openclaw|OpenClaw|$HOME/.openclaw|$HOME/.openclaw/skills|verified
cursor|Cursor|$HOME/.cursor|$HOME/.cursor/skills|best-effort
antigravity|Antigravity|$HOME/.gemini/antigravity|$HOME/.gemini/antigravity/skills|best-effort
openclaude|OpenClaude|$HOME/.openclaude|$HOME/.openclaude/skills|best-effort
opencode|OpenCode|$HOME/.config/opencode|$HOME/.config/opencode/skills|best-effort
continue|Continue|$HOME/.continue|$HOME/.continue/skills|best-effort
gemini_cli|Gemini CLI|$HOME/.gemini|$HOME/.gemini/skills|best-effort
github_copilot|GitHub Copilot|$HOME/.copilot|$HOME/.copilot/skills|best-effort
qwen_code|Qwen Code|$HOME/.qwen|$HOME/.qwen/skills|best-effort
windsurf|Windsurf|$HOME/.codeium/windsurf|$HOME/.codeium/windsurf/skills|best-effort
EOF
)

detect_platform() {
  kernel="$(uname -s 2>/dev/null || printf 'unknown')"
  case "$kernel" in
    Darwin) printf 'macos\n' ;;
    Linux) printf 'linux\n' ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT) printf 'windows\n' ;;
    *)
      case "${OSTYPE:-}" in
        msys*|cygwin*|win32*) printf 'windows\n' ;;
        darwin*) printf 'macos\n' ;;
        linux*) printf 'linux\n' ;;
        *) printf 'unknown\n' ;;
      esac
      ;;
  esac
}

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'WARNING: %s\n' "$*" >&2
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

yaml_name() {
  skill_md="$1"
  sed -n 's/^name:[[:space:]]*\(.*\)$/\1/p' "$skill_md" | head -n 1 | sed 's/^"//; s/"$//'
}

discover_skills() {
  source_root="$1"
  found=''

  for path in "$source_root"/*; do
    [ -d "$path" ] || continue

    skill_name="$(basename "$path")"
    skill_md="$path/SKILL.md"
    [ -f "$skill_md" ] || continue

    declared_name="$(yaml_name "$skill_md")"
    [ -n "$declared_name" ] || die "skill missing name in frontmatter: $skill_md"
    [ "$declared_name" = "$skill_name" ] || die "skill name mismatch for $skill_name: frontmatter name is $declared_name"

    if [ -z "$found" ]; then
      found="$skill_name"
    else
      found="$found $skill_name"
    fi
  done

  [ -n "$found" ] || die "no installable skills were discovered in: $source_root"
  printf '%s\n' "$found"
}

usage() {
  cat <<'EOF'
Usage:
  sh install.sh
  sh install.sh --dry-run
  sh install.sh --ref main
  sh install.sh --tool claude_code --tool codex
  sh install.sh --source-dir /path/to/local/repo

Options:
  --dry-run            Show detected tools and planned actions without changing files
  --ref REF            Install from the specified GitHub branch or tag (default: main)
  --tool KEY           Limit installation to selected tool key(s); may be repeated
  --source-dir PATH    Use a local unpacked repository instead of downloading from GitHub
  -h, --help           Show this help
EOF
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

need_cmd() {
  has_cmd "$1" || die "missing required command: $1"
}

append_selected_tool() {
  tool="$1"
  if [ -z "$SELECTED_TOOLS" ]; then
    SELECTED_TOOLS="$tool"
  else
    SELECTED_TOOLS="$SELECTED_TOOLS $tool"
  fi
}

tool_is_selected() {
  tool="$1"
  [ -z "$SELECTED_TOOLS" ] && return 0
  for selected in $SELECTED_TOOLS; do
    [ "$selected" = "$tool" ] && return 0
  done
  return 1
}

download_file() {
  url="$1"
  target="$2"
  if has_cmd curl; then
    curl -fsSL "$url" -o "$target"
    return
  fi
  if has_cmd wget; then
    wget -qO "$target" "$url"
    return
  fi
  die "neither curl nor wget is available"
}

detect_local_source_root() {
  if [ -n "$LOCAL_SOURCE_DIR" ]; then
    [ -d "$LOCAL_SOURCE_DIR" ] || die "local source directory not found: $LOCAL_SOURCE_DIR"
    printf '%s\n' "$LOCAL_SOURCE_DIR"
    return
  fi

  if [ -f "$0" ]; then
    script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
    if [ -d "$script_dir/ns-client-ai-shared" ]; then
      printf '%s\n' "$script_dir"
      return
    fi
  fi

  printf '\n'
}

download_source_root() {
  need_cmd unzip

  temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dropshippinglite-agent-skills.XXXXXX")
  archive_path="$temp_dir/source.zip"

  branch_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${REPO_REF}.zip"
  tag_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/tags/${REPO_REF}.zip"

  if ! download_file "$branch_url" "$archive_path"; then
    download_file "$tag_url" "$archive_path" || die "failed to download repository archive for ref: $REPO_REF"
  fi

  unzip -q "$archive_path" -d "$temp_dir"

  skill_dir=$(find "$temp_dir" -maxdepth 3 -type d -name 'ns-client-ai-shared' | head -n 1)
  [ -n "$skill_dir" ] || die "downloaded archive does not contain ns-client-ai-shared"
  printf '%s\n' "$(dirname "$skill_dir")"
}

ensure_skill_source_root() {
  source_root=$(detect_local_source_root)
  if [ -n "$source_root" ]; then
    printf '%s\n' "$source_root"
    return
  fi
  download_source_root
}

validate_source_root() {
  source_root="$1"
  discover_skills "$source_root" >/dev/null
}

detect_targets() {
  detected_any=0
  printf '%s\n' "$TOOLS" | while IFS='|' read -r key display detect_dir target_dir support_level; do
    tool_is_selected "$key" || continue
    if [ -d "$detect_dir" ]; then
      printf '%s|%s|%s|%s|%s\n' "$key" "$display" "$detect_dir" "$target_dir" "$support_level"
      detected_any=1
    fi
  done
}

backup_if_exists() {
  skill_target="$1"
  tool_key="$2"
  timestamp="$3"

  if [ ! -e "$skill_target" ]; then
    return
  fi

  backup_root="$(dirname "$skill_target")/../.dropshippinglite-agent-skills-backups/$tool_key/$timestamp"
  backup_target="$backup_root/$(basename "$skill_target")"

  if [ "$DRY_RUN" -eq 1 ]; then
    log "DRY RUN: backup $(basename "$skill_target") -> $backup_target"
    return
  fi

  mkdir -p "$backup_root"
  mv "$skill_target" "$backup_target"
}

install_skill_to_target() {
  source_root="$1"
  tool_key="$2"
  tool_name="$3"
  target_dir="$4"
  support_level="$5"
  timestamp="$6"
  skills="$7"

  if [ "$DRY_RUN" -eq 1 ]; then
    log "DRY RUN: would install to $tool_name [$support_level] -> $target_dir"
  else
    mkdir -p "$target_dir"
    log "Installing to $tool_name [$support_level] -> $target_dir"
  fi

  for skill in $skills; do
    source_skill="$source_root/$skill"
    target_skill="$target_dir/$skill"
    backup_if_exists "$target_skill" "$tool_key" "$timestamp"

    if [ "$DRY_RUN" -eq 1 ]; then
      log "DRY RUN: copy $skill -> $target_dir"
      continue
    fi

    cp -R "$source_skill" "$target_dir/"
  done
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --ref)
      REPO_REF="$2"
      shift 2
      ;;
    --tool)
      append_selected_tool "$2"
      shift 2
      ;;
    --source-dir)
      LOCAL_SOURCE_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

PLATFORM="$(detect_platform)"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"

case "$PLATFORM" in
  macos|linux) ;;
  windows)
    if has_cmd powershell; then
      exec powershell -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/install.ps1" "$@"
    fi
    if has_cmd pwsh; then
      exec pwsh -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/install.ps1" "$@"
    fi
    die "Windows environment detected. Please run install.ps1 in PowerShell."
    ;;
  *)
    die "unsupported platform: $PLATFORM"
    ;;
esac

need_cmd sh
need_cmd unzip
if ! has_cmd curl && ! has_cmd wget; then
  die "curl or wget is required"
fi

SOURCE_ROOT=$(ensure_skill_source_root)
validate_source_root "$SOURCE_ROOT"
SKILL_NAMES="$(discover_skills "$SOURCE_ROOT")"

TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
DETECTED_TARGETS=$(detect_targets)

[ -n "$DETECTED_TARGETS" ] || die "no supported AI tools were detected in this account. Install a supported tool first or rerun with a different account."

log "NS Client agent skills source: $SOURCE_ROOT"
log "Repository: ${REPO_OWNER}/${REPO_NAME}"
log "Ref: $REPO_REF"
log "Discovered skills: $SKILL_NAMES"
log ""
log "Detected targets:"
printf '%s\n' "$DETECTED_TARGETS" | while IFS='|' read -r key display detect_dir target_dir support_level; do
  log "- $display [$support_level]"
  log "  detect: $detect_dir"
  log "  target: $target_dir"
done
log ""

printf '%s\n' "$DETECTED_TARGETS" | while IFS='|' read -r key display detect_dir target_dir support_level; do
  install_skill_to_target "$SOURCE_ROOT" "$key" "$display" "$target_dir" "$support_level" "$TIMESTAMP" "$SKILL_NAMES"
done

log ""
if [ "$DRY_RUN" -eq 1 ]; then
  log "Dry run complete. No files were changed."
else
  log "Installation complete."
  log "Next steps:"
  log "1. Open your preferred AI tool."
  log "2. Make a normal NS Client request in natural language."
  log "3. If local credentials are not configured yet, let the AI tool prompt you for Base URL, access_key_id, and secret."
  log "4. Approve local credential saving if you want future reuse."
fi
