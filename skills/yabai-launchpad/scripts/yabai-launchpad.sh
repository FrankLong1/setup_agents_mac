#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
YABAI_BIN="${YABAI_BIN:-$(command -v yabai 2>/dev/null || true)}"
JQ_BIN="${JQ_BIN:-$(command -v jq 2>/dev/null || true)}"
CONFIG_ROOT="${YABAI_LAUNCHPAD_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/yabai-launchpad}"
LAYOUT_ROOT="$CONFIG_ROOT/layouts"
WAIT_SECONDS="${YABAI_LAUNCHPAD_WAIT_SECONDS:-20}"

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
warn() { printf 'warning: %s\n' "$*" >&2; }
info() { printf '%s\n' "$*"; }

usage() {
    cat <<EOF
Usage:
  $SCRIPT_NAME snapshot NAME
  $SCRIPT_NAME restore NAME [--dry-run] [--allow-display-mismatch]
  $SCRIPT_NAME list
  $SCRIPT_NAME path NAME

Environment:
  YABAI_LAUNCHPAD_HOME       Root directory for saved layouts.
  YABAI_LAUNCHPAD_WAIT_SECONDS  Seconds to wait for launched windows (default: 20).
EOF
}

require_tools() {
    [ -n "$YABAI_BIN" ] || die "yabai is not on PATH"
    [ -n "$JQ_BIN" ] || die "jq is not on PATH"
    [ -x "$YABAI_BIN" ] || die "yabai is not executable: $YABAI_BIN"
    "$YABAI_BIN" -m query --displays >/dev/null 2>&1 || \
        die "yabai is not reachable; start it with the passive ~/.yabairc first"
}

layout_file() {
    case "$1" in
        ''|*[!A-Za-z0-9._-]*) die "invalid layout name '$1' (use letters, digits, dot, underscore, or dash)" ;;
    esac
    printf '%s/%s.json\n' "$LAYOUT_ROOT" "$1"
}

query_state() {
    DISPLAYS_JSON=$("$YABAI_BIN" -m query --displays) || die "could not query displays"
    SPACES_JSON=$("$YABAI_BIN" -m query --spaces) || die "could not query Spaces"
    WINDOWS_JSON=$("$YABAI_BIN" -m query --windows) || die "could not query windows"
    "$JQ_BIN" -e 'type == "array"' >/dev/null <<<"$DISPLAYS_JSON" || die "invalid display JSON"
    "$JQ_BIN" -e 'type == "array"' >/dev/null <<<"$SPACES_JSON" || die "invalid Space JSON"
    "$JQ_BIN" -e 'type == "array"' >/dev/null <<<"$WINDOWS_JSON" || die "invalid window JSON"
}

snapshot() {
    local name="$1" file tmp captured
    file=$(layout_file "$name")
    mkdir -p "$LAYOUT_ROOT"
    query_state
    captured=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    tmp=$(mktemp "$LAYOUT_ROOT/.${name}.XXXXXX")
    "$JQ_BIN" -n \
        --arg schema "yabai-launchpad/v1" \
        --arg name "$name" \
        --arg captured_at "$captured" \
        --argjson displays "$DISPLAYS_JSON" \
        --argjson spaces "$SPACES_JSON" \
        --argjson windows "$WINDOWS_JSON" \
        '{schema:$schema,name:$name,captured_at:$captured_at,displays:$displays,spaces:$spaces,windows:$windows}' \
        >"$tmp"
    chmod 600 "$tmp"
    mv -f "$tmp" "$file"
    info "saved $file"
    info "captured $("$JQ_BIN" 'length' <<<"$WINDOWS_JSON") windows across $("$JQ_BIN" 'length' <<<"$SPACES_JSON") Spaces"
}

list_layouts() {
    mkdir -p "$LAYOUT_ROOT"
    found=0
    for file in "$LAYOUT_ROOT"/*.json; do
        [ -e "$file" ] || continue
        found=1
        "$JQ_BIN" -r '[.name, .captured_at, ((.windows // []) | length | tostring) + " windows"] | @tsv' "$file"
    done
    [ "$found" -eq 1 ] || info "no saved layouts in $LAYOUT_ROOT"
}

json_field() {
    local expression="$1" json="$2"
    "$JQ_BIN" -r "$expression" <<<"$json"
}

launch_saved_apps() {
    local snapshot_json="$1" app
    while IFS= read -r app; do
        [ -n "$app" ] || continue
        info "launching $app"
        open -a "$app" >/dev/null 2>&1 || warn "could not launch '$app'"
    done < <("$JQ_BIN" -r '[.windows[] | select(.app != null and .app != "")] | map(.app) | unique[]' <<<"$snapshot_json")
}

current_window_id() {
    local app="$1" title="$2" used_json="$3" current="$4"
    "$JQ_BIN" -r \
        --arg app "$app" \
        --arg title "$title" \
        --argjson used "$used_json" \
        '[.[] | select(.app == $app) | select((.id as $id | ($used | index($id)) == null)) | select(($title == "") or (.title == $title))] | .[0].id // empty' \
        <<<"$current"
}

space_index_for_window() {
    local snapshot_json="$1" saved_space="$2"
    "$JQ_BIN" -r --argjson saved_space "$saved_space" \
        '[.spaces[] | select((.id? == $saved_space) or (.index? == $saved_space)) | .index] | .[0] // empty' \
        <<<"$snapshot_json"
}

restore() {
    local name="$1" dry_run=0 allow_display_mismatch=0 arg file snapshot_json expected_displays actual_displays
    shift
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --dry-run) dry_run=1 ;;
            --allow-display-mismatch) allow_display_mismatch=1 ;;
            *) die "unknown restore option '$1'" ;;
        esac
        shift
    done
    file=$(layout_file "$name")
    [ -f "$file" ] || die "layout not found: $file"
    snapshot_json=$(<"$file")
    "$JQ_BIN" -e '.schema == "yabai-launchpad/v1" and (.windows | type == "array") and (.spaces | type == "array")' \
        >/dev/null <<<"$snapshot_json" || die "unsupported or corrupt layout: $file"
    require_tools
    expected_displays=$("$JQ_BIN" '.displays | length' <<<"$snapshot_json")
    actual_displays=$("$YABAI_BIN" -m query --displays | "$JQ_BIN" 'length')
    if [ "$expected_displays" -ne "$actual_displays" ] && [ "$allow_display_mismatch" -ne 1 ]; then
        die "saved layout has $expected_displays displays but current setup has $actual_displays; use --allow-display-mismatch only if intentional"
    fi

    if [ "$dry_run" -eq 1 ]; then
        info "dry run: would launch $("$JQ_BIN" '[.windows[].app] | unique | length' <<<"$snapshot_json") apps and restore $("$JQ_BIN" '.windows | length' <<<"$snapshot_json") windows"
        info "dry run: no windows, Spaces, or focus will be changed"
        return 0
    fi

    launch_saved_apps "$snapshot_json"
    local deadline now current windows_spec app title saved_space space_index id used_json floating x y w h
    deadline=$(( $(date +%s) + WAIT_SECONDS ))
    used_json='[]'
    while IFS= read -r windows_spec; do
        app=$(json_field '.app // empty' "$windows_spec")
        title=$(json_field '.title // empty' "$windows_spec")
        saved_space=$(json_field '.space // empty' "$windows_spec")
        [ -n "$app" ] || continue
        id=''
        while [ -z "$id" ]; do
            current=$("$YABAI_BIN" -m query --windows 2>/dev/null || true)
            id=$(current_window_id "$app" "$title" "$used_json" "$current" || true)
            [ -n "$id" ] && break
            now=$(date +%s)
            [ "$now" -lt "$deadline" ] || break
            sleep 1
        done
        if [ -z "$id" ]; then
            warn "could not match window: app='$app' title='$title'"
            continue
        fi
        used_json=$("$JQ_BIN" --argjson used "$used_json" --argjson id "$id" '$used + [$id]' <<<"null")
        space_index=$(space_index_for_window "$snapshot_json" "$saved_space" || true)
        if [ -n "$space_index" ]; then
            "$YABAI_BIN" -m window "$id" --space "$space_index" || warn "could not move '$app' to Space $space_index"
        else
            warn "could not resolve saved Space for '$app'"
        fi
        floating=$(json_field '.floating // false' "$windows_spec")
        if [ "$floating" != "true" ]; then
            "$YABAI_BIN" -m window "$id" --toggle float >/dev/null 2>&1 || true
        fi
        x=$(json_field '.frame.x // empty' "$windows_spec")
        y=$(json_field '.frame.y // empty' "$windows_spec")
        w=$(json_field '.frame.w // empty' "$windows_spec")
        h=$(json_field '.frame.h // empty' "$windows_spec")
        if [ -n "$x" ] && [ -n "$y" ]; then
            "$YABAI_BIN" -m window "$id" --move "abs:$x:$y" || warn "could not restore position for '$app'"
        fi
        if [ -n "$w" ] && [ -n "$h" ]; then
            "$YABAI_BIN" -m window "$id" --resize "abs:$w:$h" || warn "could not restore size for '$app'"
        fi
    done < <("$JQ_BIN" -c '.windows[]' <<<"$snapshot_json")
    info "restore finished; verify the layout visually"
}

command="${1:-}"
case "$command" in
    snapshot)
        [ "$#" -eq 2 ] || { usage; exit 2; }
        require_tools
        snapshot "$2"
        ;;
    restore)
        [ "$#" -ge 2 ] || { usage; exit 2; }
        restore "$2" "${@:3}"
        ;;
    list)
        [ "$#" -eq 1 ] || { usage; exit 2; }
        list_layouts
        ;;
    path)
        [ "$#" -eq 2 ] || { usage; exit 2; }
        layout_file "$2"
        ;;
    -h|--help|help|'')
        usage
        ;;
    *)
        usage
        exit 2
        ;;
esac
