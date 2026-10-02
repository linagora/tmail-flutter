# MCP Marionette

## Introduce

Marionette MCP lets an AI agent drive a running Twake Mail debug or profile build: tap, type, scroll, screenshot, and read logs. Launch `tmail-mcp/main.dart`. Composer extensions reach the email body outside the widget tree (web iframe, mobile WebView). Use it for local smoke and QA exploration; keep Patrol as the CI suite, not Marionette.

Owners:

- MCP entrypoint: `tmail-mcp/main.dart`
- Binding host: `tmail-mcp/runtime/`
- Marionette adapter: `tmail-mcp/marionette/`
- Official package docs: [marionette_flutter](https://pub.dev/packages/marionette_flutter) / [getting started](https://github.com/leancodepl/marionette_mcp/blob/main/docs/getting-started.md)

## Setup

Install the MCP bridge once, register it in Cursor or Claude Code, then run the MCP entrypoint. Keep `marionette_mcp` on the same version as `marionette_flutter` (0.6.0).

```bash
dart pub global activate marionette_mcp 0.6.0
export PATH="$PATH:$HOME/.pub-cache/bin"
```

Cursor (project `.cursor/mcp.json` or `~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "marionette": { "command": "marionette_mcp", "args": [] }
  }
}
```

Claude Code:

```bash
claude mcp add --transport stdio marionette -- marionette_mcp
```

Run the MCP entrypoint (not `lib/main.dart`). Release never enables Marionette:

```bash
/bin/bash scripts/prebuild.sh
flutter run -t tmail-mcp/main.dart
```

Web example:

```bash
flutter run -t tmail-mcp/main.dart -d chrome --web-port=2025
```

`MARIONETTE` defaults to on for this target. Pass `--dart-define=MARIONETTE=false` to skip it while using the same host.

Copy the `ws://…/ws` URI from `flutter run` output. That is the connect target.

No MCP server? Use the [Marionette CLI](https://github.com/leancodepl/marionette_mcp/blob/main/docs/cli.md) instead.

## Guide to use

Use Marionette when a person or AI needs to **drive the live Flutter UI** and see the **widget tree**, not the Chrome DOM.

### Development

- Smoke a flow you just coded: open composer, fill fields, send, check `get_logs`.
- Reproduce a widget-level bug on **mobile or web** with the same agent loop.
- After a UI change, `hot_reload` and re-tap the same labels without restarting the agent.
- Reach the composer body with `tmailComposer.setBody` / `tmailComposer.getBody` (iframe / WebView is invisible to tree tools).

### QA

- Exploratory checks: “open inbox, search X, open first result, reply, set body, send”.
- Cross-check a Patrol case on a real debug build (same labels, same composer extension idea).
- Capture `take_screenshots` + `get_logs` as evidence, not as the CI gate.

### Do not use it for

- Release / store / Docker production images (`kReleaseMode` drops the binding).
- Deterministic CI regression — that stays [Patrol](../adr/0053-patrol-integration-test.md).
- Web-only DOM, SSO cookie reuse, file-picker, or network traces — that stays `agent-browser`.

## How to use

### Start a session

1. Start the app with `flutter run -t tmail-mcp/main.dart` (debug or profile).
2. Log in yourself. Do not put credentials in the agent prompt.
3. Copy the `ws://…/ws` line from `flutter run`.
4. Tell the agent that URI and the goal in one message (screen, labels, do-not-send).
5. The agent must `connect` before any other tool. A version mismatch means `marionette_mcp` ≠ `marionette_flutter` 0.6.0.

### Find, then act

- Call `get_interactive_elements` after every navigation. The list is the current screen, not the last one.
- Prefer `tap(text: "Compose")` / `tap(text: tooltip)`. Twake Mail maps `TMailButtonWidget` text and tooltip, and `TMailContainerWidget` tooltip. Icon-only buttons match the tooltip.
- Prefer a `key` or Semantics `identifier` when two widgets share the same label.
- `enter_text` does not match by visible text. Tap the field first, then `enter_text` with `focused_element: true`, or pass its `key`.
- Off-screen item: `scroll_to` by text or key, then tap.
- Unknown screen: `take_screenshots` first, then list elements. Do not guess taps.

### Drive the composer (the hard part)

The email body is **not** a Flutter `TextField`. Tree tools cannot type into Summernote (web iframe) or the mobile InAppWebView. That is why this repo registers two extensions.

1. Open composer (Compose / Reply / Forward). Confirm it with `get_interactive_elements` (To, Subject, Send).
2. Fill To and Subject with `tap` + `enter_text`. Press Enter on To so the address becomes a chip.
3. Call `tmailComposer.setBody` with `{ "text": "line one\n\nline two" }`. Each line becomes a paragraph. The signature stays.
4. Wait one beat. Call `tmailComposer.getBody` and check `text` (and `html` if you care about markup).
5. Only then tap Send or Save. Immediate Send can use a stale body.
6. `get_logs` to confirm the JMAP send/save. `take_screenshots` for the toast or sent thread.

If the extension returns `No composer editor found`, the composer is closed or the editor iframe/WebView is not ready. Open it and retry. Do not fall back to `enter_text` on the body.

### Verify every step

- After a tap: list elements again. The new screen must show the expected labels.
- After `setBody`: `getBody` must contain your text and still contain the signature.
- After Send / Search / Move: `get_logs` must show the JMAP call, not only a UI change.
- After a failure: screenshot + logs before you retry. That pair is the bug report.

### Development loop

1. Connect once. Keep the session.
2. Ask the agent to reach the screen you changed (composer, search, mailbox list).
3. Save code. Ask for `hot_reload` (keep state) or `hot_restart` (reset to `main()`).
4. Re-run the same taps. Compare screenshot + logs before and after.
5. Stop at “body set and confirmed” while you iterate. Send only on the last pass.

What this buys in development:

- You do not write a Patrol test to see if today’s widget still taps.
- The same prompt works on a phone and on Chrome, because the agent sees Flutter widgets, not the Chrome DOM.
- `hot_reload` keeps you in the composer. No re-login, no re-type of To/Subject.
- `get_logs` answers “did Email/set fire?” without opening DevTools.
- You can hand the agent a ticket (“Reply keeps the old body”) and get a reproduce path: list → tap Reply → `setBody` → `getBody` → screenshot.

### QA loop

1. Human logs in on the target backend (local / stg / prod test account).
2. Give the agent: URI, flow, expected labels, recipient allowlist, “do not send” or the exact test address.
3. Agent drives the flow, stops on the first missing label or failed extension.
4. Agent returns: step list, screenshots, `getBody` payload, relevant logs.
5. QA files the ticket with that evidence, or signs the flow as walked.

What this buys in QA:

- Exploratory coverage on **mobile**, which `agent-browser` cannot do.
- A tester who is not a Flutter expert can still say “tap Search, open first mail, reply”.
- Evidence is structured (widget list + screenshot + logs), not only a phone photo.
- You can replay a Patrol scenario by hand on a real debug build before you change the test.
- You can compare web vs Android with the same prompt and the same composer tools.

### Prompts that work

Copy the URI, then paste one of these:

- **Compose, do not send:** “Connect to `ws://127.0.0.1:9101/ws`. List interactive elements. Tap Compose. Set To to `<test@…>` and press Enter. Set Subject to `Marionette smoke`. Call `tmailComposer.setBody` with `Hello from Marionette`. Wait, call `tmailComposer.getBody`, and stop. Screenshot + logs. Do not send.”
- **Send mail (QA):** “Connect. Open composer. To = allowlisted test account only. Subject = `QA send`. `setBody` then `getBody` (must match). Then Send. Show the toast screenshot and the JMAP send lines from `get_logs`.”
- **Reply:** “Connect. Open the first inbox mail. Tap Reply. `getBody` (quote + signature). `setBody` with a new first paragraph. `getBody` again. Do not send unless I say so.”
- **Search:** “Connect. Tap Search. Enter `<query>`. Wait for results. Open the first row. Screenshot and list elements on the thread.”
- **After a code change:** “Hot reload. List elements. Repeat the last composer steps. Diff `getBody` and logs against the previous run.”

### Safety

- Send only to known test accounts. Same rule as headed UI checks.
- Do not put passwords, SSO cookies, or Bearer tokens in the prompt or in pasted logs.
- `hot_restart` drops in-memory composer state. Re-open composer after it.
- One app per URI. Reconnect if you restart `flutter run`.

### Composer rules

- `tmailComposer.setBody` / `tmailComposer.getBody` fail with “No composer editor found” if the composer is closed.
- `setBody` takes plain text. Each line becomes a paragraph. The signature stays.
- Web target is Summernote `div.note-editable` (same idea as `WebComposerRobot.addContent`).
- Mobile target is the InAppWebView `#editor`.
- Sending or saving immediately after `setBody` can use a stale body. Wait, then `getBody` before Send.

## Benefits

What Marionette gives this repo that the other tools do not:

- **See Flutter, not CanvasKit.** Twake Mail web paints to canvas. A DOM agent guesses. Marionette lists real buttons, tooltips, and keys, so “tap Compose” is a widget match, not a pixel hunt.
- **One skill for mobile and web.** The same `connect` → list → tap → `tmailComposer.setBody` path runs on Chrome, Android, and iOS debug/profile. `agent-browser` stops at web.
- **Composer body is automatable.** The PR’s extensions close the gap Patrol already solved in tests: the editor lives in an iframe / WebView. Without them, an agent can fill To/Subject and still cannot write the body.
- **Faster than writing a test first.** A developer can prove a flow in minutes (connect, drive, logs) and only then spend time on a Patrol case.
- **Keep state while you code.** `hot_reload` applies the Dart change on the open composer. You iterate on the widget, not on login + navigation.
- **Logs sit next to the tap.** `get_logs` shows whether the UI action reached JMAP (send, save, search). That is the difference between “the button moved” and “the backend was called”.
- **QA evidence without a device farm script.** Screenshot + interactive-element dump + logs is enough to attach to a ticket or a PR comment.
- **Same vocabulary as Patrol.** Labels, composer body helper, send-mail case. QA can walk the Patrol happy path on a headed debug build when CI is red or the device is local.
- **Small, opt-in surface.** Few tools, short prompts, MCP entrypoint only, never in `lib/` or release. You are not shipping a driver into production.

It does **not** replace Patrol (CI truth) or `agent-browser` (SSO, file picker, network). It fills the gap: *drive the live Flutter UI, including the composer, on mobile and web, with an AI agent.*

## Disadvantages

- Needs the VM Service. Debug / profile only. No release, no production web image.
- `marionette_mcp` and `marionette_flutter` versions must match or `connect` fails.
- You must paste the `ws://` URI. Inferring it is unreliable.
- Custom widgets are invisible unless configured. Twake Mail covers its buttons; new controls need the same hook.
- Iframe / WebView / OS dialogs are still blind without an extension (file picker, native share, SSO browser).
- Gestures are best-effort. Overlays and custom hit targets can miss.
- `setBody` then Send too fast can save or send the old body.
- Not a CI replacement. Flaky agent runs do not replace Patrol.
- Login, SSO, and real sends still need a human and an allowlisted recipient.
- One `WidgetsBinding` per process. The MCP entrypoint boots Marionette before Sentry. Do not init it from `flutter test` or Patrol.

## Add another MCP binding

`tmail-mcp/` is the shared host for every in-app MCP. Keep product `lib/` free of agent drivers. New hooks go next to Marionette:

1. Implement `McpAppBinding` under `tmail-mcp/<name>/`.
2. Set `ownsWidgetsBinding` only if the adapter installs a `WidgetsBinding`. Only one owner is allowed.
3. Append the binding to the list in `tmail-mcp/main.dart`.
4. Gate it with `!kReleaseMode` and its own dart-define if you need to turn it off.

## Pick a tool

| Need | Tool |
|------|------|
| Drive Flutter widgets on mobile or web, read app logs, hot reload | **Marionette MCP** |
| Drive Chrome DOM, SSO profile, file picker, network | **agent-browser** |
| Repeatable CI / PR regression | **Patrol** |
| Analyze / pub / compile errors | **Dart & Flutter MCP** |

## See also

- App run and backend: [backend-setup.md](backend-setup.md)
- Patrol CI: [ADR 0053](../adr/0053-patrol-integration-test.md)
- Official tools list: [MCP Tools](https://github.com/leancodepl/marionette_mcp/blob/main/docs/mcp-tools.md)
