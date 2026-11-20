# Runner hooks

Scripts run by the self-hosted runner (`runner` account, LXC) around each job.

## job-started.sh

Removes leftover containers, networks, anonymous volumes and `~/.docker/config.json`.
Fails closed: if cleanup fails, the job does not start. Caches (`~/.gradle`, named volumes) are kept for now.

## Install (as root, on the runner)

```bash
install -d -o root -g root -m 0755 /opt/runner-hooks
install -o root -g root -m 0755 job-started.sh /opt/runner-hooks/job-started.sh
echo 'ACTIONS_RUNNER_HOOK_JOB_STARTED=/opt/runner-hooks/job-started.sh' >> /opt/actions-runner/.env
# restart the runner service afterwards
```

Root-owned so a job running as `runner` cannot rewrite its own cleanup.
After a runner update, check that `.env` and the script permissions are intact.
Note: the hook runs as `runner`, which has Docker access, so jobs can still reach Docker itself.
