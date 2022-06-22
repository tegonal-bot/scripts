#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/scripts
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        It is licensed under Apache 2.0
#  \__/\__/\_, /\___/_//_/\_,_/_/         Please report bugs and contribute back your improvements
#         /___/
#                                         Version: v0.3.0-SNAPSHOT-SNAPSHOT
#
#######  Description  #############
#
#  Updates the version which is placed before the `Description` section in bash files (line 8 in this file).
#
#######  Usage  ###################
#
#    #!/usr/bin/env bash
#    set -e
#    declare current_dir
#    current_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
#    # Assuming update-version-scripts.sh is in the same directory as your script
#    "$current_dir/update-version-scripts.sh" -v 0.1.0
#
###################################

set -e

declare -A params
declare -A help

declare version directory

params[version]='-v|--version'
help[version]='the version which shall be used'

# shellcheck disable=SC2034
params[directory]='-d|--directory'
# shellcheck disable=SC2034
help[directory]='(optional) the working directory -- default: ./src'

declare examples
# shellcheck disable=SC2034
examples=$(cat << EOM
# update version to v0.1.0 for all *.sh in ./src and subdirectories
update-version-scripts.sh -v v0.1.0

# update version to v0.1.0 for all *.sh in ./scripts and subdirectories
update-version-scripts.sh -v v0.1.0 -d ./scripts

EOM
)

declare current_dir
current_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
# Assuming parse-args.sh is in the same directory as your script
source "$current_dir/../utility/parse-args.sh"

parseArguments params "$@"
# in case there are optional parameters, then fill them in here before calling checkAllArgumentsSet
if ! [ -v directory ]; then directory="./src"; fi
checkAllArgumentsSet params

find "$directory" -name "*.sh" \
  -print0 | while read -r -d $'\0' script
    do
      perl -0777 -i \
         -pe "s/Version:.+(\n[\S\s]+?###+\s+Description)/Version: $version\$1/g;" \
         "$script"
    done
