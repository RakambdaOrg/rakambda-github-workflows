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

## Network isolation (Proxmox firewall, CT 105)

`proxmox-firewall-105.fw` is a copy of `/etc/pve/firewall/105.fw` on the Proxmox host: the runner can reach the internet but not the LAN (IPv4 private ranges, IPv6 LAN prefix, ULA).
The datacenter firewall, the CT firewall and the `firewall=1` flag on `net0` must all be enabled. Replace `<IPV6_PREFIX>` with the LAN `/64` before copying.
Test from the host: `pct exec 105 -- curl -m 5 http://<router-ip>` must time out, `pct exec 105 -- curl -sSI https://github.com` must succeed.
Not covered yet: IPv6 link-local (`fe80::/10`) TCP/UDP.
