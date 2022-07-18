#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/scripts
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        It is licensed under Apache 2.0
#  \__/\__/\_, /\___/_//_/\_,_/_/         Please report bugs and contribute back your improvements
#         /___/
#                                         Version: v0.9.0-SNAPSHOT
#
#######  Description  #############
#
# Intended to parse positional function parameters including assignment and check if there are enough arguments
#
#######  Usage  ###################
#
#    #!/usr/bin/env bash
#    set -eu
#
#    if ! [[ -v dir_of_tegonal_scripts ]]; then
#    	# Assumes tegonal's scripts were fetched with gget - adjust location accordingly
#    	dir_of_tegonal_scripts="$(realpath "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd 2>/dev/null)/../lib/tegonal-scripts/src")"
#    	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
#    fi
#    sourceOnce "$dir_of_tegonal_scripts/utility/parse-fn-args.sh"
#
#    function myFunction() {
#    	# declare the variable you want to use and repeat in `declare params`
#    	local command dir
#
#    	# as shellcheck doesn't get that we are passing `params` to parseFnArgs ¯\_(ツ)_/¯ (an open issue of shellcheck)
#    	# shellcheck disable=SC2034
#    	local -ra params=(command dir)
#    	parseFnArgs params "$@"
#
#    	# pass your variables storing the arguments to other scripts
#    	echo "command: $command, dir: $dir"
#    }
#
#    function myFunctionWithVarargs() {
#
#    	# in case you want to use a vararg parameter as last parameter then name your last parameter for `params` varargs:
#    	local command dir varargs
#    	# shellcheck disable=SC2034
#    	local -ra params=(command dir varargs)
#    	parseFnArgs params "$@"
#
#    	# use varargs in another script
#    	echo "command: $command, dir: $dir, varargs: ${varargs*}"
#    }
#
#######	Limitations	#############
#
#	1. Does not support named arguments (see parse-args.sh if you want named arguments for your function)
#
###################################
set -eu

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$(realpath "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd 2>/dev/null)/..")"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi
sourceOnce "$dir_of_tegonal_scripts/utility/checks.sh"
sourceOnce "$dir_of_tegonal_scripts/utility/log.sh"

function parseFnArgs() {
	if (($# < 2)); then
		logError "At least two arguments need to be passed to parseFnArgs.\nGiven \033[0;36m%s\033[0m in \033[0;36m%s\033[0m\nFollowing a description of the parameters:" "$#" "${BASH_SOURCE[1]}"
		echo >&2 '1. params     the name of an array which contains the parameter names'
		echo >&2 '2... args...  the arguments as such, typically "$@"'
		return 9
	fi

	# using unconventional naming in order to avoid name clashes with the variables we will initialise further below
	local -rn parseFnArgs_paramArr1=$1
	shift

	checkArgIsArray parseFnArgs_paramArr1 1

	local parseFnArgs_withVarArgs
	if [[ ${parseFnArgs_paramArr1[$((${#parseFnArgs_paramArr1[@]} - 1))]} == "varargs" ]]; then
		parseFnArgs_withVarArgs=true
	else
		parseFnArgs_withVarArgs=false
	fi

	local -r minExpected=$( ([[ $parseFnArgs_withVarArgs == false ]] && echo "${#parseFnArgs_paramArr1[@]}") || echo "$((${#parseFnArgs_paramArr1[@]} - 1))")
	if (($# < minExpected)); then
		logError "Not enough arguments supplied to \033[0m\033[0;36m%s\033[0m in %s\nExpected %s, given %s\nFollowing a listing of the expected arguments (red means missing):" \
			"${FUNCNAME[1]}" "${BASH_SOURCE[1]}" "${#parseFnArgs_paramArr1[@]}" "$#"

		for ((parseFnArgs_i = 0; parseFnArgs_i < minExpected; ++parseFnArgs_i)); do
			local parseFnArgs_name=${parseFnArgs_paramArr1[parseFnArgs_i]}
			printf "\033[0m"
			if ((parseFnArgs_i < $#)); then
				printf "\033[0;32m"
			else
				printf "\033[0;31m"
			fi
			printf >&2 "%2s: %s\n" "$((parseFnArgs_i + 1))" "$parseFnArgs_name"
		done
		printf "\033[0m"
		if [[ $parseFnArgs_withVarArgs == true ]]; then
			printf >&2 "%2s: %s\n" "$((parseFnArgs_i + 1))" "varargs"
		fi
		return 9
	fi

	if [[ $parseFnArgs_withVarArgs == false ]] && ! (($# == ${#parseFnArgs_paramArr1[@]})); then
		logError "more arguments supplied to \033[0m\033[0;36m%s\033[0m in %s than expected\nExpected %s, given %s" \
			"${FUNCNAME[1]}" "${BASH_SOURCE[1]}" "${#parseFnArgs_paramArr1[@]}" "$#"
		echo >&2 "in case you wanted your last parameter to be a vararg parameter, then use 'varargs' as last variable name in your array containing the parameter names."
		echo >&2 "Following a listing of the expected arguments:"
		for ((parseFnArgs_i = 0; parseFnArgs_i < minExpected; ++parseFnArgs_i)); do
			local parseFnArgs_name=${parseFnArgs_paramArr1[parseFnArgs_i]}
			printf >&2 "%2s: %s\n" "$((parseFnArgs_i + 1))" "$parseFnArgs_name"
		done
		return 9
	fi

	for ((parseFnArgs_i = 0; parseFnArgs_i < minExpected; ++parseFnArgs_i)); do
		local parseFnArgs_name=${parseFnArgs_paramArr1[parseFnArgs_i]}
		# assign arguments to specified variables
		printf -v "$parseFnArgs_name" "%s" "$1"
		shift
	done

	# assign rest to varargs if used
	if [[ $parseFnArgs_withVarArgs == true ]]; then
		# is used afterwards
		# shellcheck disable=SC2034
		varargs=("$@")
	fi
}
