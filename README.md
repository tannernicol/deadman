# GitHub dead-man heartbeat

An off-property check for a machine that can commit to GitHub.

## Why

Two existing watchers can live inside the same blast radius. A whole-house
power or internet outage can take both out together, leaving a quiet night
that looks exactly like health. This repository runs the third watcher on
GitHub's infrastructure: it sees the absence of an hourly heartbeat.

## How it works

`scripts/heartbeat.sh` commits a UTC timestamp to `heartbeat/<host>` every
hour. GitHub Actions checks its age every 30 minutes. If it is older than four
hours, missing, malformed, or in the future, the workflow opens an issue and
sends a silent ntfy notification. When the heartbeat returns, it closes the
same issue.

## Install

1. Select **Use this template** on GitHub to create your own repository, then
   clone it to the machine that will send the heartbeat (the examples use
   `$HOME/deadman`). Give that clone credentials that can push to its own
   repository.
2. In the repository's **Settings → Secrets and variables → Actions**, set the
   repository variable `HOST_NAME` (for example, `my-server`). It defaults to
   `my-server` if omitted. Create the repository secret `NTFY_URL` with the
   full ntfy publish URL, such as `https://ntfy.sh/<topic>`.
   Anyone who knows a public ntfy topic can publish to it, so keep that URL in
   a secret rather than committing it.
3. Install the heartbeat script with the included systemd units:

   ```bash
   mkdir -p ~/.config/systemd/user
   cp systemd/github-heartbeat.service systemd/github-heartbeat.timer ~/.config/systemd/user/
   systemctl --user daemon-reload
   systemctl --user enable --now github-heartbeat.timer
   ```

   The unit assumes the clone is `$HOME/deadman`; edit its two paths if yours
   is elsewhere. Alternatively, use cron:

   ```cron
   0 * * * * cd "$HOME/deadman" && ./scripts/heartbeat.sh
   ```

4. Run `./scripts/heartbeat.sh` once, then use **Run workflow** on the
   `deadman` Actions workflow to confirm the first check is healthy. (The
   workflow is disabled in this template repository itself, because the
   template has no heartbeat to watch; it is enabled in repositories created
   from it.)

## Deliberate choices

- **An open issue is the state.** No database or extra service is needed, and
  the alert remains readable in a browser if a phone push is missed.
- **Four-hour threshold.** The heartbeat is hourly, so this tolerates a delayed
  Actions run plus missed pushes. A dead-man that cries wolf gets muted.
- **Hourly, not every 10 minutes.** This is an outage signal, not a fast health
  check; hourly keeps history useful and avoids needless repository churn.
- **Silent push.** ntfy uses minimum priority: the issue is the durable record,
  while the push is only a nudge.
- **The heartbeat keeps the workflow alive.** GitHub disables scheduled
  workflows after 60 days of repository inactivity; hourly commits prevent
  that expiry.

## What it does NOT cover

- It cannot distinguish a powered-off machine from a broken network path.
- It relies on GitHub Actions, GitHub Issues, and the machine's ability to push
  to GitHub; it is not an independent monitoring service for those systems.
- It watches one configured heartbeat. Add separate, clearly named checks if
  you need to locate failures across multiple machines.

## Maintenance

Maintenance: slow until 2027-01.

## License

MIT. See [LICENSE](LICENSE).
