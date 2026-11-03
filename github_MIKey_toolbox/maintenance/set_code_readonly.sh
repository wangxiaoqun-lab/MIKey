#!/usr/bin/env bash
set -euo pipefail
mode="${1:-protect}"
case "$mode" in protect|unlock) ;; *) echo 'Use protect or unlock' >&2; exit 2 ;; esac
root="$(cd -- "$(dirname -- "$0")/.." && pwd -P)"
list="$root/docs/maintenance/readonly-code-files.txt"
while IFS= read -r relative || [[ -n "$relative" ]]; do
    [[ -z "$relative" ]] && continue
    case "$relative" in /*|*..*|*:*|*\*) echo 'Unsafe source-list entry' >&2; exit 2 ;; esac
    [[ -f "$root/$relative" && ! -L "$root/$relative" ]] || { echo "Missing/linked core: $relative" >&2; exit 1; }
done < "$list"
while IFS= read -r relative || [[ -n "$relative" ]]; do
    [[ -z "$relative" ]] && continue
    if [[ "$mode" == protect ]]; then chmod a-w -- "$root/$relative"; else chmod u+w -- "$root/$relative"; fi
done < "$list"
printf '%s completed; user configurations and data are unchanged.\n' "$mode"
