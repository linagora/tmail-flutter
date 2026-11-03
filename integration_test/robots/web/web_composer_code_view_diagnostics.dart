import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Log-only timeline of the Embed code toggle: it adds no waits and changes no state,
/// so a timing-dependent failure keeps its timing while it is being recorded.
class WebComposerCodeViewDiagnostics {
  WebComposerCodeViewDiagnostics(this._appState);

  static const _tag = '[CODE VIEW STATE]';
  static const _markAttribute = 'data-probe-doc';

  /// Dart side of the state, e.g. `codeViewEnabled=true toggleInFlight=false`.
  final String Function() _appState;
  final _clock = Stopwatch();
  final _cleanups = <void Function()>[];
  var _nextMark = 0;

  /// Marks every editor document and watches its codeview class, iframe loads and window messages.
  void startObserving() => _safe('start', () {
        stopObserving();
        _clock
          ..reset()
          ..start();
        final iframes = web.document.querySelectorAll('iframe');
        for (var i = 0; i < iframes.length; i++) {
          _safe('observe iframe[$i]', () => _observeIframe(i, iframes.item(i) as web.HTMLIFrameElement));
        }
        final onMessage = ((web.MessageEvent event) {
          _safe('message listener', () => _log('message ${_describeMessage(event.data)}'));
        }).toJS;
        web.window.addEventListener('message', onMessage);
        _cleanups.add(() => web.window.removeEventListener('message', onMessage));
      });

  void stopObserving() {
    for (final cleanup in _cleanups) {
      _safe('cleanup', cleanup);
    }
    _cleanups.clear();
    _clock.stop();
  }

  /// One line per iframe: the web console forwarder keeps only the first line of a message.
  void dump(String when) {
    _safe('dump', () {
      _log('$when: ${_appState()}');
      final iframes = web.document.querySelectorAll('iframe');
      for (var i = 0; i < iframes.length; i++) {
        final document = (iframes.item(i) as web.HTMLIFrameElement).contentDocument;
        final textarea = document?.querySelector('textarea.note-codable') as web.HTMLTextAreaElement?;
        final box = textarea?.getBoundingClientRect();
        _log(
          'iframe[$i] of ${iframes.length}: '
          'textarea=${textarea != null} visible=${textarea?.offsetParent != null} '
          'size=${box?.width}x${box?.height} disabled=${textarea?.disabled} '
          'readOnly=${textarea?.readOnly} codeviewClass=${_isCodeView(document)} '
          'toolbarButtons=${document?.querySelectorAll('.note-toolbar button').length} '
          'probeDoc=${document?.documentElement?.getAttribute(_markAttribute) ?? 'none'}',
        );
      }
    });
  }

  void _observeIframe(int index, web.HTMLIFrameElement iframe) {
    final onLoad = ((web.Event _) => _log('iframe[$index] load')).toJS;
    iframe.addEventListener('load', onLoad);
    _cleanups.add(() => iframe.removeEventListener('load', onLoad));

    final root = iframe.contentDocument?.documentElement;
    if (root == null) {
      _log('mark iframe[$index] failed: no accessible document');
      return;
    }
    final mark = _nextMark++;
    root.setAttribute(_markAttribute, '$mark');
    var wasCodeView = _isCodeView(iframe.contentDocument);
    _log('mark iframe[$index]=$mark ok codeviewClass=$wasCodeView');

    final observer = web.MutationObserver(
      ((JSArray<web.MutationRecord> _, web.MutationObserver __) {
        _safe('class observer', () {
          final isCodeView = _isCodeView(iframe.contentDocument);
          if (isCodeView == wasCodeView) return;
          wasCodeView = isCodeView;
          _log('iframe[$index] codeviewClass=$isCodeView');
        });
      }).toJS,
    );
    observer.observe(
      root,
      web.MutationObserverInit(
        attributes: true,
        attributeFilter: ['class'.toJS].toJS,
        subtree: true,
      ),
    );
    _cleanups.add(() => observer.disconnect());
  }

  bool _isCodeView(web.Document? document) =>
      document?.querySelector('.note-editor.codeview') != null;

  String _describeMessage(JSAny? data) {
    final text = data.isA<JSString>() ? (data as JSString).toDart : '${data.runtimeType}';
    final flat = text.replaceAll(RegExp(r'\s+'), ' ');
    return flat.length <= 60 ? flat : flat.substring(0, 60);
  }

  void _log(String message) =>
      debugPrintSynchronously('$_tag t=${_clock.elapsedMilliseconds}ms $message');

  void _safe(String what, void Function() body) {
    try {
      body();
    } catch (e) {
      debugPrintSynchronously('$_tag $what failed: $e');
    }
  }
}
