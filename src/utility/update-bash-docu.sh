#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/scripts
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        It is licensed under Apache 2.0
#  \__/\__/\_, /\___/_//_/\_,_/_/         Please report bugs and contribute back your improvements
#         /___/
#                                         Version: v0.5.0-SNAPSHOT
#
#
#######  Description  #############
#
#  checks if there is a script.help.sh next to the script.sh file, calls
#  replaceSnippet (from replace-snippet.sh) with its content
#  and updates the `Usage` section in script.sh accordingly
#
#######  Usage  ###################
#
#    #!/usr/bin/env bash
#    set -eu
#
#    declare scriptDir
#    scriptDir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
#
#    # Assuming update-bash-docu.sh is in the same directory as your script
#    source "$scriptDir/update-bash-docu.sh"
#    find . -name "*.sh" \
#    	-not -name "*.doc.sh" \
#    	-not -path "**.history/*" \
#    	-not -name "update-docu.sh" \
#    	-print0 | while read -r -d $'\0' script
#    		do
#    			declare script="${script:2}"
#    			replaceSnippetForScript "$scriptDir/$script" "${script////-}" . README.md
#    		done
#
###################################
set -eu

function updateBashDocumentation(){
	local script id dir pattern
	# args is required for parse-fn-args.sh thus:
	# shellcheck disable=SC2034
	local -ra args=(script id dir pattern)

	local scriptDir
	scriptDir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
	local -r scriptDir
	source "$scriptDir/parse-fn-args.sh" || return 1
	source "$scriptDir/replace-snippet.sh"

	local snippet
	snippet=$(cat "${script::-3}.doc.sh")

	local quotedSnippet
	quotedSnippet=$(echo "$snippet" | perl -0777 -pe 's/(\/|\$|\\)/\\$1/g;' | sed 's/^/#    /' | sed 's/^#    $/#/')

	perl -0777 -i \
		-pe "s/(###+\s+Usage\s+###+\n#\n)[\S\s]+?(\n#\n###+)/\$1${quotedSnippet}\$2/g;" \
		"$script"

	replaceSnippet "$script" "$id" "$dir" "$pattern" "$(printf "\`\`\`bash\n%s\n\`\`\`" "$snippet")"
}
