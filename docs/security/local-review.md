# Local security review

Run the same LLM security review as the CI release scan, with your own agent.

## What it is
- Prompts and threat model: `.github/security/llm-*.md`
- Review areas: `.github/security/areas.json`
- CI (`security-release.yaml`) and local runs read the same files.
- Edit them there, and both change.

## Requirements
- `git`, `jq`
- Optional scanners for `--scan`; missing ones are skipped:
  - `brew install gitleaks trivy osv-scanner semgrep`
  - `pipx install mobsfscan==1.0.1`

## Commands
- `bash scripts/security-review.sh list` — print the areas
- `bash scripts/security-review.sh changes` — review changes since the previous release tag
- `bash scripts/security-review.sh --scan changes` — run scanners first, triage their findings
- `bash scripts/security-review.sh --base v0.20.0 all` — every area, custom range
- `bash scripts/security-review.sh html-xss` — one full-area audit

## Agent
- Headless: the prompt is passed as the last argument; the report goes to `.security-review/report-<area>.md`.
  - `--agent "claude -p --permission-mode plan"`
  - `--agent "codex exec --sandbox read-only"`
  - `OPENCODE_PERMISSION='{"bash":"deny","edit":"deny","webfetch":"deny"}' bash scripts/security-review.sh --agent "opencode run" changes`
- Interactive: run without `--agent`, then tell your agent:
  "Follow `.security-review/prompt-<area>.md` and write the report to `.security-review/report-<area>.md`."
- The prompt carries diffs and commit text, which can hold prompt injection: always run the agent read-only, as above.

## Output
- Everything stays in `.security-review/` (gitignored).
- Never commit it or paste it into public issues or PRs.
- Share findings privately with the GitLab owners/maintainers.

## CI release scan
- Runs after "Build Docker images with Sentry" succeeds on a `v*` tag.
- Also runs by hand: Actions → Security release scan → run from `master` → tag input.
- Emails one report to the owners/maintainers of the private GitLab project.
- Members need a public email on ci.linagora.com to receive it.
- One runner runs every scanner and LLM area in parallel; a separate job sends the email.
- `SECURITY_LLM_MAX_PARALLEL` caps concurrent area audits (default 8); the `changes` area runs on top, after the scanners.
- The scanned tag must contain `.github/security/`; tags cut before this change cannot be scanned.

## CI configuration
- Environment `security-release` (deployment refs: tags `v*`, branch `master`) holds every secret below; repo-level secrets are not read.
- PR runs use no environment, so they run without secrets (dry run).
- Secrets: `SECURITY_GITLAB_TOKEN` (`read_api`), `SECURITY_SMTP_URL` (e.g. `smtps://host:465`), `SECURITY_SMTP_USER`, `SECURITY_SMTP_PASSWORD`, `SECURITY_REPORT_KEY` (RSA private key PEM: `openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out report.pem`)
- Secrets for the LLM: `SECURITY_LLM_API_KEYS` (one key per line; a key out of quota or rejected falls back to the next), `SECURITY_LLM_BASE_URL`, `SECURITY_LLM_MODEL`
- Variables: `SECURITY_GITLAB_PROJECT`, `SECURITY_REPORT_PUBLIC_KEY` (`openssl pkey -in report.pem -pubout`), `SECURITY_MAIL_FROM` (bare address, no display name), optional `SECURITY_LLM_MAX_PARALLEL`, optional `SECURITY_LLM_STALL_SECONDS` (default 600; silence after which a key counts as stuck)
