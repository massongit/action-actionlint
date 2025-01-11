#!/bin/sh

if [ "${RUNNER_DEBUG}" = "1" ] ; then
  set -x
fi

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}" || exit
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

output="$(actionlint -oneline ${INPUT_ACTIONLINT_FLAGS})"
error_level="$(echo "$output" | sed -e 's/^.* shellcheck reported issue in this script: [^:]*:\([^:]*\):.*$/\1/g')"

# shellcheck disable=SC2086
echo "$output" | sed -e "s/^\([^:]*:[^:]*:[^:]*:\) \(.*\)$/\1$error_level \2/g" \
    | reviewdog \
        -efm="%f:%l:%c:%t %m" \
        -name="${INPUT_TOOL_NAME}" \
        -reporter="${INPUT_REPORTER}" \
        -filter-mode="${INPUT_FILTER_MODE}" \
        -fail-level="${INPUT_FAIL_LEVEL}" \
        -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
        -level="${INPUT_LEVEL}" \
        ${INPUT_REVIEWDOG_FLAGS}
exit_code=$?

exit $exit_code
