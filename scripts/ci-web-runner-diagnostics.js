#!/usr/bin/env node
// Usage: node scripts/ci-web-runner-diagnostics.js <patrol web_runner dir>
// Logs failed requests and page errors during Patrol page setup: a splash-only hang names the failed URL.
// Never fails the job: a changed spec only prints a warning.
const fs = require("fs");
const path = require("path");

const MARKER = "// tmail-ci-diagnostics";
const ORIGINAL = `    await page.goto("/", { waitUntil: "load" })

    await exposePatrolPlatformHandler(page)

    await initialise(page)
`;
const PATCHED = `    ${MARKER}
    let setupDone = false
    const ciLog = (text: string) => console.log(\`Playwright: [page setup] \${new Date().toISOString()} \${text}\`)
    page.on("requestfailed", request => {
      if (!setupDone) ciLog(\`request failed \${request.method()} \${request.url()} \${request.failure()?.errorText}\`)
    })
    page.on("pageerror", error => {
      if (!setupDone) ciLog(\`page error \${error.stack ?? error.message}\`)
    })
    page.on("crash", () => ciLog("page crashed"))
    await page.goto("/", { waitUntil: "load" })
    await exposePatrolPlatformHandler(page)
    await initialise(page)
    setupDone = true
`;

try {
  const spec = path.join(process.argv[2], "tests", "test.spec.ts");
  const source = fs.readFileSync(spec, "utf8");
  if (source.includes(MARKER)) {
    console.log("web_runner diagnostics already applied");
  } else if (!source.includes(ORIGINAL)) {
    console.log("::warning::web_runner diagnostics not applied: test.spec.ts changed");
  } else {
    fs.writeFileSync(spec, source.replace(ORIGINAL, () => PATCHED));
    console.log("web_runner diagnostics applied");
  }
} catch (e) {
  console.log(`::warning::web_runner diagnostics failed: ${e.message}`);
}
