# 93. postMessage Handshake for Drive Intent WebView

Date: 2026-05-29

## Status

Accepted

## Context

Step 5 of [ADR-0092](0092-external-drive-file-picker-integration.md). Bidirectional `postMessage` handshake between the drive app (in WebView) and Flutter host.

Platform split: on **mobile/tablet** `window.parent === window` (native WebView, no cross-frame boundary) — a shim is required. On **web** Flutter's `HtmlIframeWidget` renders an `<iframe>` — standard cross-frame `postMessage` applies, no shim.

## Decision

### 1. Protocol Sequence

| Step | Direction | `type` | Notes |
|------|-----------|--------|-------|
| 1 | Service → Client | `intent-{id}:ready` | |
| 2 | Client → Service | *(none)* | Empty `{}` — PICK has no filter. **Mandatory** — must be sent even when there is no filter data |
| 3 | Service → Client | `intent-{id}:done` \| `:error` \| `:cancel` | `done` carries `{ "document": [...] }` |

Only messages prefixed `intent-{id}:` are processed (`{id}` from `POST /intents` response).

### 2. Mobile / Tablet — `window.parent` Shim

**Inject shim via `UserScript` at `AT_DOCUMENT_START`** (before any page JS runs). The shim source lives in `DriveIntentShims` (a `final abstract class` with no instances):

```dart
// workplace/lib/presentation/mixin/drive_intent_shims.dart
abstract final class DriveIntentShims {
  static const String handlerName = 'driveIntentMessage';

  // The shim forwards `targetOrigin` as the second arg to the Flutter handler.
  // Mobile WebViews have no browser-stamped origin; targetOrigin is a best-effort
  // hint. Origin checking on mobile is inherently weaker — mitigation is that
  // we only open URLs from trusted/validated sources.
  static String get parentPostMessageShim => '''
    window.parent = {
      postMessage: function(data, targetOrigin) {
        window.flutter_inappwebview.callHandler(
          '$handlerName',
          typeof data === 'string' ? data : JSON.stringify(data),
          targetOrigin
        );
      }
    };
    ''';
}
```

**Dart — receive** (in `InAppWebView.onWebViewCreated`):
```dart
controller.addJavaScriptHandler(
  handlerName: DriveIntentShims.handlerName,
  callback: (args) => onMessage(
    raw: args[0] as String,
    origin: args.length > 1 ? args[1] as String? : null,
  ),
);
```

**Dart — send ack back:**
```dart
@override
void sendAck() {
  final payload = jsonEncode({});
  _webViewController?.evaluateJavascript(source: '''
    window.dispatchEvent(new MessageEvent('message', {
      data: '$payload',
      origin: '$_intentOrigin',
      source: window
    }));
  ''');
}
```

**Data URI origin edge case:** when the intent URL is a `data:` URI (used by `DriveIntentFakePage` in development), the WebView's origin is opaque `'null'`. The fake page sends `postMessage(..., '*')`, so `targetOrigin` arrives as `'*'`. `_isValidOrigin` in `DriveIntentMessageHandlerMixin` handles this:

```dart
bool _isValidOrigin(String? origin) {
  if (origin == null) return false;
  if (origin == _intentOrigin) return true;
  // data: URIs have opaque 'null' origin; shim receives '*' from postMessage.
  return _intentOrigin == 'null' && origin == '*';
}
```

### 3. Web — `window.addEventListener`

No shim. The listener is registered **once when the composer opens** (not at modal open), via `DrivePickerWebStateMixin`. This ensures the handler is ready before any iframe interaction begins.

Use `addEventListener` — never `window.onmessage =`. `WebEditorWidget` already registers its own `message` listener via `addEventListener`; property assignment would overwrite that handler and break the rich-text editor.

**`DrivePickerWebStateMixin`** (composer-level, registers on `initState`, removes on `dispose`):
```dart
mixin DrivePickerWebStateMixin<T extends StatefulWidget>
    on State<T>, DrivePickerStateMixin<T>, WebWindowMessageMixin<T> {
  void Function(String raw, String? origin)? _webModalHandler;

  @override
  void initState() {
    super.initState();
    startWindowMessageListener((data, origin) => _webModalHandler?.call(data, origin));
  }

  @override
  void dispose() {
    stopWindowMessageListener();
    super.dispose();
  }
}
```

**`WebWindowMessageMixin`** (guards for `MessageEvent` and `String` data):
```dart
mixin WebWindowMessageMixin<T extends StatefulWidget> on State<T> {
  OnWebWindowListener? _windowListener;

  void startWindowMessageListener(void Function(String data, String? origin) onMessage) {
    _windowListener = (html.Event event) {
      if (event is! html.MessageEvent) return;
      final data = event.data;
      if (data is! String) return;
      onMessage(data, event.origin);
    };
    html.window.addEventListener('message', _windowListener!);
  }

  void stopWindowMessageListener() {
    if (_windowListener != null) {
      html.window.removeEventListener('message', _windowListener!);
      _windowListener = null;
    }
  }
}
```

The modal receives the forwarded messages via `onRegisterExternalHandler`:
```dart
// In DriveIntentWebViewModal (web variant) initState:
if (widget.onRegisterExternalHandler != null) {
  widget.onRegisterExternalHandler!(_forwardMessage);
} else {
  // Fallback: modal owns its own window listener when used outside composer.
  startWindowMessageListener(_forwardMessage);
}
```

**Send ack via iframe `contentWindow`:**
```dart
@override
void sendAck() {
  // data: URIs have opaque 'null' origin — postMessage requires '*' for those.
  final targetOrigin = _intentOrigin == 'null' ? '*' : _intentOrigin;
  _iframeElement?.contentWindow?.postMessage(jsonEncode({}), targetOrigin);
}
```

**Cleanup on dispose:**
```dart
@override
void onCleanup() => stopWindowMessageListener();

@override
void dispose() {
  onCleanup(); // guard for system back / parent nav bypassing closeModal
  super.dispose();
}
```

**Multiple composers:** each composer holds its own `_intentId` and `_webModalHandler`. All listeners fire on every `window` message, but each returns early unless the origin matches and the message type starts with `intent-{_intentId}:`. Because `intentId` is unique per `POST /intents` call, messages are naturally isolated across concurrent composer instances.

Uses `package:universal_html` (`html.window`, `html.MessageEvent`) — consistent with the rest of the codebase's web interop.

### 4. Typed Message Model

All incoming messages are parsed into a sealed class hierarchy. Raw strings never leave the parse boundary.

```dart
// top-level, independently testable
WorkplaceIntentMessage parseWorkplaceIntentMessage(String intentId, String raw) {
  final map = jsonDecode(raw) as Map<String, dynamic>;
  final type = map['type'] as String? ?? '';
  return switch (type) {
    _ when type == 'intent-$intentId:ready'  => const WorkplaceIntentReadyMessage(),
    _ when type == 'intent-$intentId:done'   => WorkplaceIntentDoneMessage.fromJson(map),
    _ when type == 'intent-$intentId:error'  => const WorkplaceIntentErrorMessage(),
    _ when type == 'intent-$intentId:cancel' => const WorkplaceIntentCancelMessage(),
    _                                        => WorkplaceIntentUnknownMessage(type),
  };
}

sealed class WorkplaceIntentMessage {
  const WorkplaceIntentMessage();
  factory WorkplaceIntentMessage.parse(String intentId, String raw) =>
      parseWorkplaceIntentMessage(intentId, raw);
}

final class WorkplaceIntentReadyMessage  extends WorkplaceIntentMessage { const WorkplaceIntentReadyMessage(); }
final class WorkplaceIntentErrorMessage  extends WorkplaceIntentMessage { const WorkplaceIntentErrorMessage(); }
final class WorkplaceIntentCancelMessage extends WorkplaceIntentMessage { const WorkplaceIntentCancelMessage(); }
final class WorkplaceIntentUnknownMessage extends WorkplaceIntentMessage {
  final String type;
  const WorkplaceIntentUnknownMessage(this.type);
}

final class WorkplaceIntentDoneMessage extends WorkplaceIntentMessage {
  final List<DriveDocument> documents;
  const WorkplaceIntentDoneMessage(this.documents);

  factory WorkplaceIntentDoneMessage.fromJson(Map<String, dynamic> json) {
    final raw = json['document'] as List? ?? [];
    final documents = <DriveDocument>[];
    for (final e in raw) {
      final doc = _tryParseDocument(e);
      if (doc != null) documents.add(doc);
    }
    return WorkplaceIntentDoneMessage(documents);
  }

  // Validates and silently drops malformed or unsafe entries.
  static DriveDocument? _tryParseDocument(dynamic e) {
    try {
      final doc = DriveDocument.fromJson(e as Map<String, dynamic>);
      if (doc.size < 0) { log('driveIntent: skipping doc with negative size'); return null; }
      if (_hasUnsafeUrl(doc)) { log('driveIntent: skipping doc with non-http(s) URL'); return null; }
      return doc;
    } catch (err) {
      log('driveIntent: skipping malformed document entry: $err');
      return null;
    }
  }

  // Rejects any URL with a scheme other than http or https.
  static bool _hasUnsafeUrl(DriveDocument doc) {
    for (final uri in [doc.sharingLink, doc.downloadLink]) {
      if (uri == null) continue;
      if (uri.scheme != 'http' && uri.scheme != 'https') return true;
    }
    return false;
  }
}
```

`DriveDocument` mirrors the `done` payload schema from ADR-0092 §8.

### 5. Shared Message Handler — `DriveIntentMessageHandlerMixin`

`DriveIntentMessageHandlerMixin<T extends StatefulWidget> on State<T>` is mixed into both platform modal `State` classes. It centralises origin validation, message dispatch, and terminal-event deduplication.

```dart
mixin DriveIntentMessageHandlerMixin<T extends StatefulWidget> on State<T> {
  late String _intentId;
  late String _intentOrigin;
  bool _modalClosed = false;  // prevents duplicate terminal events

  void initMessageHandler({required String intentId, required String intentOrigin}) { ... }

  void onMessage({required String raw, required String? origin}) {
    if (!_isValidOrigin(origin)) {
      log('driveIntent: dropped message from unexpected origin: $origin');
      return;
    }
    final WorkplaceIntentMessage msg;
    try {
      msg = WorkplaceIntentMessage.parse(_intentId, raw);
    } catch (_) {
      log('driveIntent: failed to parse message: $raw');
      return; // parse failures are logged and dropped, not thrown
    }
    _handleWorkplaceMessage(msg);
  }

  void _handleWorkplaceMessage(WorkplaceIntentMessage msg) {
    switch (msg) {
      case WorkplaceIntentReadyMessage():
        log('driveIntent: ready received, sending ack');
        sendAck();
      case WorkplaceIntentDoneMessage():
        if (_modalClosed) break;
        _modalClosed = true;
        closeModal(msg.documents);
      case WorkplaceIntentErrorMessage():
        if (_modalClosed) break;
        _modalClosed = true;
        closeModal(null);
      case WorkplaceIntentCancelMessage():
        if (_modalClosed) break;
        _modalClosed = true;
        closeModal(null);
      case WorkplaceIntentUnknownMessage():
        log('driveIntent: unknown type ${msg.type}, discarded');
    }
  }

  void closeModal(List<DriveDocument>? result) {
    onCleanup();
    if (mounted) Navigator.of(context).pop(result);
  }

  void sendAck();        // implemented by platform variants
  void onCleanup() {}    // hook for resource cleanup (web removes listener here)
}
```

Parse failures are caught and logged — not rethrown — because a single malformed message from the drive app should not crash the picker session.

### 6. Security

| Rule | Detail |
|------|--------|
| Origin validation | Every message: reject if `origin` is `null` or not `== _intentOrigin` (derived from intent URL). On mobile, data: URI `_intentOrigin` is `'null'`; accept `'*'` from shim for that case only. |
| Intent ID binding | Only accept `type` starting with `intent-{_intentId}:`. Prevents replay from prior sessions. |
| targetOrigin on send | Always `_intentOrigin`, except for data: URIs where `'*'` is required because the opaque origin cannot be specified as target. |
| JSON boundary | Always `jsonDecode`; catch and drop on malformed input. |
| URL scheme on parse | Non-http(s) links in `done` payload are dropped at parse time. |
| HTTPS | Intent URLs enforced `https://` before WebView load (ADR-0092 §3). |

### 7. Timeout & Cleanup

No 30 s ready-timeout is implemented in the current version. The modal can be dismissed manually via the close button (X) or footer cancel action at any time, which calls `closeModal(null)`. A timeout may be added in a future iteration.

On any terminal event (`done`/`error`/`cancel`/user close): `closeModal` calls `onCleanup()` (removes web window listener) then `Navigator.of(context).pop(result)`. The web modal also calls `onCleanup()` in `dispose()` as a safety guard for routes dismissed via system back or parent navigation.

## Consequences

- Mobile shim normalises both object and string payloads from the drive app; `targetOrigin` is used as a best-effort origin hint (not browser-stamped).
- Web path couples to `package:universal_html` for `window.addEventListener` — consistent with the rest of the codebase.
- Web path does not use `dart:js_interop` (`web` package); migration is a future concern.
- `DrivePickerWebStateMixin` is separate from `DriveIntentWebViewModal` — the window listener lifecycle is owned by the caller widget (composer), not the modal. This prevents a race where the iframe loads and fires `ready` before the listener is registered.
- Parse failures are silently dropped to avoid crashing the picker on a single bad message; callers will see an empty document list if all entries are invalid.
