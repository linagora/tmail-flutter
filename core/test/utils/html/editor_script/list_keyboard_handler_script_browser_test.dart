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

const _uninitializedSummernoteStub = r'''
  window.jQuery = function (element) {
    return {
      data: function () { return undefined; },
      summernote: function (command) { window.__listCommands.push(command); },
    };
  };
''';

const _failingSummernoteStub = r'''
  window.jQuery = function (element) {
    return {
      data: function () { return {}; },
      summernote: function () { throw new Error('command failed'); },
    };
  };
''';

const _consoleErrorSpy = r'''
  window.__loggedErrors = [];
  window.__originalConsoleError = console.error;
  console.error = function (message) {
    window.__loggedErrors.push(String(message));
  };
''';

const _consoleErrorRestore = r'''
  console.error = window.__originalConsoleError;
  delete window.__originalConsoleError;
  delete window.__loggedErrors;
''';

@JS('__listCommands')
external JSArray<JSString>? get _recordedCommands;

@JS('__loggedErrors')
external JSArray<JSString>? get _recordedErrors;

@JS('jQuery')
external set _jQuery(JSAny? value);

void main() {
  late web.HTMLDivElement fixture;
  late web.Element editable;
  late web.HTMLScriptElement stubElement;
  late web.HTMLScriptElement scriptElement;
  late web.HTMLScriptElement consoleSpyElement;

  setUp(() {
    fixture = web.HTMLDivElement()
      ..innerHTML = '''
        <div id="summernote-2"></div>
        <div class="note-editor">
          <div class="note-editable" contenteditable="true">
            <ul>
              <li id="first">Item one
                <ul>
                  <li id="nested-empty"><br></li>
                  <li id="nested-wrapper"><ul><li><br></li></ul></li>
                  <li id="nested-image"><img alt=""></li>
                  <li id="nested-zero-width">&#8203;&#8204;&#8205;&#8288;&#65279;</li>
                </ul>
              </li>
              <li id="second">Item two</li>
              <li id="top-empty"><br></li>
            </ul>
            <p id="paragraph">Plain text</p>
            <table><tr><td><ul><li id="in-cell">Cell item</li></ul></td></tr></table>
            <ul><ul><li id="list-in-list"><br></li></ul></ul>
            <ol><ul><li id="list-in-ordered-list"><br></li></ul></ol>
          </div>
        </div>'''.toJS;
    _required(web.document.body, 'document body').append(fixture);
    editable = _required(fixture.querySelector('.note-editable'), 'editable');

    consoleSpyElement = _appendScript(_consoleErrorSpy);
    stubElement = _appendScript(_summernoteStub);
    scriptElement = _appendScript(const ListKeyboardHandlerScript().script);
  });

  tearDown(() {
    scriptElement.remove();
    stubElement.remove();
    fixture.remove();
    _jQuery = null;
    consoleSpyElement.remove();
    _appendScript(_consoleErrorRestore).remove();
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

  for (final delegatedCase in _delegatedKeyCases) {
    test('keeps ${delegatedCase.label} untouched', () {
      final item = _byId(editable, delegatedCase.itemId);
      _placeCaret(item);

      final defaultPrevented = _dispatchKeyStroke(item, delegatedCase.stroke);

      expect(defaultPrevented, isFalse);
      expect(_commands(), isEmpty);
    });
  }

  test('Tab already handled by an earlier listener is left alone', () {
    final abortController = web.AbortController();
    fixture.addEventListener(
      'keydown',
      ((web.Event event) => event.preventDefault()).toJS,
      web.AddEventListenerOptions(
        capture: true,
        signal: abortController.signal,
      ),
    );
    addTearDown(() => abortController.abort());
    final item = _byId(editable, 'second');
    _placeCaret(item);

    _dispatchKey(item, 'Tab');

    expect(_commands(), isEmpty);
  });

  test('injecting the script twice runs the command once', () {
    _appendScriptUntilTearDown(const ListKeyboardHandlerScript().script);
    final item = _byId(editable, 'second');
    _placeCaret(item);

    _dispatchKey(item, 'Tab');

    expect(_commands(), ['indent']);
  });

  test('Enter without a selection keeps the editor behaviour', () {
    final item = _byId(editable, 'nested-empty');
    _required(web.window.getSelection(), 'selection').removeAllRanges();

    final defaultPrevented = _dispatchKey(item, 'Enter');

    expect(defaultPrevented, isFalse);
    expect(_commands(), isEmpty);
    expect(_loggedErrors(), isEmpty);
  });

  test('Enter over a selected empty nested item keeps the editor behaviour', () {
    final item = _byId(editable, 'nested-empty');
    _selectContents(item);

    final defaultPrevented = _dispatchKey(item, 'Enter');

    expect(defaultPrevented, isFalse);
    expect(_commands(), isEmpty);
  });

  test('Enter outside a list keeps the editor behaviour', () {
    final paragraph = _byId(editable, 'paragraph');
    _placeCaret(paragraph);

    final defaultPrevented = _dispatchKey(paragraph, 'Enter');

    expect(defaultPrevented, isFalse);
    expect(_commands(), isEmpty);
    expect(_loggedErrors(), isEmpty);
  });

  for (final itemId in ['nested-wrapper', 'nested-image']) {
    test('Enter on the nested item "$itemId" keeps the editor behaviour', () {
      final item = _byId(editable, itemId);
      _placeCaret(item);

      final defaultPrevented = _dispatchKey(item, 'Enter');

      expect(defaultPrevented, isFalse);
      expect(_commands(), isEmpty);
    });
  }

  for (final itemId in [
    'nested-zero-width',
    'list-in-list',
    'list-in-ordered-list',
  ]) {
    test('Enter on the empty nested item "$itemId" outdents it', () {
      final item = _byId(editable, itemId);
      _placeCaret(item);

      final defaultPrevented = _dispatchKey(item, 'Enter');

      expect(defaultPrevented, isTrue);
      expect(_commands(), ['outdent']);
    });
  }

  test('Tab without Summernote keeps the browser behaviour', () {
    _jQuery = null;
    final item = _byId(editable, 'second');
    _placeCaret(item);

    final defaultPrevented = _dispatchKey(item, 'Tab');

    expect(defaultPrevented, isFalse);
    expect(_loggedErrors(), isEmpty);
  });

  test('Tab before Summernote is initialized keeps the browser behaviour', () {
    _appendScriptUntilTearDown(_uninitializedSummernoteStub);
    final item = _byId(editable, 'second');
    _placeCaret(item);

    final defaultPrevented = _dispatchKey(item, 'Tab');

    expect(defaultPrevented, isFalse);
    expect(_commands(), isEmpty);
  });

  test('a failing Summernote command is logged with its name', () {
    _appendScriptUntilTearDown(_failingSummernoteStub);
    final item = _byId(editable, 'second');
    _placeCaret(item);

    final defaultPrevented = _dispatchKey(item, 'Tab');

    expect(defaultPrevented, isTrue);
    expect(
      _loggedErrors(),
      ['[TwakeMail][ListKeyboardHandler] indent command failed'],
    );
  });
}

typedef _KeyStroke = ({
  String key,
  bool shiftKey,
  bool altKey,
  bool ctrlKey,
  bool metaKey,
  bool isComposing,
});

typedef _DelegatedKeyCase = ({
  String label,
  String itemId,
  _KeyStroke stroke,
});

const List<_DelegatedKeyCase> _delegatedKeyCases = [
  (
    label: 'Alt+Tab',
    itemId: 'second',
    stroke: (
      key: 'Tab',
      shiftKey: false,
      altKey: true,
      ctrlKey: false,
      metaKey: false,
      isComposing: false,
    ),
  ),
  (
    label: 'Ctrl+Tab',
    itemId: 'second',
    stroke: (
      key: 'Tab',
      shiftKey: false,
      altKey: false,
      ctrlKey: true,
      metaKey: false,
      isComposing: false,
    ),
  ),
  (
    label: 'Meta+Tab',
    itemId: 'second',
    stroke: (
      key: 'Tab',
      shiftKey: false,
      altKey: false,
      ctrlKey: false,
      metaKey: true,
      isComposing: false,
    ),
  ),
  (
    label: 'composing Tab',
    itemId: 'second',
    stroke: (
      key: 'Tab',
      shiftKey: false,
      altKey: false,
      ctrlKey: false,
      metaKey: false,
      isComposing: true,
    ),
  ),
  (
    label: 'Shift+Enter on an empty nested item',
    itemId: 'nested-empty',
    stroke: (
      key: 'Enter',
      shiftKey: true,
      altKey: false,
      ctrlKey: false,
      metaKey: false,
      isComposing: false,
    ),
  ),
];

web.HTMLScriptElement _appendScript(String source) {
  final element = web.HTMLScriptElement()
    ..type = 'text/javascript'
    ..text = source;
  _required(web.document.head, 'document head').append(element);
  return element;
}

void _appendScriptUntilTearDown(String source) {
  final element = _appendScript(source);
  addTearDown(() => element.remove());
}

web.Element _byId(web.Element parent, String id) =>
    _required(parent.querySelector('#$id'), id);

List<String> _commands() =>
    (_recordedCommands?.toDart ?? []).map((command) => command.toDart).toList();

List<String> _loggedErrors() =>
    (_recordedErrors?.toDart ?? []).map((error) => error.toDart).toList();

void _placeCaret(web.Element element) {
  final range = web.document.createRange()
    ..selectNodeContents(element)
    ..collapse(true);
  final selection = _required(web.window.getSelection(), 'selection');
  selection
    ..removeAllRanges()
    ..addRange(range);
}

void _selectContents(web.Element element) {
  final range = web.document.createRange()..selectNodeContents(element);
  final selection = _required(web.window.getSelection(), 'selection');
  selection
    ..removeAllRanges()
    ..addRange(range);
}

bool _dispatchKey(web.Element target, String key, {bool shiftKey = false}) =>
    _dispatchKeyStroke(
      target,
      (
        key: key,
        shiftKey: shiftKey,
        altKey: false,
        ctrlKey: false,
        metaKey: false,
        isComposing: false,
      ),
    );

bool _dispatchKeyStroke(web.Element target, _KeyStroke stroke) {
  final event = web.KeyboardEvent(
    'keydown',
    web.KeyboardEventInit(
      key: stroke.key,
      shiftKey: stroke.shiftKey,
      altKey: stroke.altKey,
      ctrlKey: stroke.ctrlKey,
      metaKey: stroke.metaKey,
      isComposing: stroke.isComposing,
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
