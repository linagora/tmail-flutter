@TestOn('chrome')

import 'dart:js_interop';

import 'package:core/utils/html/editor_script/quoted_reply_enter_handler_script.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  late web.HTMLDivElement fixture;
  late web.HTMLDivElement editable;
  late web.HTMLParagraphElement emptyLine;
  late web.Element quote;
  late web.HTMLScriptElement scriptElement;

  setUp(() {
    fixture = web.HTMLDivElement()
      ..className = 'note-editor'
      ..innerHTML = '''
        <div class="note-editable" contenteditable="true">
          <blockquote>
            <div><img data-part="leading"></div>
            <div>
              <p><br></p>
              <p>Encrypted chat</p>
              <p><br></p>
            </div>
            <div><img data-part="trailing"></div>
          </blockquote>
        </div>'''.toJS;
    _required(web.document.body, 'document body').append(fixture);

    editable = _required(
      fixture.querySelector('.note-editable'),
      'editable',
    ) as web.HTMLDivElement;
    emptyLine = _required(fixture.querySelector('p'), 'empty line')
        as web.HTMLParagraphElement;
    quote = _required(fixture.querySelector('blockquote'), 'quote');
    scriptElement = web.HTMLScriptElement()
      ..type = 'text/javascript'
      ..text = const QuotedReplyEnterHandlerScript().script;
    _required(web.document.head, 'document head').append(scriptElement);
  });

  tearDown(() {
    scriptElement.remove();
    fixture.remove();
  });

  test('splits the quote at an empty line before following content', () async {
    final inputEvents = _observeInput(editable);
    _placeCaret(emptyLine);

    final defaultPrevented = _dispatchEnter(emptyLine);
    await _flushMicrotask();

    expect(defaultPrevented, isTrue);
    final children =
        _verifyEditableLayout(editable, ['blockquote', 'p', 'blockquote']);
    _verifyQuoteHalf(children[0], keepsAnswerText: false);
    _verifyQuoteHalf(children[2], keepsAnswerText: true);
    _verifyAnswerSelected(children[1], inputEvents);
  });

  test('exits a quote at its terminal empty paragraph', () async {
    quote.innerHTML = '''
      <div><img data-part="leading"></div>
      <div>
        <p>Encrypted chat</p>
        <p><br></p>
      </div>'''.toJS;
    emptyLine = _required(
      quote.querySelector('p:last-child'),
      'terminal empty line',
    ) as web.HTMLParagraphElement;
    final inputEvents = _observeInput(editable);
    _placeCaret(emptyLine);

    final defaultPrevented = _dispatchEnter(emptyLine);
    await _flushMicrotask();

    expect(defaultPrevented, isTrue);
    final children = _verifyEditableLayout(editable, ['blockquote', 'p']);
    _verifyQuoteHalf(children[0], keepsAnswerText: true);
    _verifyAnswerSelected(children[1], inputEvents);
  });

  test('preserves a following blank line in the trailing quote', () async {
    _setQuoteContent(
      quote,
      '<div><p><br></p><p><br></p><p>Encrypted chat</p></div>',
    );
    final firstEmptyLine =
        _required(quote.querySelector('p'), 'first empty line');
    final inputEvents = _observeInput(editable);
    _placeCaret(firstEmptyLine);

    final defaultPrevented = _dispatchEnter(firstEmptyLine);
    await _flushMicrotask();

    expect(defaultPrevented, isTrue);
    final children =
        _verifyEditableLayout(editable, ['blockquote', 'p', 'blockquote']);
    final trailingLines = children[2].querySelectorAll('p');
    expect(trailingLines.length, 2);
    expect(
      (trailingLines.item(0) as web.Element?)?.querySelector('br'),
      isNotNull,
    );
    _verifyAnswerSelected(children[1], inputEvents);
  });

  for (final splitCase in _leadingBreakSplitCases) {
    test('splits ${splitCase.label}', () async {
      _setQuoteContent(quote, splitCase.content);
      final block = _required(
        quote.querySelector(splitCase.targetSelector),
        splitCase.label,
      );
      final inputEvents = _observeInput(editable);
      splitCase.placeCaret(block);

      final defaultPrevented = _dispatchEnter(block);
      await _flushMicrotask();

      expect(defaultPrevented, isTrue);
      _verifyLeadingBreakSplit(
        editable,
        inputEvents,
        blockSelector: splitCase.blockSelector,
      );
    });
  }

  test('preserves a non-editable widget after the split', () async {
    _setQuoteContent(
      quote,
      '<p><span contenteditable="false" data-widget="card"></span>Settings -&gt; Devices</p>',
    );
    final lineWithWidget = _required(quote.querySelector('p'), 'line with widget');
    final inputEvents = _observeInput(editable);
    _placeCaret(lineWithWidget);

    final defaultPrevented = _dispatchEnter(lineWithWidget);
    await _flushMicrotask();

    expect(defaultPrevented, isTrue);
    final children =
        _verifyEditableLayout(editable, ['blockquote', 'p', 'blockquote']);
    expect(
      children[2].querySelector('[data-widget="card"]'),
      isNotNull,
    );
    expect(children[2].textContent, contains('Settings -> Devices'));
    _verifyAnswerSelected(children[1], inputEvents);
  });

  test('exits the outermost nested quote', () async {
    quote.innerHTML = '''
      <div><img data-part="leading"></div>
      <blockquote><p><br></p><p>Nested content</p></blockquote>
      <div>Outer trailing content</div>'''.toJS;
    emptyLine = _required(quote.querySelector('p'), 'nested empty line')
        as web.HTMLParagraphElement;
    final inputEvents = _observeInput(editable);
    _placeCaret(emptyLine);

    final defaultPrevented = _dispatchEnter(emptyLine);
    await _flushMicrotask();

    expect(defaultPrevented, isTrue);
    final children =
        _verifyEditableLayout(editable, ['blockquote', 'p', 'blockquote']);
    expect(children[0].querySelector('img'), isNotNull);
    expect(children[2].textContent, contains('Nested content'));
    expect(children[2].textContent, contains('Outer trailing content'));
    _verifyAnswerSelected(children[1], inputEvents);
  });

  for (final delegatedCase in _delegatedEnterCases) {
    test('keeps ${delegatedCase.label} untouched', () async {
      final htmlBefore = _editableHtml(editable);
      _placeCaret(emptyLine);

      final defaultPrevented = _dispatchEnter(
        emptyLine,
        modifiers: delegatedCase.modifiers,
        isComposing: delegatedCase.isComposing,
      );
      await _flushMicrotask();

      expect(defaultPrevented, isFalse);
      expect(_editableHtml(editable), htmlBefore);
    });
  }

  test('synchronizes through Summernote when jQuery is available', () async {
    _installSummernoteSource(fixture);
    _installSummernoteStub(initialized: true);
    final inputEvents = _observeInput(editable);
    _placeCaret(emptyLine);

    final defaultPrevented = _dispatchEnter(emptyLine);
    await _flushMicrotask();

    expect(defaultPrevented, isTrue);
    expect(
      (
        source: fixture.getAttribute('data-summernote-source'),
        command: fixture.getAttribute('data-summernote-command'),
      ),
      (source: _summernoteSourceId, command: 'editor.afterCommand'),
    );
    expect(inputEvents.count, 0);
  });

  test('falls back to an input event when Summernote is not initialized',
      () async {
    _installSummernoteSource(fixture);
    _installSummernoteStub(initialized: false);
    final inputEvents = _observeInput(editable);
    _placeCaret(emptyLine);

    final defaultPrevented = _dispatchEnter(emptyLine);
    await _flushMicrotask();

    expect(defaultPrevented, isTrue);
    expect(fixture.getAttribute('data-summernote-command'), isNull);
    expect(inputEvents.count, 1);
  });

  test('handles Enter once when the handler script is injected twice', () async {
    final duplicateScript = web.HTMLScriptElement()
      ..type = 'text/javascript'
      ..text = const QuotedReplyEnterHandlerScript().script;
    _required(web.document.head, 'document head').append(duplicateScript);
    addTearDown(() => duplicateScript.remove());
    final inputEvents = _observeInput(editable);
    _placeCaret(emptyLine);

    _dispatchEnter(emptyLine);
    await _flushMicrotask();

    final children =
        _verifyEditableLayout(editable, ['blockquote', 'p', 'blockquote']);
    _verifyAnswerSelected(children[1], inputEvents);
  });

  for (final domCase in _delegatedDomCases) {
    test('leaves ${domCase.label} to the editor', () async {
      final target = domCase.prepare(editable, quote);
      final htmlBefore = _editableHtml(editable);
      domCase.placeCaret(target);

      final defaultPrevented = _dispatchEnter(target);
      await _flushMicrotask();

      expect(defaultPrevented, isFalse);
      expect(_editableHtml(editable), htmlBefore);
    });
  }

  test('inserts a fallback line when the quote changes before the microtask', () async {
    final abortController = web.AbortController();
    final removeQuote = ((web.Event _) => quote.remove()).toJS;

    editable.addEventListener(
      'keydown',
      removeQuote,
      web.AddEventListenerOptions(signal: abortController.signal),
    );
    addTearDown(() => abortController.abort());
    _placeCaret(emptyLine);

    _dispatchEnter(emptyLine);
    await _flushMicrotask();

    final children = _verifyEditableLayout(editable, ['p']);
    expect(_selectionAnchorNode(), same(children[0]));
  });
}

typedef _RangePosition = void Function(web.Range range);

void _setCaret(_RangePosition position, {bool toStart = true}) {
  final range = web.document.createRange();
  position(range);
  range.collapse(toStart);
  final selection = _required(web.window.getSelection(), 'selection');
  selection.removeAllRanges();
  selection.addRange(range);
}

void _placeCaret(web.Element block) =>
    _setCaret((range) => range.setStart(block, 0));

void _placeCaretBeforeLeadingBreak(web.Element block) => _setCaret(
  (range) => range.setStartBefore(
    _required(block.querySelector('br'), 'leading break'),
  ),
);

void _placeCaretAfterLeadingBreak(web.Element block) => _setCaret(
  (range) => range.setStartAfter(
    _required(block.querySelector('br'), 'leading break'),
  ),
);

void _placeCaretAfterFirstCharacter(web.Element block) => _setCaret(
  (range) => range.setStart(_required(block.firstChild, 'first text'), 1),
);

void _placeCaretAtEnd(web.Element block) =>
    _setCaret((range) => range.selectNodeContents(block), toStart: false);

void _setQuoteContent(web.Element quote, String content) {
  quote.innerHTML = '''
    <div><img data-part="leading"></div>
    $content
    <div><img data-part="trailing"></div>'''.toJS;
}

web.Node? _selectionAnchorNode() => web.window.getSelection()?.anchorNode;

List<web.Element> _verifyEditableLayout(
  web.HTMLDivElement editable,
  List<String> expectedLocalNames,
) {
  final children = [
    for (var i = 0; i < editable.children.length; i++)
      _required(editable.children.item(i), 'editable child $i'),
  ];
  expect(
    children.map((child) => child.localName),
    orderedEquals(expectedLocalNames),
  );
  return children;
}

void _verifyQuoteHalf(web.Element quoteHalf, {required bool keepsAnswerText}) {
  expect(quoteHalf.querySelector('img'), isNotNull);
  expect(
    quoteHalf.textContent,
    keepsAnswerText
        ? contains('Encrypted chat')
        : isNot(contains('Encrypted chat')),
  );
}

void _verifyLeadingBreakSplit(
  web.HTMLDivElement editable,
  _InputEvents inputEvents, {
  String blockSelector = 'p',
}) {
  final children =
      _verifyEditableLayout(editable, ['blockquote', 'p', 'blockquote']);
  expect(children[0].querySelector('img'), isNotNull);
  expect(children[2].querySelector('img'), isNotNull);
  expect(children[2].textContent, contains('Settings -> Devices'));
  expect(children[2].querySelector(blockSelector)?.querySelector('br'), isNull);
  _verifyAnswerSelected(children[1], inputEvents);
}

void _verifyAnswerSelected(web.Element answer, _InputEvents inputEvents) {
  expect(_selectionAnchorNode(), same(answer));
  expect(inputEvents.count, 1);
}

String _editableHtml(web.Element editable) =>
    (editable.innerHTML as JSString).toDart;

const String _summernoteSourceId = 'summernote-source';

void _installSummernoteSource(web.Element fixture) {
  final source = web.HTMLDivElement()..id = _summernoteSourceId;
  fixture.before(source);
  addTearDown(() => source.remove());
}

void _installSummernoteStub({required bool initialized}) {
  final summernoteStub = web.HTMLScriptElement()
    ..type = 'text/javascript'
    ..text = '''
      window.__previousJQuery = window.jQuery;
      window.jQuery = function (source) {
        const recorder = document.querySelector('.note-editor');
        if (recorder && source && source.id) {
          recorder.setAttribute('data-summernote-source', source.id);
        }
        return {
          summernote: function (command) {
            if (recorder) recorder.setAttribute('data-summernote-command', command);
          },
          data: function (key) {
            return key === 'summernote' && $initialized ? {} : undefined;
          }
        };
      };''';
  _required(web.document.head, 'document head').append(summernoteStub);
  addTearDown(() {
    summernoteStub.remove();
    final cleanup = web.HTMLScriptElement()
      ..type = 'text/javascript'
      ..text = '''
        if (window.__previousJQuery === undefined) {
          delete window.jQuery;
        } else {
          window.jQuery = window.__previousJQuery;
        }
        delete window.__previousJQuery;''';
    _required(web.document.head, 'document head').append(cleanup);
    cleanup.remove();
  });
}

_InputEvents _observeInput(web.Element target) {
  final events = _InputEvents();
  final abortController = web.AbortController();
  target.addEventListener(
    'input',
    ((web.Event _) => events.count++).toJS,
    web.AddEventListenerOptions(signal: abortController.signal),
  );
  addTearDown(() => abortController.abort());
  return events;
}

final class _InputEvents {
  var count = 0;
}

T _required<T>(T? value, String label) {
  if (value == null) throw StateError('Missing $label');
  return value;
}

Future<void> _flushMicrotask() => Future<void>.delayed(Duration.zero);

typedef _EnterModifiers = ({
  bool shiftKey,
  bool altKey,
  bool ctrlKey,
  bool metaKey,
});

typedef _DelegatedEnterCase = ({
  String label,
  _EnterModifiers modifiers,
  bool isComposing,
});

typedef _CaretPlacement = void Function(web.Element block);

typedef _SplitCase = ({
  String label,
  String content,
  String targetSelector,
  String blockSelector,
  _CaretPlacement placeCaret,
});

const _EnterModifiers _noModifiers =
    (shiftKey: false, altKey: false, ctrlKey: false, metaKey: false);

const List<_DelegatedEnterCase> _delegatedEnterCases = [
  (
    label: 'Shift+Enter',
    modifiers: (shiftKey: true, altKey: false, ctrlKey: false, metaKey: false),
    isComposing: false,
  ),
  (
    label: 'Alt+Enter',
    modifiers: (shiftKey: false, altKey: true, ctrlKey: false, metaKey: false),
    isComposing: false,
  ),
  (
    label: 'Ctrl+Enter',
    modifiers: (shiftKey: false, altKey: false, ctrlKey: true, metaKey: false),
    isComposing: false,
  ),
  (
    label: 'Meta+Enter',
    modifiers: (shiftKey: false, altKey: false, ctrlKey: false, metaKey: true),
    isComposing: false,
  ),
  (label: 'composing Enter', modifiers: _noModifiers, isComposing: true),
];

typedef _DomSetup = web.Element Function(
  web.HTMLDivElement editable,
  web.Element quote,
);

typedef _DelegatedDomCase = ({
  String label,
  _DomSetup prepare,
  _CaretPlacement placeCaret,
});

final List<_DelegatedDomCase> _delegatedDomCases = [
  (
    label: 'Enter after content in a quoted paragraph',
    prepare: (editable, quote) =>
        _required(quote.querySelector('p:nth-child(2)'), 'content line'),
    placeCaret: _placeCaretAtEnd,
  ),
  (
    label: 'Enter outside a quote',
    prepare: (editable, quote) {
      final outsideLine = web.HTMLParagraphElement()..innerHTML = '<br>'.toJS;
      editable.append(outsideLine);
      return outsideLine;
    },
    placeCaret: _placeCaret,
  ),
  (
    label: 'Enter in a quoted table cell',
    prepare: (editable, quote) {
      _setQuoteContent(
        quote,
        '<table><tbody><tr><td><br>&nbsp;Settings -&gt; Devices&nbsp;</td></tr></tbody></table>',
      );
      return _required(quote.querySelector('td'), 'table cell');
    },
    placeCaret: _placeCaretBeforeLeadingBreak,
  ),
  (
    label: 'Enter in a paragraph inside a quoted table cell',
    prepare: (editable, quote) {
      _setQuoteContent(
        quote,
        '<table><tbody><tr><td><p><br></p><p>Cell text</p></td></tr></tbody></table>',
      );
      return _required(quote.querySelector('td p'), 'cell paragraph');
    },
    placeCaret: _placeCaret,
  ),
];

const String _styledLeadingBreakLines = '''<div>
      <p style="margin-top: 1.05pt; margin-bottom: 0pt; margin-left: .01in"><span style="color: rgb(14, 34, 66); letter-spacing: -0.1pt"><font style="font-size: 16px"><br></font></span>&nbsp;Settings -&gt; Devices&nbsp;</p>
      <p style="margin-top: 1.05pt; margin-bottom: 0pt; margin-left: .01in"><br></p>
    </div>''';

const List<_SplitCase> _leadingBreakSplitCases = [
  (
    label: 'a styled paragraph before its leading line break',
    content: _styledLeadingBreakLines,
    targetSelector: 'p',
    blockSelector: 'p',
    placeCaret: _placeCaretBeforeLeadingBreak,
  ),
  (
    label: 'a styled paragraph after its leading line break',
    content: _styledLeadingBreakLines,
    targetSelector: 'p',
    blockSelector: 'p',
    placeCaret: _placeCaretAfterLeadingBreak,
  ),
  (
    label: 'a direct div before text after a leading line break',
    content: '<div><br>&nbsp;Settings -&gt; Devices&nbsp;</div>',
    targetSelector: 'div:nth-child(2)',
    blockSelector: 'div',
    placeCaret: _placeCaretBeforeLeadingBreak,
  ),
  (
    label: 'a list item before text after a leading line break',
    content:
        '<ul><li><br>&nbsp;Settings -&gt; Devices&nbsp;</li><li>Next item</li></ul>',
    targetSelector: 'li',
    blockSelector: 'li',
    placeCaret: _placeCaretBeforeLeadingBreak,
  ),
  (
    label: 'a heading before text after a leading line break',
    content: '<h2><br>&nbsp;Settings -&gt; Devices&nbsp;</h2>',
    targetSelector: 'h2',
    blockSelector: 'h2',
    placeCaret: _placeCaretBeforeLeadingBreak,
  ),
  (
    label: 'a line with multiple leading line breaks',
    content: '<p><br><br>&nbsp;Settings -&gt; Devices&nbsp;</p>',
    targetSelector: 'p',
    blockSelector: 'p',
    placeCaret: _placeCaretBeforeLeadingBreak,
  ),
  (
    label: 'a line with an invisible text prefix',
    content: '<p>\u2060Settings -&gt; Devices</p>',
    targetSelector: 'p',
    blockSelector: 'p',
    placeCaret: _placeCaretAfterFirstCharacter,
  ),
  (
    label: 'a line with an empty anchor line break',
    content: '<p><a href="#"><br></a>&nbsp;Settings -&gt; Devices&nbsp;</p>',
    targetSelector: 'p',
    blockSelector: 'p',
    placeCaret: _placeCaretBeforeLeadingBreak,
  ),
];

bool _dispatchEnter(
  web.Element target, {
  _EnterModifiers modifiers = _noModifiers,
  bool isComposing = false,
}) {
  final event = web.KeyboardEvent(
    'keydown',
    web.KeyboardEventInit(
      key: 'Enter',
      bubbles: true,
      cancelable: true,
      shiftKey: modifiers.shiftKey,
      altKey: modifiers.altKey,
      ctrlKey: modifiers.ctrlKey,
      metaKey: modifiers.metaKey,
      isComposing: isComposing,
    ),
  );
  target.dispatchEvent(event);
  return event.defaultPrevented;
}
