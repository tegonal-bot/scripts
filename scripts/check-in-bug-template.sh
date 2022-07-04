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

declare current_dir
current_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd 2>/dev/null)"

find "$current_dir/../src" -name "*.sh" \
	-not -name "*.doc.sh" \
	-not -path "**.history/*" \
	-print0 |
	while read -r -d $'\0' script; do
		declare path=${script:(${#current_dir} + 8)}
		grep "$path" "$current_dir/../.github/ISSUE_TEMPLATE/bug_report.yaml" >/dev/null || (echo "you forgot to add $path to .github/ISSUE_TEMPLATE/bug_report.yaml" && false)
	done

echo "Success: all scripts are listed in the bug template"
