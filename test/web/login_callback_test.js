const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

const html = fs.readFileSync(path.join(__dirname, '../../web/login-callback.html'), 'utf8');
assert.match(html, /<script src="js\/login-callback\.js"><\/script>/);
assert.doesNotMatch(html, /<script>/);
const script = fs.readFileSync(path.join(__dirname, '../../web/js/login-callback.js'), 'utf8');

/** Run the callback with isolated browser state and optional injected failures. */
function callback(query, destination = 'https://mail.example/login', storageBlocked = false,
    transaction = {state: 'test-state', verifier: 'test-verifier'}, failureOperation = null) {
  const values = new Map([
    ['auth_destination_url', destination],
  ]);
  if (transaction.verifier !== null) values.set('auth_code_verifier', transaction.verifier);
  if (transaction.state !== null) values.set('auth_request_state', transaction.state);
  const redirects = [];
  const errors = [];
  function fail(operation) {
    if (failureOperation === operation) throw new Error(`sensitive callback: ${href}`);
  }
  const elements = {failure: {hidden: true}, retry: {href: '/'}};
  const href = 'https://mail.example/login-callback.html' + query;
  const location = {href, assign: url => { fail('redirect'); redirects.push(url); }, toString: () => href};
  const context = {
    URL, location,
    sessionStorage: {
      getItem: key => { fail('read-storage'); return values.get(key) ?? null; },
      setItem: (key, value) => { fail('store-response'); values.set(key, String(value)); },
      removeItem: key => {
        if (storageBlocked) throw new Error('Storage blocked');
        if (key === 'auth_destination_url') fail('remove-destination');
        values.delete(key);
      },
    },
    document: {title: 'Twake Mail', getElementById: id => elements[id]},
    console: {error: (...args) => errors.push(args)},
    window: {location},
  };
  vm.runInNewContext(script, context);
  context.window.onload();
  return {values, redirects, elements, context, errors};
}

test('successful callback preserves the response and verifier for validated exchange', () => {
  const result = callback('?code=test-code&state=test-state');
  assert.deepEqual(result.redirects, ['https://mail.example/dashboard?type=normal']);
  assert.equal(result.values.get('auth_info'), 'https://mail.example/login-callback.html?code=test-code&state=test-state');
  assert.equal(result.values.get('auth_code_verifier'), 'test-verifier');
  assert.equal(result.values.get('auth_request_state'), 'test-state');
  assert.equal(result.values.has('auth_destination_url'), false);
  assert.equal(result.elements.failure.hidden, true);
});

test('successful callback retains the root destination behavior', () => {
  assert.deepEqual(callback('?code=test-code&state=test-state', '/').redirects,
    ['/dashboard?type=normal']);
});

test('storage failure still shows an explicit retry instead of redirecting', () => {
  const result = callback('?code=test-code&state=test-state', '/', true);
  assert.deepEqual(result.redirects, []);
  assert.equal(result.values.has('auth_info'), false);
  assert.equal(result.elements.failure.hidden, false);
  assert.equal(result.elements.retry.href, 'https://mail.example/');
});

for (const query of [
  '?error=invalid_request&error_description=The%20state%20parameter%20is%20missing.',
  '?error=access_denied&code=test-code&state=test-state',
  '', '?state=test-state', '?code=test-code',
  '?code=&state=test-state', '?code=test-code&state=',
  '?code=first&code=second&state=test-state',
  '?code=test-code&state=first&state=second',
  '?code=test-code&state=wrong-state',
  '?code=test-code&state=test-state#',
  '?code=test-code&state=test-state#fragment',
]) {
  test(`failed or malformed callback stops automatic redirects: ${query}`, () => {
    const result = callback(query);
    assert.deepEqual(result.redirects, []);
    assert.equal(result.values.size, 0);
    assert.equal(result.elements.failure.hidden, false);
    assert.equal(result.elements.retry.href, 'https://mail.example/');
    assert.equal(result.context.document.title, 'Sign-in failed');
  });
}

for (const transaction of [
  {state: null, verifier: 'test-verifier'},
  {state: '', verifier: 'test-verifier'},
  {state: 'test-state', verifier: null},
  {state: 'test-state', verifier: ''},
]) {
  test(`missing pending transaction stops automatic redirects: ${JSON.stringify(transaction)}`, () => {
    const result = callback('?code=test-code&state=test-state', '/', false, transaction);
    assert.deepEqual(result.redirects, []);
    assert.equal(result.values.size, 0);
    assert.equal(result.elements.failure.hidden, false);
  });
}


test('legacy plugin without state can still return a successful code', () => {
  const result = callback('?code=test-code', '/', false,
    {state: null, verifier: 'test-verifier'});
  assert.deepEqual(result.redirects, ['/dashboard?type=normal']);
  assert.equal(result.elements.failure.hidden, true);
  assert.equal(result.values.get('auth_code_verifier'), 'test-verifier');
});

for (const operation of ['read-storage', 'remove-destination', 'store-response', 'redirect']) {
  test(`failure logs only the safe operation identifier: ${operation}`, () => {
    const result = callback('?code=test-code&state=test-state', '/', false,
      {state: 'test-state', verifier: 'test-verifier'}, operation);
    assert.deepEqual(result.redirects, []);
    assert.equal(result.values.has('auth_info'), false);
    assert.equal(result.elements.failure.hidden, false);
    assert.equal(result.elements.retry.href, 'https://mail.example/');
    assert.deepEqual(result.errors, [[`[Auth Redirect] Sign-in failed during ${operation}.`]]);
  });
}
