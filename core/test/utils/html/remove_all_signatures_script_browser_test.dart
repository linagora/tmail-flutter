@TestOn('chrome')

import 'dart:js_interop';

import 'package:core/utils/html/html_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  late web.HTMLDivElement fixture;

  setUp(() {
    fixture = web.HTMLDivElement();
    web.document.body!.append(fixture);
  });

  tearDown(() {
    fixture.remove();
    _runJs('delete window.jQuery;');
    web.document.body!
      ..removeAttribute('data-error')
      ..removeAttribute('data-triggers');
  });

  test('removes the top-level signature', () {
    fixture.innerHTML = '''<div class="note-editable"><p>Body</p><div class="tmail-signature">Sig</div></div>'''.toJS;

    _runRemoveAllSignatures();

    expect(_editableHtml(fixture), '<p>Body</p>');
  });

  test('removes every part of a signature the user split or nested', () {
    fixture.innerHTML = '''<div class="note-editable"><p>Body</p><div class="tmail-signature">Sig</div><div class="tmail-signature">Edited</div><div><div class="tmail-signature">Nested</div></div></div>'''.toJS;

    _runRemoveAllSignatures();

    expect(_editableHtml(fixture), '<p>Body</p><div></div>');
  });

  test('keeps signatures quoted in a blockquote or a cite', () {
    const quoted = '<blockquote><div class="tmail-signature">Quoted</div></blockquote>'
        '<cite><div class="tmail-signature">Cited</div></cite>';
    fixture.innerHTML = '''<div class="note-editable"><div class="tmail-signature">Sig</div>$quoted</div>'''.toJS;

    _runRemoveAllSignatures();

    expect(_editableHtml(fixture), quoted);
  });

  test('removes signatures in the mobile editor root', () {
    fixture.innerHTML = '''<div id="editor"><p>Body</p><div class="tmail-signature">Sig</div></div>'''.toJS;

    _runRemoveAllSignatures();

    expect(fixture.querySelector('#editor')!.innerHTML.toString(), '<p>Body</p>');
  });

  test('leaves signatures outside the editor root', () {
    fixture.innerHTML = '''<div class="tmail-signature">Outside</div><div class="note-editable"><div class="tmail-signature">Sig</div></div>'''.toJS;

    _runRemoveAllSignatures();

    expect(fixture.querySelectorAll('.tmail-signature').length, 1);
    expect(fixture.querySelector('.tmail-signature')!.textContent, 'Outside');
  });

  test('does nothing without an editor root', () {
    _installFakeJQuery();
    fixture.innerHTML = '''<div class="tmail-signature">Sig</div>'''.toJS;

    _runRemoveAllSignatures();

    expect(fixture.querySelectorAll('.tmail-signature').length, 1);
    expect(_triggers(), isEmpty);
  });

  test('notifies the web editor once with the body left after removal', () {
    _installFakeJQuery();
    fixture.innerHTML = '''<div class="note-editable"><p>Body</p><div class="tmail-signature">Sig</div></div>'''.toJS;

    _runRemoveAllSignatures();

    expect(_triggers(), ['["#summernote-2","summernote.change","<p>Body</p>"]']);
  });
}

void _runJs(String source) {
  final script = web.HTMLScriptElement()..text = source;
  web.document.head!.append(script);
  script.remove();
}

/// Records a thrown error on the body so a broken guard fails the test.
void _runRemoveAllSignatures() {
  _runJs('try {${HtmlUtils.removeAllSignatures.script}} '
      'catch (e) { document.body.dataset.error = String(e); }');
  expect(web.document.body!.getAttribute('data-error'), isNull);
}

/// Stands in for Summernote's jQuery, recording each `trigger` call.
void _installFakeJQuery() => _runJs('''
  window.jQuery = (target) => ({
    trigger: (name, args) => {
      const call = JSON.stringify([target, name, args[0]]);
      document.body.dataset.triggers = (document.body.dataset.triggers || '') + call + '\\n';
    },
  });''');

List<String> _triggers() => (web.document.body!.getAttribute('data-triggers') ?? '')
    .split('\n')
    .where((line) => line.isNotEmpty)
    .toList();

String _editableHtml(web.Element fixture) =>
    fixture.querySelector('.note-editable')!.innerHTML.toString();
