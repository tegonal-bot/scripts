#!/usr/bin/env bash
set -eu
# Assumes tegonal's scripts were fetched with gget - adjust location accordingly
dir_of_tegonal_scripts="$(realpath "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd 2>/dev/null)/../lib/tegonal-scripts/src")"
source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"

"$dir_of_tegonal_scripts/releasing/toggle-sections.sh" -c main

# if you use it in combination with other files, then you might want to source it instead
sourceOnce "$dir_of_tegonal_scripts/releasing/toggle-sections.sh"

# and then call the function
toggleSections -c release
