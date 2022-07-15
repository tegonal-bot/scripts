#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/scripts
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        It is licensed under Apache 2.0
#  \__/\__/\_, /\___/_//_/\_,_/_/         Please report bugs and contribute back your improvements
#         /___/
#                                         Version: v0.6.1
#
#######  Description  #############
#
#  Shows or hides the sneak peek banner
#
#######  Usage  ###################
#
#    #!/usr/bin/env bash
#    set -eu
#    declare dir_of_tegonal_scripts
#    # Assuming tegonal's scripts are in the same directory as your script
#    dir_of_tegonal_scripts="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd 2>/dev/null)"
#    "$dir_of_tegonal_scripts/releasing/sneak-peek-banner.sh" -c hide
#
###################################
set -eu
declare -x TEGONAL_SCRIPTS_VERSION='v0.6.1'

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$(realpath "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd 2>/dev/null)/..")"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi
sourceOnce "$dir_of_tegonal_scripts/utility/parse-args.sh"

function sneakPeekBanner() {
	local command file
	# shellcheck disable=SC2034
	local -ra params=(
		command '-c|--command' "either 'show' or 'hide'"
		file '-f|--file' '(optional) the file where search & replace shall be done -- default: ./README.md'
	)
	local -r examples=$(
		cat <<-EOM
			# hide the sneak peek banner in ./README.md
			sneak-peek-banner.sh -c hide

			# show the sneak peek banner in ./docs/index.md
			sneak-peek-banner.sh -c show -f ./docs/index.md
		EOM
	)

	parseArguments params "$examples" "$TEGONAL_SCRIPTS_VERSION" "$@"
	if ! [[ -v file ]]; then file="./README.md"; fi
	checkAllArgumentsSet params "$examples" "$TEGONAL_SCRIPTS_VERSION"

	if [[ $command == show ]]; then
		echo "show sneak peek banner in $file"
		perl -0777 -i -pe 's/<!(---\n❗ You are taking[\S\s]+?---)>/$1/;' "$file"
	elif [[ $command == hide ]]; then
		echo "hide sneak peek banner in $file"
		perl -0777 -i -pe 's/((?<!<!)---\n❗ You are taking[\S\s]+?---)/<!$1>/;' "$file"
	else
		echo >&2 "only 'show' and 'hide' are supported as command. Following the output of calling --help"
		printHelp params help "$examples"
	fi
}
sneakPeekBanner "$@"
