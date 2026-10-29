// Usage: node scripts/ci-web-report-failures.js <web-results-dir>
const fs = require('fs');
const path = require('path');

function findReports(dir, reports) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch (_) {
    return;
  }
  for (const entry of entries) {
    const file = path.join(dir, entry.name);
    if (entry.isDirectory()) findReports(file, reports);
    else if (entry.isFile() && ['results.json', 'report.json'].includes(entry.name)) {
      try {
        reports.set(file, fs.statSync(file).mtimeMs);
      } catch (_) {}
    }
  }
}

const firstLine = (value) => String(value || '').replace(/\x1b\[[0-9;]*m/g, '').split(/\r?\n/)[0];

function printSuite(suite, titles = []) {
  const prefix = [...titles, suite.title].filter(Boolean);
  for (const spec of suite.specs || []) {
    for (const test of spec.tests || []) {
      const results = test.results || [];
      const final = results[results.length - 1];
      const status = final ? final.status : test.status || 'unknown';
      if ((status === 'passed' && test.status !== 'flaky') || status === 'skipped') continue;
      const error = final && (final.error || (final.errors || [])[0]);
      const message = firstLine(error && (error.message || error.value || error)).slice(0, 200);
      const title = firstLine([...prefix, spec.title].filter(Boolean).join(' > '));
      console.log(`${test.status === 'flaky' ? 'flaky' : status} ${spec.file || suite.file || '?'}:${spec.line || 0} ${title} | ${message}`);
    }
  }
  for (const child of suite.suites || []) printSuite(child, prefix);
}

try {
  const dir = process.argv[2];
  if (!dir) throw new Error('web-results-dir missing');
  const reports = new Map();
  findReports(path.resolve(dir), reports);
  // Patrol's JSON reporter writes under --web-report-dir, beside the results directory in CI.
  findReports(path.resolve(dir, '..', 'playwright-report'), reports);
  const newest = [...reports].sort((a, b) => b[1] - a[1])[0];
  if (!newest) throw new Error(`no results.json or report.json found in ${dir} or sibling playwright-report`);
  const report = JSON.parse(fs.readFileSync(newest[0], 'utf8'));
  if (!Array.isArray(report.suites) || !report.stats) throw new Error(`invalid Playwright report: ${newest[0]}`);
  for (const error of report.errors || []) console.log(`error ${firstLine(error.message || error.value || error)}`);
  for (const suite of report.suites) printSuite(suite);
  const stats = report.stats;
  const total = ['expected', 'unexpected', 'flaky', 'skipped'].reduce((sum, key) => sum + (Number(stats[key]) || 0), 0);
  console.log(`Playwright: total=${total} unexpected=${Number(stats.unexpected) || 0}`);
} catch (error) {
  console.log(`Playwright report unavailable: ${firstLine(error.message)}`);
}
process.exit(0);
