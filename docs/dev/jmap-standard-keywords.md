# JMAP Standard Keywords as Label Chips

> **Audience:** integrators and developers building tools that read from or
> write to a Twake Mail account via JMAP (mail sentinels, filters, custom
> IMAP/JMAP clients, backfill scripts).

Twake Mail renders any [RFC 8621](https://datatracker.ietf.org/doc/html/rfc8621)
custom keyword (`Email.keywords`) as a visual **label chip** in the email
list and detail views, even when no server-side `Label` object exists for
that keyword. This lets external tools tag messages using the standard
JMAP API and have those tags immediately visible to the end user.

- [What changed](#what-changed)
- [How it interacts with the Linagora label extension](#how-it-interacts-with-the-linagora-label-extension)
- [API — setting a keyword that renders as a chip](#api--setting-a-keyword-that-renders-as-a-chip)
- [Color management](#color-management)
- [System keyword deny-list](#system-keyword-deny-list)
- [Where chips appear](#where-chips-appear)
- [Feature flag / rollout](#feature-flag--rollout)
- [Backwards compatibility](#backwards-compatibility)
- [Limitations](#limitations)
- [Testing](#testing)

---

## What changed

Before this feature, Twake Mail only displayed labels for keywords that
had a matching server-side `Label` object (Linagora
`com:linagora:params:jmap:labels` extension). Any keyword set via a
standard `Email/set { keywords/… : true }` call by an external tool was
silently discarded from the UI.

With this feature, `PresentationEmail.getLabelList(labels)` also
synthesises **orphan** `Label` chips — one per enabled keyword that is:

1. present in `Email.keywords` and enabled (`true`), and
2. not already covered by a registered `Label` object, and
3. not in the [system keyword deny-list](#system-keyword-deny-list).

Orphan chips are read-only visualisations. They render using a
[deterministic color](#color-management) derived from the keyword string,
so the same keyword always shows in the same color across sessions and
devices with no server round-trip and no storage.

---

## How it interacts with the Linagora label extension

The proprietary Linagora label extension is untouched.

| Case | Registered `Label` exists? | Result |
| :--- | :--- | :--- |
| User creates a "Newsletter" label in the UI, then a rule tags mails with `keywords/newsletter` | yes | Chip renders with the user-chosen `displayName` and `color`. |
| A mail sentinel sets `keywords/newsletter` via JMAP and no user-created label matches | no | **Orphan chip** renders with `displayName = "newsletter"` and a deterministic hash-based color. |
| RFC 8621 system keyword (`$seen`, `$flagged`, `$answered`, `$draft`, `$junk`, `$notjunk`, `$forwarded`, `$phishing`, `$mdnsent`) | not applicable | Not rendered as a chip — handled by dedicated UI (star, read/unread badge, draft badge, junk-folder move). |
| Tmail UI-mapped custom keyword (`$unsubscribe`, `needs-action`, `event`) | not applicable | Not rendered as a chip — handled by feature-specific UI. |

If both a registered `Label` and an orphan chip would apply to the same
keyword, the registered `Label` wins (retains its custom color and
display name).

---

## API — setting a keyword that renders as a chip

Any [JMAP](https://jmap.io/) `Email/set` operation that adds a keyword
outside the [deny-list](#system-keyword-deny-list) will render as a
chip on the next `Email/get` result the UI receives (typically within
seconds via the `Email/changes` polling loop).

### Constraints

JMAP keyword values follow [IMAP flag naming rules](https://datatracker.ietf.org/doc/html/rfc9051#name-flags-message-attribute)
(James enforces them server-side):

- length 1..255 characters,
- allowed: `A-Z a-z 0-9 - _ $` and non-control ASCII,
- forbidden: control characters, whitespace, and any of `( ) { ] % * " \\`.

Recommended shape: lowercase, hyphenated, no colon prefix
(`newsletter`, `github-notif`, `action-required`).

### Set a keyword

```json
{
  "using": ["urn:ietf:params:jmap:core", "urn:ietf:params:jmap:mail"],
  "methodCalls": [
    ["Email/set", {
      "accountId": "<accountId>",
      "update": {
        "<emailId>": {
          "keywords/newsletter": true,
          "keywords/action-required": true
        }
      }
    }, "0"]
  ]
}
```

Response:

```json
{
  "methodResponses": [
    ["Email/set", {
      "accountId": "<accountId>",
      "oldState": "…",
      "newState": "…",
      "updated": { "<emailId>": null }
    }, "0"]
  ]
}
```

Both chips appear on the next UI refresh — no `Label/set` call needed.

### Remove a keyword

```json
{
  "using": ["urn:ietf:params:jmap:core", "urn:ietf:params:jmap:mail"],
  "methodCalls": [
    ["Email/set", {
      "accountId": "<accountId>",
      "update": {
        "<emailId>": {
          "keywords/newsletter": null
        }
      }
    }, "0"]
  ]
}
```

### Query by keyword

Filter emails carrying a specific keyword:

```json
{
  "using": ["urn:ietf:params:jmap:core", "urn:ietf:params:jmap:mail"],
  "methodCalls": [
    ["Email/query", {
      "accountId": "<accountId>",
      "filter": { "hasKeyword": "newsletter" },
      "limit": 50
    }, "0"]
  ]
}
```

The `hasKeyword` filter works for any keyword — registered `Label`,
orphan, or system.

---

## Color management

Orphan chips receive a deterministic color computed client-side from
the keyword string; no server-side storage and no round-trip.

### Palette

Twelve colors, selected from the tmail label color picker for
sufficient contrast against white chip text:

| Slot | Hex | Rough name |
| :--- | :--- | :--- |
| 0 | `#273891` | deep blue |
| 1 | `#7E57E3` | purple |
| 2 | `#4896E5` | blue |
| 3 | `#038199` | teal |
| 4 | `#457D6C` | dark green |
| 5 | `#51B588` | green |
| 6 | `#E0465C` | red |
| 7 | `#ED20A4` | pink |
| 8 | `#B85B17` | brown |
| 9 | `#ED916B` | orange |
| 10 | `#EDA91D` | amber |
| 11 | `#646580` | slate |

### Hash

Simple FNV-1a variant on the keyword's UTF-16 code units, modulo the
palette length:

```dart
var hash = 0x811C9DC5;
for (final unit in keyword.value.codeUnits) {
  hash = (hash ^ unit) * 0x01000193 & 0xFFFFFFFF;
}
final color = palette[hash % palette.length];
```

### Guarantees

- **Deterministic** — the same keyword always maps to the same color.
- **Stable across sessions** — no cookie, cache, or storage required.
- **Cross-platform** — mobile, desktop, and web produce the same result.

### Overriding the color

To display a keyword with a *custom* color and display name, register
a `Label` object via the Linagora label extension
(`com:linagora:params:jmap:labels`, `Label/set create`). Once the
matching `Label` exists, it takes precedence over the orphan-chip
synthesis and its color / display name are used instead.

---

## System keyword deny-list

The following keywords are **never** rendered as chips because they
carry dedicated UI treatment:

| Keyword | Dedicated UI |
| :--- | :--- |
| `$seen` (RFC 8621) | Read/unread badge on the email tile. |
| `$flagged` (RFC 8621) | Star icon on the email tile. |
| `$answered` (RFC 8621) | Reply arrow icon in the tile action area. |
| `$forwarded` (RFC 8621) | Forward arrow icon in the tile action area. |
| `$draft` (RFC 8621) | Drafts folder + tile badge. |
| `$junk` (RFC 8621) | Spam / Indésirables folder auto-move. |
| `$notjunk` (RFC 8621) | Ham marker — no chip; feeds spam classifiers. |
| `$phishing` (RFC 8621) | Phishing warning banner. |
| `$mdnsent` (RFC 8621) | MDN delivery-receipt indicator. |
| `$unsubscribe` (tmail) | Unsubscribe button in the email header. |
| `needs-action` (tmail) | "Action requise" filter + folder view. |
| `event` (tmail) | Calendar event integration. |

The deny-list is a single source of truth in
`model/lib/extensions/keyword_identifier_extension.dart::systemKeywords`.
Adding a keyword that should get dedicated UI treatment means adding it
here — it will then no longer render as an orphan chip.

---

## Where chips appear

All four view callsites for `getLabelList` benefit automatically:

- **Thread view** — `lib/features/thread/presentation/thread_view.dart`
- **Single email view** — `lib/features/email/presentation/email_view.dart`
- **Thread detail view** — `lib/features/thread_detail/presentation/extension/get_thread_details_email_views.dart`
- **Search results** — `lib/features/search/email/presentation/search_email_view.dart`

No per-callsite change was needed; the synthesis lives in the shared
extension `PresentationEmailExtension.getLabelList(labels)` in
`lib/features/email/presentation/extensions/presentation_email_extension.dart`.

---

## Feature flag / rollout

The orphan-chip synthesis is **always on** — no capability negotiation
and no user preference gate. `Email.keywords` is a standard RFC 8621
`Email` property, so the change works on any JMAP server (with or
without the Linagora `com:linagora:params:jmap:labels` capability).

The Linagora label capability gate (`isLabelAvailable`) continues to
gate the *management* UI (create / edit / delete `Label` objects). The
orphan-chip *display* path is independent.

---

## Backwards compatibility

- **API surface** — none added on the server side; keyword semantics
  and JMAP wire format are unchanged.
- **Existing `Label` objects** — untouched; their color and display
  name still win over any orphan synthesis for the same keyword.
- **System keywords** — always suppressed; existing UI icons remain
  the sole visual representation.
- **Older client behavior** — clients that predate this change
  continue to ignore keywords without a registered `Label`. Rolling
  back the change is a UI-only revert.

---

## Limitations

- **Read-only chips** — orphan chips do not currently expose a "remove"
  action from the tile. Removing an orphan keyword still requires an
  `Email/set { keywords/foo: null }` call from an external tool (or
  registering a matching `Label` and using the standard remove UI).
- **Display name = keyword value** — orphan chips display the raw
  keyword. If the raw value is technical (`__spam__`,
  `mail-sentinel-processed`), consider using human-readable keyword
  values from the start (`spam-detected`, `sentinel-processed`).
- **Color drift on palette resize** — the palette size (currently
  `12`) is stable; if a future release changes it, deterministic
  color assignments will remap. Palette entries can be reordered
  without changing individual keyword→color mappings so long as the
  size stays the same.

---

## Testing

Unit tests live in
`test/model/lib/extensions/get_label_list_in_keyword_email_test.dart`
and cover:

- surfacing a keyword as an orphan label when no matching `Label` exists;
- filtering out the full RFC 8621 system keyword set;
- registered `Label` wins over orphan synthesis for the same keyword;
- mixed input (registered + orphan + system-filtered) produces the
  right chip set;
- disabled keywords (`keywords/foo: false`) are excluded;
- deterministic color — same keyword string always resolves to the
  same hex value.

Run:

```bash
flutter test test/model/lib/extensions/get_label_list_in_keyword_email_test.dart
```

Live end-to-end verification: from any JMAP client, set a non-system
keyword on an inbox message and reload the Twake Mail web/mobile app —
the chip appears on the affected message tile within seconds.
