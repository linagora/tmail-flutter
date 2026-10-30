# Mobile CI tunnels

## Why tunnels
- Firebase Test Lab (FTL) devices run in Google's cloud.
- The JMAP backends run in Docker on the Jenkins agent, behind NAT.
- Each backend slot gets one public tunnel.
- The backend reset server gets one more tunnel.
- Total tunnels = `POOL_SIZE + 1` (default 6 + 1 = 7).
- The reset server's public URL is baked into the APK (`RESET_SERVER_URL`), so it must not change during a run.
- The reset server hands each test its slot's public URL on `POST /lease`.

## Relay
- Tunnels use `bore` through the public relay `bore.pub`.
- The relay is a free service run by the bore author.
- Our scripts: `scripts/ci-bore-tunnels.sh`, `scripts/patrol-integration-test-with-docker.sh`.
- Set `BORE_HOST` to use another relay (for example a self-hosted `bore server`).

## Limitations
| Limitation | Source |
|---|---|
| No uptime promise. Outages in 2026-02, 2026-05, 2026-08. | ekzhang/bore #182, #187, #196, #200 |
| The author has browned out bore.pub to fight abuse. The service may stop. | ekzhang/bore #150 |
| Asking for the same public port again (`--port`) is best-effort. It often fails with "port already in use". | ekzhang/bore #147 |
| The client does not notice a dead connection quickly. The heartbeat design will not change. | ekzhang/bore #147 |
| When the relay closes the control connection, the client exits with code 0 and logs nothing. | bore v0.6.0 `src/client.rs`, `listen()`, `None => return Ok(())` |
| Some ISPs block bore.pub. | ekzhang/bore #104 |

## What the scripts do about it
- Each tunnel runs under `supervise_bore`.
- When bore exits, the supervisor logs `[bore-supervisor …] exited` and restarts it on the same public port.
- A tunnel that cannot rebind within `BORE_RECONNECT_WINDOW` seconds (default 120) is given up: `gave up` is logged and the supervisor exits.
- A supervisor stops when the script that started it is gone, so a killed job leaves no tunnel behind.
- Before FTL starts, the tunnels are checked:
  - every supervisor is alive;
  - the reset tunnel answers an HTTP request through the relay;
  - every slot that is not dropped also answers through the relay, because the reset server can still lease it (a failed tunnel is retried once after 5 s);
  - a slot the reset server dropped (`ERROR slot N attempt 2` in `backend-reset-server.log`) only logs a `WARN`;
  - at least `FTL_SHARDS` slot tunnels answer (the reset server also starts with that many free backends).
- After FTL, `check_bore_supervisors` runs again and `bore_summary` prints one row per tunnel.
- A request in flight when a tunnel drops still fails. Only later requests recover.

## Failure signature
- Dart tests fail in about 1 second.
- Logcat shows `Connection refused` or `Connection reset by peer` for `bore.pub:<port>`.
- `ci-logs/bore-*.log` have no `new connection` lines.
- `ci-logs/backend-reset-server.log` has no `lease request` lines.
- All tunnels dropped at the same moment: the relay is the cause.

## Where to look
- Console: `ERROR: … tunnel …`, the `bore probe` timing lines, and the summary table.
- `ci-logs/bore-summary.txt`: connections, errors, exits and give-ups per tunnel.
- `ci-logs/bore-*.log`: `[bore-supervisor …]` lines give exit, reconnect and give-up times.
- `ci-logs/backend-reset-server.log`: lease and release requests.
- `ci-logs/patrol-build.log`: the full Gradle and Patrol build output.
- The console hides repetitive lines (Gradle tasks, Dio dumps, GetX lifecycle).
- Its last line, `[console-filter] dropped N lines (…); full log: <path>`, names the file with every line.

## Tuning the tunnel count
- Set `POOL_SIZE` and `FTL_SHARDS` in the `environment` block of `JenkinsfileMobile`.
- Rule: `FTL_SHARDS <= POOL_SIZE <= 16`.
- Drops or give-ups on only some tunnels, or more drops with more tunnels: use `POOL_SIZE=4` (5 tunnels).
- Drops continue: use `FTL_SHARDS=3` and `POOL_SIZE=3` (4 tunnels). Runs get slower.
- Drops on all tunnels at once: lowering the count does not help.

## Knobs
| Variable | Default | Meaning |
|---|---|---|
| `BORE_HOST` | `bore.pub` | Relay host |
| `BORE_RECONNECT_WINDOW` | `120` | Seconds a tunnel may keep failing to rebind |
| `POOL_SIZE` | `6` | Backend slots, one tunnel each |
| `FTL_SHARDS` | `4` | Parallel FTL devices |
