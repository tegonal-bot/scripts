#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/scripts
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        It is licensed under Apache 2.0
#  \__/\__/\_, /\___/_//_/\_,_/_/         Please report bugs and contribute back your improvements
#         /___/
#
#
set -e

declare projectDir
projectDir="$(realpath "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd 2>/dev/null)/../")"

source "$projectDir/src/utility/update-bash-docu.sh"
source "$projectDir/src/utility/replace-help-snippet.sh"

find "$projectDir/src" -name "*.sh" \
	-not -name "*.doc.sh" \
	-print0 |
	while read -r -d $'\0' script; do
		declare relative
		relative="$(realpath --relative-to="$projectDir" "$script")"
		declare id="${relative:4:-3}"

		updateBashDocumentation "$script" "${id////-}" . README.md
	done

declare executableScripts=(
	releasing/sneak-peek-banner
	releasing/toggle-sections
	releasing/update-version-README
	releasing/update-version-scripts
)

for script in "${executableScripts[@]}"; do
	replaceHelpSnippet "$projectDir/src/$script.sh" "${script////-}-help" . README.md
done
