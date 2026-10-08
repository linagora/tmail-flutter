@TestOn('chrome')

import 'dart:js_interop';

import 'package:core/utils/html/editor_script/list_keyboard_handler_script.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

const _summernoteStub = r'''
  window.__listCommands = [];
  window.jQuery = function (element) {
    return {
      data: function () { return {}; },
      summernote: function (command) { window.__listCommands.push(command); },
    };
  };
''';

@JS('__listCommands')
external JSArray<JSString>? get _recordedCommands;

@JS('jQuery')
external set _jQuery(JSAny? value);

void main() {
  late web.HTMLDivElement fixture;
  late web.Element editable;
  late web.HTMLScriptElement stubElement;
  late web.HTMLScriptElement scriptElement;

  setUp(() {
    fixture = web.HTMLDivElement()
      ..innerHTML = '''
        <div id="summernote-2"></div>
        <div class="note-editor">
          <div class="note-editable" contenteditable="true">
            <ul>
              <li id="first">Item one
                <ul><li id="nested-empty"><br></li></ul>
              </li>
              <li id="second">Item two</li>
              <li id="top-empty"><br></li>
            </ul>
            <p id="paragraph">Plain text</p>
            <table><tr><td><ul><li id="in-cell">Cell item</li></ul></td></tr></table>
          </div>
        </div>'''.toJS;
    _required(web.document.body, 'document body').append(fixture);
    editable = _required(fixture.querySelector('.note-editable'), 'editable');

    stubElement = _appendScript(_summernoteStub);
    scriptElement = _appendScript(const ListKeyboardHandlerScript().script);
  });

  tearDown(() {
    scriptElement.remove();
    stubElement.remove();
    fixture.remove();
    _jQuery = null;
  });

  test('Tab inside a list item indents it', () {
    final item = _byId(editable, 'second');
    _placeCaret(item);

    final defaultPrevented = _dispatchKey(item, 'Tab');

    expect(defaultPrevented, isTrue);
    expect(_commands(), ['indent']);
  });

  test('Shift+Tab inside a list item outdents it', () {
    final item = _byId(editable, 'second');
    _placeCaret(item);

    final defaultPrevented = _dispatchKey(item, 'Tab', shiftKey: true);

    expect(defaultPrevented, isTrue);
    expect(_commands(), ['outdent']);
  });

  test('Tab on the first item of a list keeps focus without nesting it', () {
    final item = _byId(editable, 'first');
    _placeCaret(item);

    final defaultPrevented = _dispatchKey(item, 'Tab');

    expect(defaultPrevented, isTrue);
    expect(_commands(), isEmpty);
  });

  test('Shift+Tab on the first item of a list outdents it', () {
    final item = _byId(editable, 'first');
    _placeCaret(item);

    final defaultPrevented = _dispatchKey(item, 'Tab', shiftKey: true);

    expect(defaultPrevented, isTrue);
    expect(_commands(), ['outdent']);
  });

  test('Tab outside a list keeps the browser behaviour', () {
    final paragraph = _byId(editable, 'paragraph');
    _placeCaret(paragraph);

    final defaultPrevented = _dispatchKey(paragraph, 'Tab');

    expect(defaultPrevented, isFalse);
    expect(_commands(), isEmpty);
  });

  test('Tab inside a table cell list is left to the table', () {
    final item = _byId(editable, 'in-cell');
    _placeCaret(item);

    final defaultPrevented = _dispatchKey(item, 'Tab');

    expect(defaultPrevented, isFalse);
    expect(_commands(), isEmpty);
  });

  test('Enter on an empty nested list item outdents it', () {
    final item = _byId(editable, 'nested-empty');
    _placeCaret(item);

    final defaultPrevented = _dispatchKey(item, 'Enter');

    expect(defaultPrevented, isTrue);
    expect(_commands(), ['outdent']);
  });

  test('Enter on an empty top level list item keeps the editor behaviour', () {
    final item = _byId(editable, 'top-empty');
    _placeCaret(item);

    final defaultPrevented = _dispatchKey(item, 'Enter');

    expect(defaultPrevented, isFalse);
    expect(_commands(), isEmpty);
  });

  test('Enter on a non empty list item keeps the editor behaviour', () {
    final item = _byId(editable, 'second');
    _placeCaret(item);

    final defaultPrevented = _dispatchKey(item, 'Enter');

    expect(defaultPrevented, isFalse);
    expect(_commands(), isEmpty);
  });
}

web.HTMLScriptElement _appendScript(String source) {
  final element = web.HTMLScriptElement()
    ..type = 'text/javascript'
    ..text = source;
  _required(web.document.head, 'document head').append(element);
  return element;
}

web.Element _byId(web.Element parent, String id) =>
    _required(parent.querySelector('#$id'), id);

List<String> _commands() =>
    (_recordedCommands?.toDart ?? []).map((command) => command.toDart).toList();

void _placeCaret(web.Element element) {
  final range = web.document.createRange()
    ..selectNodeContents(element)
    ..collapse(true);
  final selection = _required(web.window.getSelection(), 'selection');
  selection
    ..removeAllRanges()
    ..addRange(range);
}

bool _dispatchKey(web.Element target, String key, {bool shiftKey = false}) {
  final event = web.KeyboardEvent(
    'keydown',
    web.KeyboardEventInit(
      key: key,
      shiftKey: shiftKey,
      bubbles: true,
      cancelable: true,
    ),
  );
  target.dispatchEvent(event);
  return event.defaultPrevented;
}

T _required<T extends Object>(T? value, String name) {
  if (value == null) fail('Missing $name');
  return value;
}
