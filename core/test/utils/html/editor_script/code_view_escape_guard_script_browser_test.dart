@TestOn('chrome')

import 'dart:js_interop';

import 'package:core/utils/html/editor_script/code_view_escape_guard_script.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  late web.HTMLDivElement fixture;
  late web.Element codable;
  late web.Element editable;
  late List<String> codableKeyups;
  late List<String> editableKeyups;

  setUpAll(() {
    final scriptElement = web.HTMLScriptElement()
      ..type = 'text/javascript'
      ..text = const CodeViewEscapeGuardScript().script;
    _required(web.document.head, 'document head').append(scriptElement);
  });

  setUp(() {
    fixture = web.HTMLDivElement()
      ..className = 'note-editor'
      ..innerHTML = '''
        <div class="note-editable" contenteditable="true"></div>
        <textarea class="note-codable"></textarea>'''.toJS;
    _required(web.document.body, 'document body').append(fixture);

    codable = _required(fixture.querySelector('.note-codable'), 'codable');
    editable = _required(fixture.querySelector('.note-editable'), 'editable');
    // Stand-ins for Summernote's bubbling jQuery `keyup` handlers.
    codableKeyups = _recordKeyups(codable);
    editableKeyups = _recordKeyups(editable);
  });

  tearDown(() => fixture.remove());

  test('keeps Escape from reaching the code view textarea', () {
    _dispatchKeyup(codable, 'Escape');

    expect(codableKeyups, isEmpty);
  });

  test('lets other keys reach the code view textarea', () {
    _dispatchKeyup(codable, 'a');
    _dispatchKeyup(codable, 'Enter');

    expect(codableKeyups, ['a', 'Enter']);
  });

  test('lets Escape reach the editable outside code view', () {
    _dispatchKeyup(editable, 'Escape');

    expect(editableKeyups, ['Escape']);
  });

}

T _required<T>(T? value, String label) {
  if (value == null) throw StateError('Missing $label');
  return value;
}

List<String> _recordKeyups(web.Element target) {
  final keys = <String>[];
  target.addEventListener(
    'keyup',
    ((web.KeyboardEvent event) => keys.add(event.key)).toJS,
  );
  return keys;
}

void _dispatchKeyup(web.Element target, String key) {
  target.dispatchEvent(
    web.KeyboardEvent(
      'keyup',
      web.KeyboardEventInit(key: key, bubbles: true, cancelable: true),
    ),
  );
}
