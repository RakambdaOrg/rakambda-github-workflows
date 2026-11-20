#!/bin/bash
# Self-hosted runner hook (ACTIONS_RUNNER_HOOK_JOB_STARTED): leave a clean state before every job.
# Fail closed: any error exits non-zero and the runner refuses to start the job.
set -euo pipefail

ids=$(docker ps -aq)
if [ -n "$ids" ]; then
  # shellcheck disable=SC2086
  docker rm -f $ids
fi
docker network prune -f
# Anonymous volumes only: named volumes (build caches) are kept on purpose.
docker volume prune -f
rm -f "${HOME:-/home/runner}/.docker/config.json"
