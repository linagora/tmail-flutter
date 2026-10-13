import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// One element that sticks out past the right edge of the email pane.
class DisplayOverflow {
  const DisplayOverflow(this.path, this.pixels);

  final String path;
  final double pixels;

  @override
  String toString() => '$path +${pixels.toStringAsFixed(1)}px';
}

/// A rendered image box with the image's intrinsic size.
class DisplayImage {
  const DisplayImage({
    required this.path,
    required this.element,
    required this.width,
    required this.height,
  });

  final String path;
  final web.HTMLImageElement element;
  final double width;
  final double height;

  int get naturalWidth => element.naturalWidth;
  int get naturalHeight => element.naturalHeight;
}

/// An email document rendered in an iframe at the email pane width, after
/// its layout scripts have settled. Holds the measurements the display
/// rules check.
class DisplayFrame {
  DisplayFrame._(this._frame, this.paneWidth);

  final web.HTMLIFrameElement _frame;
  final int paneWidth;

  static const settleTimeout = Duration(seconds: 10);
  static const _initialHeight = 400;

  /// Renders [document] at [paneWidth] and waits for layout to settle: the
  /// `load` event, then animation frames until every image is decoded and
  /// the layout is unchanged for two frames. Like the app's viewer, the frame
  /// then grows to the content height (so no vertical scrollbar narrows the
  /// pane) and settles again. Throws a [TimeoutException] naming [label] if
  /// this takes longer than [settleTimeout].
  static Future<DisplayFrame> render(
    String document,
    int paneWidth, {
    required String label,
  }) async {
    final frame = web.HTMLIFrameElement()
      ..width = '$paneWidth'
      ..height = '$_initialHeight'
      ..style.border = '0'
      ..style.display = 'block'
      ..srcdoc = document.toJS;
    final loaded = Completer<void>();
    frame.addEventListener(
      'load',
      (web.Event _) {
        if (!loaded.isCompleted) loaded.complete();
      }.toJS,
    );
    web.document.body!.append(frame);
    final display = DisplayFrame._(frame, paneWidth);
    try {
      await () async {
        await loaded.future;
        await display._settleAndGrow();
      }()
          .timeout(settleTimeout);
    } on TimeoutException {
      display.dispose();
      throw TimeoutException(
        '$label: ${loaded.isCompleted ? 'layout did not settle' : 'document did not load'}',
        settleTimeout,
      );
    } catch (_) {
      display.dispose();
      rethrow;
    }
    return display;
  }

  Future<void> _settleAndGrow() async {
    for (var round = 0; round < 5; round++) {
      await _settle();
      final height = '${document.documentElement!.scrollHeight}';
      if (_frame.height == height) return;
      _frame.height = height;
    }
  }

  Future<void> _nextFrame() {
    final completer = Completer<void>();
    _window.requestAnimationFrame(
      ((JSNumber _) => completer.complete()).toJS,
    );
    return completer.future;
  }

  String get _layoutSignature {
    final content = this.content;
    final pending = images.where((image) => !image.element.complete).length;
    return '${content.scrollWidth}x${content.scrollHeight}:$pending';
  }

  Future<void> _settle() async {
    var previous = '';
    var stableFrames = 0;
    for (var frames = 0; stableFrames < 2 || frames < 2; frames++) {
      await _nextFrame();
      final signature = _layoutSignature;
      final pending = !signature.endsWith(':0');
      stableFrames = signature == previous && !pending ? stableFrames + 1 : 0;
      previous = signature;
    }
  }

  web.Window get _window => _frame.contentWindow!;

  /// Top of the iframe in the test page's viewport, to place an element of
  /// the email relative to the top-level fold (what lazy observers watch).
  double get topInWindow => _frame.getBoundingClientRect().top.toDouble();

  web.Document get document => _frame.contentDocument!;

  web.Element get content =>
      document.getElementsByClassName('tmail-content').item(0)!;

  web.Element? query(String selector) => document.querySelector(selector);

  List<web.Element> queryAll(String selector) {
    final nodes = document.querySelectorAll(selector);
    return [for (var i = 0; i < nodes.length; i++) nodes.item(i)! as web.Element];
  }

  /// Width the email body can occupy (the pane minus the document margin).
  double get contentWidth => content.clientWidth.toDouble();

  /// Elements inside `.tmail-content` that stick out of the pane by more
  /// than [tolerance] px, on the right or (RTL) on the left. `body` is not
  /// checked: it hides horizontal overflow.
  List<DisplayOverflow> overflows({double tolerance = 1}) {
    final pane = content.getBoundingClientRect();
    final result = <DisplayOverflow>[];
    for (final element in queryAll('.tmail-content *')) {
      final rect = element.getBoundingClientRect();
      if (rect.width == 0 && rect.height == 0) continue;
      final right = rect.right - pane.right;
      final left = pane.left - rect.left;
      final past = right > left ? right : left;
      if (past > tolerance) result.add(DisplayOverflow(cssPath(element), past));
    }
    return result;
  }

  /// URLs the document fetched over http(s); must stay empty (offline).
  List<String> get remoteRequests {
    final entries = _window.performance.getEntriesByType('resource').toDart;
    return [
      for (final entry in entries)
        if (entry.name.startsWith('http')) entry.name,
    ];
  }

  /// Elements whose own content (text that cannot wrap, a `pre` line) runs
  /// past their box while their `overflow-x` is `visible`: the box fits, the
  /// text sticks out.
  List<DisplayOverflow> contentOverflows({double tolerance = 1}) => [
        for (final element in [content, ...queryAll('.tmail-content *')])
          if (element.scrollWidth > element.clientWidth + tolerance &&
              element.clientWidth > 0 &&
              computedStyle(element).overflowX == 'visible')
            DisplayOverflow(
              cssPath(element),
              (element.scrollWidth - element.clientWidth).toDouble(),
            ),
      ];

  bool get scrollsHorizontally => content.scrollWidth > content.clientWidth + 1;

  List<DisplayImage> get images => [
        for (final element in queryAll('img'))
          DisplayImage(
            path: cssPath(element),
            element: element as web.HTMLImageElement,
            width: element.getBoundingClientRect().width.toDouble(),
            height: element.getBoundingClientRect().height.toDouble(),
          ),
      ];

  web.CSSStyleDeclaration computedStyle(web.Element element) =>
      _window.getComputedStyle(element);

  /// Product of the CSS `zoom` of [element] and all its ancestors.
  double zoomOf(web.Element element) {
    var scale = 1.0;
    web.Element? current = element;
    while (current != null) {
      scale *= double.tryParse(computedStyle(current).zoom) ?? 1.0;
      current = current.parentElement;
    }
    return scale;
  }

  /// Font size as seen on screen: the computed size times every zoom.
  double renderedFontSize(web.Element element) =>
      (double.tryParse(computedStyle(element).fontSize.replaceAll('px', '')) ?? 0) *
      zoomOf(element);

  bool get hasQuoteToggle => query('.quote-toggle-button') != null;

  /// Whether the quote after the toggle button is shown; the toggle starts
  /// collapsed (`.quote-toggle-button.collapsed + blockquote` is hidden).
  bool get isQuoteExpanded {
    final quote = query('.quote-toggle-button + blockquote');
    return quote != null && computedStyle(quote).display != 'none';
  }

  Future<void> toggleQuote() async {
    (query('.quote-toggle-button')! as web.HTMLElement).click();
    await _settleAndGrow().timeout(settleTimeout);
  }

  /// Scrolls [element] into view the way the app's scrolling viewer does:
  /// the frame shrinks to the visible part of the test page (which itself
  /// cannot scroll), the email scrolls inside it, then the frame grows back.
  /// Lazy observers watch the top-level viewport, so this is what loads a
  /// lazy element. Waits up to [maxFrames] frames for it to load.
  Future<void> scrollIntoView(web.Element element, {int maxFrames = 60}) async {
    final visible = (web.window.innerHeight - topInWindow).clamp(100, double.infinity);
    _frame.height = '${visible.floor()}';
    await _nextFrame();
    element.scrollIntoView();
    for (var i = 0; i < maxFrames && element.hasAttribute('lazy'); i++) {
      await _nextFrame();
    }
    _window.scrollTo(0.toJS, 0);
    await _settleAndGrow().timeout(settleTimeout);
  }

  /// The inline value of [property] the sender wrote on [element] (the
  /// `data-sender-style` snapshot taken before the viewer scripts ran).
  String senderInlineValue(web.Element element, String property) {
    final probe = web.document.createElement('div') as web.HTMLElement
      ..setAttribute('style', element.getAttribute('data-sender-style') ?? '');
    return probe.style.getPropertyValue(property);
  }

  /// Whether a viewer script changed the inline [property] of [element].
  bool changedByScript(web.Element element, String property) =>
      (element as web.HTMLElement).style.getPropertyValue(property) !=
      senderInlineValue(element, property);

  /// Whether a viewer script rewrote [element]'s inline style at all.
  bool styleChangedByScript(web.Element element) {
    final sender = element.getAttribute('data-sender-style');
    final now = element.getAttribute('style');
    return sender == null ? (now ?? '').isNotEmpty : sender != now;
  }

  String get visibleText => (content as web.HTMLElement).innerText;

  /// `tag:nth-of-type(n)` chain from `.tmail-content` down to [element].
  String cssPath(web.Element element) {
    final parts = <String>[];
    web.Element? current = element;
    while (current != null && !current.classList.contains('tmail-content')) {
      final tag = current.localName;
      final parent = current.parentElement;
      var index = 1;
      var sameTag = 0;
      if (parent != null) {
        for (var i = 0; i < parent.children.length; i++) {
          final sibling = parent.children.item(i)!;
          if (sibling.localName != tag) continue;
          sameTag++;
          if (sibling == current) index = sameTag;
        }
      }
      parts.add(sameTag > 1 ? '$tag:nth-of-type($index)' : tag);
      current = parent;
    }
    return ['.tmail-content', ...parts.reversed].join(' > ');
  }

  void dispose() => _frame.remove();
}
