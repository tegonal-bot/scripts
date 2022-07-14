#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/scripts
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        It is licensed under Apache 2.0
#  \__/\__/\_, /\___/_//_/\_,_/_/         Please report bugs and contribute back your improvements
#         /___/
#                                         Version: v0.6.0-SNAPSHOT
#
#######  Description  #############
#
#  function which searches for *.sh files within defined directories and runs shellcheck on each file with
#  predefined settings i.a. sets `-s bash`
#
#######  Usage  ###################
#
#    #!/usr/bin/env bash
#    set -eu
#    declare dir_of_tegonal_scripts
#    # Assuming tegonal's scripts are in the same directory as your script
#    dir_of_tegonal_scripts="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd 2>/dev/null)"
#    source "$dir_of_tegonal_scripts/qa/run-shellcheck.sh"
#
#    # shellcheck disable=SC2034
#    declare -a dirs=(
#    	"$dir_of_tegonal_scripts"
#    	"$dir_of_tegonal_scripts/../scripts"
#    	"$dir_of_tegonal_scripts/../spec"
#    )
#    declare sourcePath="$dir_of_tegonal_scripts"
#    runShellcheck dirs "$sourcePath"
#
###################################
set -eu

if ! [[ -v dir_of_tegonal_scripts ]]; then
	declare dir_of_tegonal_scripts
	dir_of_tegonal_scripts="$(realpath "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd 2>/dev/null)/..")"
	declare -r dir_of_tegonal_scripts
fi

function runShellcheck() {
	source "$dir_of_tegonal_scripts/utility/log.sh"
	source "$dir_of_tegonal_scripts/utility/recursive-declare-p.sh"

	if ! (($# == 2)); then
		logError "Two parameter need to be passed to runShellcheck\nGiven \033[0;36m%s\033[0m in \033[0;36m%s\033[0m\nFollowing a description of the parameters:" "$#" "${BASH_SOURCE[1]}"
		echo >&2 '1. dirs		 name of array which contains directories in which *.sh files are searched'
		echo >&2 '2. sourcePath		 equivalent to shellcheck''s -P, path to search for sourced files, separated by :'
		return 9
	fi
	local -n directories=$1
	local sourcePath=$2

	reg='declare -a.*'
	local arrayDefinition
	arrayDefinition="$(set -e && recursiveDeclareP directories)"
	if ! [[ "$arrayDefinition" =~ $reg ]]; then
		logError "the passed array \033[1;34m%s\033[0m defined in %s is broken." "${!directories}" "${BASH_SOURCE[1]}"
		printf >&2 "the first argument to %s needs to be a non-associative array, given:\n" "${FUNCNAME[0]}"
		echo >&2 "$arrayDefinition"
		return 9
	fi

	local -i fileWithIssuesCounter=0
	local -i fileCounter=0
	while read -r -d $'\0' script; do
		((fileCounter += 1))
		declare output
		# SC2312 Consider invoking this command separately to avoid masking its return value (or use '|| true' to ignore).
		# ==> too many false positives
		# SC2250 Prefer putting braces around variable references even when not strictly required.
		# ==> IMO without braces reads nicer
		output=$(shellcheck -C -x -o all -e SC2312 -e SC2250 -P "$sourcePath" "$script" || true)
		if ! [[ $output == "" ]]; then
			printf "%s\n" "$output"
			((fileWithIssuesCounter += 1))
		fi
		if ((fileWithIssuesCounter >= 5)); then
			logInfoWithoutNewline "Already found issues in %s files, going to stop the analysis now in order to keep the output small" "$fileWithIssuesCounter"
			break
		fi
		printf "."
	done < <(find "${directories[@]}" -name '*.sh' -print0)
	printf "\n"

	if ((fileWithIssuesCounter > 0)); then
		die "found shellcheck issues in %s files" "$fileWithIssuesCounter"
	else
		logSuccess "no shellcheck issues found, analysed %s files" "$fileCounter"
	fi
}