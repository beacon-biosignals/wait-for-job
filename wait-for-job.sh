#!/usr/bin/env bash

set -eo pipefail

timeout=${timeout:-600}
poll_interval=${poll_interval:-15}

start=$EPOCHSECONDS
last_status=""
while [[ $((EPOCHSECONDS - start)) -lt $timeout ]]; do
    # When we poll for the job before the workflow has started then `job` will be empty.
    # https://docs.github.com/en/rest/actions/workflow-jobs?apiVersion=2022-11-28#list-jobs-for-a-workflow-run
    job="$(gh api -X GET --paginate "/repos/{owner}/{repo}/actions/runs/${run_id:?}/jobs" --jq ".jobs[] | select(.name == \"${job_name:?}\")")"

    if [[ -n "$job" ]]; then
        status="$(jq -er '.status' <<<"${job}")"
        if [[ "$status" != "$last_status" ]]; then
            [[ -z "$last_status" ]] && echo "Waiting on job: $(jq -er '.html_url' <<<"${job}")"
            echo "$status"
            last_status="$status"
        fi

        if [[ "$status" == "completed" ]]; then
            break
        fi
    fi

    sleep "${poll_interval}"
done

job_id="$(jq -r '.id' <<<"${job}")"
echo "job-id=${job_id:?}" | tee -a "$GITHUB_OUTPUT"

# Prefer returning `` instead of `null`.
conclusion="$(jq -r '.conclusion // empty' <<<"${job}")"
echo "conclusion=${conclusion}" | tee -a "$GITHUB_OUTPUT"

if [[ "$status" != "completed" ]]; then
    echo "Timed out while waiting for job to complete" >&2
    exit 1
fi
