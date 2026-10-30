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

function finalStatus(test, final) {
  if (final) return final.status;
  return test.status || 'unknown';
}

// A flaky test passed on retry but is still reported.
function isReported(test, status) {
  if (status === 'skipped') return false;
  return status !== 'passed' || test.status === 'flaky';
}

function errorMessage(final) {
  if (!final) return '';
  const error = final.error || (final.errors || [])[0];
  if (!error) return '';
  return firstLine(error.message || error.value || error).slice(0, 200);
}

function printTest(suite, spec, test, prefix) {
  const results = test.results || [];
  const final = results[results.length - 1];
  const status = finalStatus(test, final);
  if (!isReported(test, status)) return;
  const title = firstLine([...prefix, spec.title].filter(Boolean).join(' > '));
  const label = test.status === 'flaky' ? 'flaky' : status;
  console.log(`${label} ${spec.file || suite.file || '?'}:${spec.line || 0} ${title} | ${errorMessage(final)}`);
}

function printSuite(suite, titles = []) {
  const prefix = [...titles, suite.title].filter(Boolean);
  for (const spec of suite.specs || []) {
    for (const test of spec.tests || []) printTest(suite, spec, test, prefix);
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
