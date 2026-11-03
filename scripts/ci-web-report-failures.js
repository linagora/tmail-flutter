// Usage: node scripts/ci-web-report-failures.js <web-results-dir>
const fs = require('fs');
const path = require('path');

const REPORT_NAMES = ['results.json', 'report.json'];

function readEntries(dir) {
  try {
    return fs.readdirSync(dir, { withFileTypes: true });
  } catch (_) {
    return [];
  }
}

const isReportFile = (entry) => entry.isFile() && REPORT_NAMES.includes(entry.name);

function addReport(file, reports) {
  try {
    reports.set(file, fs.statSync(file).mtimeMs);
  } catch (_) {}
}

function findReports(dir, reports) {
  for (const entry of readEntries(dir)) {
    const file = path.join(dir, entry.name);
    if (entry.isDirectory()) findReports(file, reports);
    else if (isReportFile(entry)) addReport(file, reports);
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

const errorText = (error) => firstLine(error.message || error.value || error);

function errorMessage(final) {
  const error = final && (final.error || (final.errors || [])[0]);
  return error ? errorText(error).slice(0, 200) : '';
}

const specLocation = (suite, spec) => `${spec.file || suite.file || '?'}:${spec.line || 0}`;

function printTest(suite, spec, test, prefix) {
  const results = test.results || [];
  const final = results[results.length - 1];
  const status = finalStatus(test, final);
  if (!isReported(test, status)) return;
  const title = firstLine([...prefix, spec.title].filter(Boolean).join(' > '));
  const label = test.status === 'flaky' ? 'flaky' : status;
  console.log(`${label} ${specLocation(suite, spec)} ${title} | ${errorMessage(final)}`);
}

function printSpec(suite, spec, prefix) {
  for (const test of spec.tests || []) printTest(suite, spec, test, prefix);
}

function printSuite(suite, titles = []) {
  const prefix = [...titles, suite.title].filter(Boolean);
  for (const spec of suite.specs || []) printSpec(suite, spec, prefix);
  for (const child of suite.suites || []) printSuite(child, prefix);
}

function newestFile(dir) {
  const reports = new Map();
  findReports(path.resolve(dir), reports);
  // Patrol's JSON reporter writes under --web-report-dir, beside the results directory in CI.
  findReports(path.resolve(dir, '..', 'playwright-report'), reports);
  const newest = [...reports].sort((a, b) => b[1] - a[1])[0];
  if (!newest) throw new Error(`no results.json or report.json found in ${dir} or sibling playwright-report`);
  return newest[0];
}

function loadReport(file) {
  const report = JSON.parse(fs.readFileSync(file, 'utf8'));
  if (!Array.isArray(report.suites) || !report.stats) throw new Error(`invalid Playwright report: ${file}`);
  return report;
}

function newestReport(dir) {
  if (!dir) throw new Error('web-results-dir missing');
  return loadReport(newestFile(dir));
}

const count = (stats, key) => Number(stats[key]) || 0;

function printReport(report) {
  for (const error of report.errors || []) console.log(`error ${errorText(error)}`);
  for (const suite of report.suites) printSuite(suite);
  const stats = report.stats;
  const total = ['expected', 'unexpected', 'flaky', 'skipped'].reduce((sum, key) => sum + count(stats, key), 0);
  console.log(`Playwright: total=${total} unexpected=${count(stats, 'unexpected')}`);
}

try {
  printReport(newestReport(process.argv[2]));
} catch (error) {
  console.log(`Playwright report unavailable: ${firstLine(error.message)}`);
}
process.exit(0);
