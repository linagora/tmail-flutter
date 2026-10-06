## Inputs
- `.security-review/commits.txt` — commits since the last scan
- `.security-review/diffstat.txt`, `.security-review/diff.patch` — the change set (generated code, translations, package-lock.json and Podfile.lock excluded)
- `.security-review/findings.json` — open scanner alerts, error/warning only (gitleaks, trivy, osv, semgrep, mobsfscan)
- The full repository, for context around changed code

## Tasks
A. Review `diff.patch`. For each changed hunk touching a category above, read the surrounding code and decide if it adds or keeps a real, exploitable issue. Ignore style. A pubspec.lock change to a git dependency's resolved-ref (sanitize_html, html-editor-enhanced forks) moves the HTML sanitizing boundary: name the ref change and what it touches.
B. Triage the entries in `findings.json` (max 40, highest severity first). For each: TRUE POSITIVE or FALSE POSITIVE, with a one-line reason based on the code you read.

## Output (markdown only, nothing else)
### New issues in this change set
| Severity | Category | file:line | Issue | Fix direction |
(or "None found.")

### Scanner triage
| Tool | Rule | file:line | Verdict | Reason |

### Notes
- Max 5 bullets: anything you could not verify.
