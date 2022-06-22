#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/scripts
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        It is licensed under Apache 2.0
#  \__/\__/\_, /\___/_//_/\_,_/_/         Please report bugs and contribute back your improvements
#         /___/
#                                         Version: v0.1.0
#
#######  Description  #############
#
#  Searches for <!-- for main --> ... <!-- for main end --> as well as for
#  <!-- for a specific release --> ... <!-- for a specific release end -->
#  and kind of toggles section in the sense of  if the passed command is 'main', then
# the content of <!-- for a specific release --> sections is commented and the content in <!-- for main --> is
# uncommented. Same same but different if someone passes the command 'release'
#
#######  Usage  ###################
#
#    #!/usr/bin/env bash
#    set -e
#    declare current_dir
#    current_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
#    # Assuming sneak-peek-banner.sh is in the same directory as your script
#    "$current_dir/sneak-peek-banner.sh" -c hide
#
###################################
set -e

declare -A params
declare -A help

declare command file

params[command]='-c|--command'
help[command]="either 'main' or 'release'"

# shellcheck disable=SC2034
params[file]='-f|--file'
# shellcheck disable=SC2034
help[file]='(optional) the file where search & replace shall be done -- default: ./README.md'

declare examples
# shellcheck disable=SC2034
examples=$(cat << EOM
# comment the release sections in ./README.md and uncomment the main sections
toggle-sections.sh -c main

# comment the main sections in ./docs/index.md and uncomment the release sections
toggle-sections.sh -c release -f ./docs/index.md

EOM
)

declare current_dir
current_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
# Assuming parse-args.sh is in the same directory as your script
source "$current_dir/../utility/parse-args.sh"

parseArguments params "$@"
# in case there are optional parameters, then fill them in here before calling checkAllArgumentsSet
if ! [ -v file ]; then file="./README.md"; fi
checkAllArgumentsSet params

function toggleSection() {
  local file=$1
  local comment=$2
  local uncomment=$3
  perl -0777 -i \
      -pe "s/(<!-- for $comment -->\n)\n([\S\s]*?)(\n<!-- for $comment end -->\n)/\${1}<!--\n\${2}-->\${3}/g;" \
      -pe "s/(<!-- for $uncomment -->\n)<!--\n([\S\s]*?)-->(\n<!-- for $uncomment end -->)/\${1}\n\${2}\${3}/g" \
      "$file"
}

if [ "$command" == "main" ]; then
  echo "comment release sections and uncomment main sections"
  toggleSection "$file" "release" "main"
elif [  "$command" == "release" ]; then
  echo "comment main sections and uncomment release sections"
  toggleSection "$file" "main" "release"
else
  echo >&2 "only 'main' and 'release' are supported as command. Following the output of calling --help"
  printHelp params
fi

