# Wait for Job

Wait for a specific GitHub Actions workflow job to complete. Can be useful for synchronization between separate workflows.

This action can be used to wait for jobs within the same workflow but users should typically rely on the built-in GitHub Actions [`jobs.*.needs`](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#jobsjob_idneeds) functionality for this purpose.

## Example

```yaml
---
jobs:
  example:
    # These permissions are needed to:
    # - Get the workflow run: https://github.com/beacon-biosignals/get-workflow-run#permissions
    # - Wait for the workflow job: https://github.com/beacon-biosignals/wait-for-job#permissions
    runs-on: ubuntu-latest
    steps:
      - uses: beacon-biosignals/get-workflow-run@v1
        id: workflow-run
        with:
          workflow-file: build.yaml
          commit-sha: ${{ github.event.pull_request.head.sha }}
      - uses: beacon-biosignals/wait-for-job@v1
        id: wait-for-job
        with:
          run-id: ${{ steps.workfow-run.outputs.run-id }}
          job-name: Build
      # Now interact with shared resource created or modified the the job
```

## Inputs

| Name                 | Description | Required | Example |
|:---------------------|:------------|:---------|:--------|
| `run-id`             | The workflow run containing the job to wait for. | Yes | `9035794515` |
| `job-name`           | The rendered workflow job name to wait for. | Yes | `Build` |
| `timeout`            | The maximum amount of seconds to wait for the workflow job. Defaults to `600` (10 minutes). | No | `300` |
| `poll-interval`      | Number of seconds between job status checks. Defaults to `15`. | No | `5` |
| `repository`         | The repository runing the workflow. Defaults to `${{ github.repository }}`. | No | `beacon-biosignals/wait-for-job` |
| `token`              | The GitHub token used to authenticate with the GitHub API. Need when attempting to access artifacts in a different repository. Defaults to `${{ github.token }}`. | No | `${{ secret.PAT }}` |

## Outputs

| Name         | Description | Example |
|:-------------|:------------|:--------|
| `job-id`     | The job ID of the job which was waited upon. | `35737668081` |
| `conclusion` | The result of the completed job after [`continue-on-error`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepscontinue-on-error) is applied. Possible values are `success`, `failure`, `cancelled`, or `skipped`. | `success` |

## Permissions

The following [job permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs) are required to run this action:

```yaml
permissions:
  actions: read
```
