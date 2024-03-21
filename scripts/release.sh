#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/scripts
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Apache License 2.0
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v2.1.0-SNAPSHOT
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH
export TEGONAL_SCRIPTS_VERSION='v2.1.0-SNAPSHOT'

if ! [[ -v scriptsDir ]]; then
	scriptsDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)"
	readonly scriptsDir
fi

if ! [[ -v projectDir ]]; then
	projectDir="$(realpath "$scriptsDir/../")"
	readonly projectDir
fi

if ! [[ -v dir_of_github_commons ]]; then
	dir_of_github_commons="$projectDir/.gt/remotes/tegonal-gh-commons/lib/src"
	readonly dir_of_github_commons
fi

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$projectDir/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi
sourceOnce "$dir_of_tegonal_scripts/releasing/release-files.sh"
sourceOnce "$dir_of_tegonal_scripts/utility/checks.sh"
sourceOnce "$dir_of_github_commons/gt/pull-hook-functions.sh"
sourceOnce "$scriptsDir/before-pr.sh"
sourceOnce "$scriptsDir/prepare-next-dev-cycle.sh"

function release() {
	if ! checkCommandExists "shellspec" "please install https://github.com/shellspec/shellspec#installation"; then
		die "You need to have shellspec installed if you want to create a release."
	fi

	local projectsRootDirParamPatternLong additionalPatternParamPatternLong findForSigningParamPatternLong
	local afterVersionUpdateHookParamPatternLong
	source "$dir_of_tegonal_scripts/releasing/common-constants.source.sh" || die "could not source common-constants.source.sh"

	local version
  # shellcheck disable=SC2034   # they seem unused but are necessary in order that parseArguments doesn't create global readonly vars
  local key branch nextVersion prepareOnly
	# shellcheck disable=SC2034   # is passed by name to parseArguments
	local -ra params=(
		version "$versionParamPattern" "$versionParamDocu"
		key "$keyParamPattern" "$keyParamDocu"
		branch "$branchParamPattern" "$branchParamDocu"
		nextVersion "$nextVersionParamPattern" "$nextVersionParamDocu"
		prepareOnly "$prepareOnlyParamPattern" "$prepareOnlyParamDocu"
	)
	parseArguments params "" "$TEGONAL_SCRIPTS_VERSION" "$@"

	function findScripts() {
		find "$dir_of_tegonal_scripts" -name "*.sh" -not -name "*.doc.sh" "$@"
	}

	function release_afterVersionHook() {
		# same as in pull-hook.sh
		local -r githubUrl="https://github.com/tegonal/scripts"
		replaceTagInPullRequestTemplate "$projectDir/.github/PULL_REQUEST_TEMPLATE.md" "$githubUrl" "$version" || die "could not fill the placeholders in PULL_REQUEST_TEMPLATE.md"
	}

	# similar as in prepare-next-dev-cycle.sh, you might need to update it there as well if you change something here
	local -r additionalPattern="(TEGONAL_SCRIPTS_(?:LATEST_)?VERSION=['\"])[^'\"]+(['\"])"

	releaseFiles \
		"$projectsRootDirParamPatternLong" "$projectDir" \
		"$additionalPatternParamPatternLong" "$additionalPattern" \
		"$findForSigningParamPatternLong" findScripts \
		"$afterVersionUpdateHookParamPatternLong" release_afterVersionHook \
		"$@"
}

${__SOURCED__:+return}
release "$@"
