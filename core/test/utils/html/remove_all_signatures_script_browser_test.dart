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

  test('removes signatures from the code view HTML and notifies the code view', () {
    _installFakeJQuery(codeView: true);
    fixture.innerHTML = '''<div class="note-editable"><p>Old</p><div class="tmail-signature">Sig</div></div><textarea class="note-codable"></textarea>'''.toJS;
    _codable(fixture).value = '<p>Edited</p><div class="tmail-signature">Sig</div>';

    _runRemoveAllSignatures();

    expect(_codable(fixture).value, '<p>Edited</p>');
    expect(_editableHtml(fixture), '<p>Old</p><div class="tmail-signature">Sig</div>');
    expect(_triggers(), ['["#summernote-2","summernote.change.codeview","<p>Edited</p>"]']);
  });

  test('keeps quoted signatures in the code view HTML', () {
    _installFakeJQuery(codeView: true);
    const quoted = '<blockquote><div class="tmail-signature">Q</div></blockquote>';
    fixture.innerHTML = '''<div class="note-editable"></div><textarea class="note-codable"></textarea>'''.toJS;
    _codable(fixture).value = quoted;

    _runRemoveAllSignatures();

    expect(_codable(fixture).value, quoted);
    expect(_triggers(), isEmpty);
  });

  test('uses the visual editor when code view is off', () {
    _installFakeJQuery();
    fixture.innerHTML = '''<div class="note-editable"><p>Body</p><div class="tmail-signature">Sig</div></div><textarea class="note-codable"></textarea>'''.toJS;
    _codable(fixture).value = '<div class="tmail-signature">Raw</div>';

    _runRemoveAllSignatures();

    expect(_editableHtml(fixture), '<p>Body</p>');
    expect(_codable(fixture).value, '<div class="tmail-signature">Raw</div>');
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
void _installFakeJQuery({bool codeView = false}) => _runJs('''
  window.jQuery = (target) => ({
    summernote: (cmd) => cmd === 'codeview.isActivated' && $codeView,
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

web.HTMLTextAreaElement _codable(web.Element fixture) =>
    fixture.querySelector('.note-codable')! as web.HTMLTextAreaElement;
