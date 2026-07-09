#!/usr/bin/env bash
# Generates a changelog from the mod files changed in the latest commit.
set -euo pipefail

if ! git rev-parse HEAD^ >/dev/null 2>&1; then
  echo "Initial release."
  exit 0
fi

modname() {
  # $1 = ref, $2 = path; reads the mod's display name from its .pw.toml
  git show "$1:$2" 2>/dev/null | grep -m1 '^name' | cut -d'"' -f2 || basename "$2" .pw.toml
}

added=() updated=() removed=()

while IFS=$'\t' read -r status path _; do
  case "$path" in mods/*.pw.toml|resourcepacks/*.pw.toml|shaderpacks/*.pw.toml) ;; *) continue ;; esac
  case "$status" in
    A) added+=("$(modname HEAD "$path")") ;;
    M) updated+=("$(modname HEAD "$path")") ;;
    D) removed+=("$(modname HEAD^ "$path")") ;;
  esac
done < <(git diff --name-status HEAD^ HEAD)

out=""
[ ${#added[@]} -gt 0 ]   && out+="### Added\n$(printf -- '- %s\n' "${added[@]}")\n\n"
[ ${#updated[@]} -gt 0 ] && out+="### Updated\n$(printf -- '- %s\n' "${updated[@]}")\n\n"
[ ${#removed[@]} -gt 0 ] && out+="### Removed\n$(printf -- '- %s\n' "${removed[@]}")\n\n"

if [ -z "$out" ]; then
  echo "Pack configuration updated."
else
  printf "%b" "$out"
fi
