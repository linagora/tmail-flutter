# 92. External Drive File Picker Integration via Intent Protocol

Date: 2026-05-29

## Status

Accepted

## Reference
https://app.notion.com/p/linagora/File-Picker-36d62718bad1802c884cd51303356b32#36e62718bad180428658ea1da27bcd82

## Context

TMail needs to allow users to attach files from an external drive service directly in the composer, without re-uploading. The mechanism is an open **intent protocol**: tmail requests a `PICK` intent from the drive platform, the platform returns a URL for a file-picker UI, tmail renders that URL in a WebView, and the two sides communicate via `postMessage` to exchange selected file metadata.

Any drive service that implements the following is compatible:
- `POST /intents` → returns an intent URL
- The three-step postMessage handshake described below

The full flow has 8 steps. Two are partially blocked on backend work:

1. **Obtain platform URL** — already available via `workplaceFqdn` in OIDC userinfo (`OidcUserInfo.workplaceFqdn`)
2. **Obtain platform access token** — WIP; requires the drive platform's token exchange endpoint to accept user OIDC tokens.
3. **Create intent** — `POST https://<platformUrl>/intents` → intent URL + intent ID
4. **Render intent URL** — `InAppWebView` (mobile/tablet) / `HtmlIframeWidget` (web)
5. **postMessage handshake** — bidirectional, service-driven
6. **Close WebView**
7. **Handle errors/cancellation**
8. **Attach selected files** — display in composer attachment panel, then send with email

Step 2 is the main blocker for production. Steps 3–8 can be designed and partially implemented ahead of the backend changes.

## Decision

### Step 1 — Platform URL

`OidcUserInfo.workplaceFqdn` is parsed from `GET /oauth2/userinfo`. Expose via a keepAlive sync Riverpod state notifier:

```dart
@Riverpod(keepAlive: true)
class WorkplaceFqdnNotifier extends _$WorkplaceFqdnNotifier {
  @override
  String? build() => null;

  void setFqdn(String? rawFqdn) { ... } // validates scheme, rejects non-https in release
}
```

Platform URL = `https://<workplaceFqdn>` (scheme added if absent; plain HTTP rejected in release mode).

**Feature visibility** is computed by `DriveAttachmentUriValueNotifierProvider` — a keepAlive `ValueNotifier<Uri?>` that watches `WorkplaceFqdnProvider`, `DriveAttachmentEnabledProvider` (server-side capability flag), and `LocalSettingsProvider` (user preference). When any dependency changes the `ValueNotifier` is updated. Consumers observe `ValueNotifier<Uri?>` — null means feature is hidden.

During development before the real flow is wired, a fake `data:` URI is returned so the picker button and modal remain testable. The TODO is marked in `DriveAttachmentUriValueNotifierProvider`.

### Step 2 — Platform Access Token

Token exchange is handled inline by `WorkplaceComposerAttachmentExtension` (a plain Dart class, not a Riverpod notifier). The OIDC `id_token` is obtained via an `oidcTokenGetter` function reference passed as a constructor parameter at startup — no direct GetX session coupling.

```dart
// workplace/lib/presentation/extension/workplace_composer_attachment_extension.dart
class WorkplaceComposerAttachmentExtension {
  final String? Function() oidcTokenGetter;
  ...
  Future<WorkplaceIntent> _fetchIntent(Uri platformUrl, ...) async {
    final oidcToken = oidcTokenGetter();
    if (oidcToken == null) throw StateError('OIDC token is unavailable');
    final accessToken = await _exchangeAccessToken(platformUrl, oidcToken);
    if (accessToken == null) throw StateError('Drive access token exchange failed');
    return _createIntent(platformUrl, accessToken, ...);
  }
}
```

**Production:** `ExchangeDriveTokenInteractor` calls `POST https://<platformUrl>/auth/token_exchange` with the current OIDC `id_token` and returns the drive access token.

Token storage: in-memory only, held for the duration of the intent creation call. Not persisted.

### Step 3 — Create Intent

```
POST https://<platformUrl>/intents
Authorization: Bearer <drive-access-token>
Content-Type: application/json

{
  "data": {
    "type": "io.cozy.intents",
    "attributes": {
      "action": "PICK",
      "type": "io.cozy.files",
      "permissions": ["GET"],
      "actions": [
        { "sharingLink": "<addAsLink label>", "downloadLink": "<addAsAttachment label>" }
      ]
    }
  }
}
```

The `actions` array passes localised button labels to the drive platform so it can render its own "Add as link" / "Add as attachment" buttons inside the WebView UI. Labels are resolved via `AppLocalizations` at tap time and forwarded via `FetchDriveIntentCallback`.

Request and response use typed `json_serializable` models in the data layer:

```dart
// data/model/workplace_intent_request.dart
class WorkplaceIntentRequest { final WorkplaceIntentDataRequest data; }
class WorkplaceIntentDataRequest { final WorkplaceDataRequestType type; final WorkplaceIntentAttributesRequest attributes; }
class WorkplaceIntentAttributesRequest { final WorkplaceAction action; final WorkplaceDocType type; final List<WorkplacePermission> permissions; final List<WorkplaceIntentActionsRequest> actions; }
class WorkplaceIntentActionsRequest { @JsonKey(name:'sharingLink') final String addAsLink; @JsonKey(name:'downloadLink') final String addAsAttachment; }

// data/model/workplace_intent_response.dart
final class WorkplaceIntentResponse { final WorkplaceIntentDataResponse data; }
final class WorkplaceIntentDataResponse { final String id; final WorkplaceIntentAttributesResponse attributes; }
final class WorkplaceIntentAttributesResponse { final List<WorkplaceIntentServiceResponse> services; ... }
final class WorkplaceIntentServiceResponse { final String href; }
```

Domain entity:

```dart
// domain/entity/workplace_intent.dart
class WorkplaceIntent with EquatableMixin {
  final String intentId;   // data.id
  final Uri intentUrl;     // data.attributes.services[0].href
}
```

`WorkplaceRepositoryImpl` parses `WorkplaceIntentResponse` → `WorkplaceIntent`. Domain layer and above only see `WorkplaceIntent` — no raw map access outside the data layer.

Reject any intent URL where `intentUrl.scheme != 'https'`.

### Step 4 — Render Intent URL

Specified in detail in **[ADR-0094](0094-render-intent-url-in-webview-modal.md)**.

Summary: `DriveIntentWebViewModal` is used across all platforms via `showDialog`. Platform split via Dart conditional export: mobile variant uses `InAppWebView`, web variant uses `HtmlIframeWidget` (from `package:core`). A shared `DriveIntentWebViewModalShell` provides the close button (X). A unique `intentId` guards lifecycle.

### Step 5 — postMessage Handshake

Specified in detail in **[ADR-0093](0093-postmessage-handshake-for-drive-intent-webview.md)**.

Summary:
- Mobile/tablet: inject a `window.parent` shim via `UserScript` at `AT_DOCUMENT_START` (see `DriveIntentShims.parentPostMessageShim`) to route `postMessage` calls to Flutter via `callHandler('driveIntentMessage', ...)`. Reply by dispatching a `MessageEvent` into the window via `evaluateJavascript`.
- Web: `DrivePickerWebStateMixin` registers `window.addEventListener('message', ...)` once when the composer opens (via `startWindowMessageListener`), not at modal open. The listener forwards messages to the modal via an `onRegisterExternalHandler` callback. Use `addEventListener` — never `window.onmessage =` — because `WebEditorWidget` already holds its own `message` listener; property assignment would clobber it. Reply via `IFrameElement.contentWindow?.postMessage(...)`.
- Three-message protocol: `intent-{id}:ready` → `{}` ack → `intent-{id}:done|error|cancel`.
- Security: origin validation on every message, intent ID binding, `targetOrigin` never `"*"` (except for data: URIs whose origin is opaque `'null'`).

### Step 6 — Close WebView

On receiving `done`, `error`, or `cancel`: `closeModal(result)` calls `onCleanup()` then `Navigator.of(context).pop(result)`. A `_modalClosed` flag in `DriveIntentMessageHandlerMixin` prevents processing multiple terminal events.

### Step 7 — Error Handling

| Signal | Cause | Action |
|--------|-------|--------|
| HTTP error on `POST /intents` | Token invalid / platform unreachable | `DriveAttachmentError` state → UI shows error |
| Intent URL not `https://` | Misconfigured platform | Reject before passing to WebView |
| `intent-{id}:error` | Service-side failure | `closeModal(null)`, caller handles |
| `intent-{id}:cancel` | User dismissed picker | `closeModal(null)`, no-op |
| Invalid `event.origin` | Spoofed message | Silent drop + log |
| Malformed JSON | Bad message payload | Caught, logged, dropped |

### Step 8 — Attach Documents

The `done` payload:

```json
{
  "document": [{
    "id": "string",
    "name": "string",
    "size": number,
    "mimeType": "string",
    "sharingLink": "string (optional)",
    "downloadLink": "string (optional)"
  }]
}
```

Domain entity:

```dart
// domain/entity/drive_document.dart
@JsonSerializable(createToJson: false)
class DriveDocument with EquatableMixin {
  final String id;
  final String name;
  final int size;
  final String mimeType;
  final Uri? sharingLink;
  final Uri? downloadLink;
}
```

Documents are validated during parse (`WorkplaceIntentDoneMessage.fromJson`): entries with negative `size` or non-http(s) URL schemes are silently dropped and logged.

On receiving a `done` result, `DriveAttachmentHandler` (in `lib/features/composer/presentation/manager/`) inserts HTML anchor tags into the composer body via `insertHtml`:

```dart
// DriveAttachmentHandler inserts <a href> links for documents that have a sharingLink
static String buildDriveLinksHtml(List<DriveDocument> docs) => docs
    .map((doc) => _driveLinkAnchor(doc))
    .nonNulls
    .join('<br>');
```

Only documents with a `sharingLink` are rendered as links. The `downloadLink` is not surfaced in the current implementation.

`DriveDocumentExtension.linkedFileHeader` (in `workplace/domain/entity/`) also exists and encodes a document as an `X-LinkedFile` header for future use:

```
url=https://link/to/the/file;\r\n\tfilename="Application form.pdf";\r\n\ttype="application/pdf";\r\n\tsize=2345
```

- Uses RFC 2822 §2.1.1 line folding (CRLF + tab between params).
- ASCII filenames → quoted-string with backslash escaping (RFC 2822 §3.2.5).
- Non-ASCII filenames → RFC 2231 encoded param (RFC 5987).
- URL: `sharingLink` if present, otherwise `downloadLink`. Only `https://` URLs are emitted.

Per-picker flow state (idle / fetching / pending / error) is modelled in `DriveAttachmentState` sealed class (`workplace/presentation/notifier/`). Pick outcomes are reported via `DrivePickState` callbacks (`DrivePickResult` / `DrivePickFailure`) from `DrivePickerStateMixin` to the composer:

```dart
sealed class DriveAttachmentState { final List<DriveDocument> attachments; }
final class DriveAttachmentIdle extends DriveAttachmentState {}
final class DriveAttachmentFetchingIntent extends DriveAttachmentState {}
final class DriveIntentPending extends DriveAttachmentState { final WorkplaceIntent intent; }
final class DriveAttachmentError extends DriveAttachmentState { final Object error; }
```

### Module Boundary

All drive-integration code lives in the `workplace` Dart workspace package at the repository root (same level as `server_settings`, `fcm`, `forward`, etc.):

```
workplace/
  pubspec.yaml              # name: workplace, resolution: workspace
  lib/
    domain/
      entity/               # DriveDocument, WorkplaceIntent
      message/              # WorkplaceIntentMessage sealed class + subtypes
      repository/           # WorkplaceRepository interface
      state/                # WorkplaceIntentState (Either success/failure types)
      usecase/              # CreateDriveIntentInteractor, ExchangeDriveTokenInteractor
    data/
      datasource/           # WorkplaceDataSource interface
      datasource_impl/      # WorkplaceDataSourceImpl (HTTP)
      model/                # WorkplaceIntentRequest/Response (json_serializable)
      repository_impl/      # WorkplaceRepositoryImpl
    presentation/
      extension/            # WorkplaceComposerAttachmentExtension (ComposerAttachmentPlugin impl)
      mixin/                # DriveIntentMessageHandlerMixin, DriveIntentShims,
                            #   DrivePickerStateMixin, DrivePickerWebStateMixin,
                            #   WebWindowMessageMixin
      model/                # DrivePickState (DrivePickResult / DrivePickFailure)
      notifier/             # DriveAttachmentState sealed class
      view/                 # DriveIntentWebViewModal (conditional export),
                            #   DriveIntentWebViewModalMobile/Web, DriveIntentWebViewModalShell,
                            #   DriveIntentFakePage
      widget/               # DriveAttachmentPickerButton, DriveAttachmentContextMenuTile
  test/
    domain/entity/          # DriveDocumentExtension tests
    domain/message/         # WorkplaceIntentMessage parse tests
    presentation/mixin/     # DriveIntentMessageHandlerMixin tests

# Riverpod providers live in the main app package:
lib/main/providers/workplace/
  workplace_fqdn_notifier.dart
  drive_attachment_enabled_notifier.dart
  drive_attachment_uri_value_notifier_provider.dart

# Composer-side integration in the main app:
lib/features/composer/presentation/manager/
  drive_attachment_handler.dart       # inserts HTML links into composer body
```

`lib/` imports `workplace` as a workspace dependency. Drive integration is wired via `WorkplaceComposerAttachmentExtension` (a `ComposerAttachmentPlugin` implementation) — no drive logic leaks into `ComposerController` directly. Dependency wiring (datasource / repository / interactor) is done inside `WorkplaceComposerAttachmentExtension` without Riverpod providers.

The typed message model (`WorkplaceIntentMessage` sealed class, `DriveDocument`) lives in `workplace/domain/` — the only shared surface consumed by the main app.
