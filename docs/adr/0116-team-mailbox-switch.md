# 116. Switch to a team mailbox

Date: 2026-10-22

## Status

Proposed

## Related ADRs

- [ADR-0114](./0114-delegated-mailbox-access.md) — `ActiveAccount`, the switch flow and the switcher this ADR extends

## Context

- A team mailbox is a folder tree of my own account (`mine`): a root with namespace `TeamMailbox[...]` (`isTeamMailboxRoot`) and its folders. Today the folder tree shows my teams under "Team mailboxes", next to my personal folders.
- A team usually has an identity with its address, and when it is picked the composer already files Sent, Drafts and Outbox in the team's folders (`emailTeamMailBoxes`).
- Users want to work in one team as if it were its own mailbox, picked in the same switcher as the mailboxes delegated to them (ADR-0114, a third group of the switcher, DS-1..3).
- ADR-0114 is built so that this needs no change to its tickets: the shown account stays `mine`, so push, caches, Settings and the readers classified in T-02 are untouched.

## Decision

### Model

The shown team is a second dimension next to `ActiveAccount`, not an account:

```dart
sealed class MailboxScope {}
class WholeAccountScope extends MailboxScope {}
class TeamMailboxScope extends MailboxScope {
  final MailboxId rootId;
  final String teamEmailAddress; // root.emailTeamMailBoxes
}
```

- `mailboxScopeProvider` is Riverpod state, `WholeAccountScope` by default. A team scope is valid on `mine` only, so every account switch resets it to `WholeAccountScope`.
- Every account reader classified in T-02 keeps its account. Push, caches and URLs of folders and emails are those of `mine`, unchanged.

### Switching

- `AccountSwitchNotifier` gets one more target, a team of `mine`. The rules of a switch apply (refused while a composer is open or another switch runs, input blocked, a new generation), but no account is loaded: the scope changes and the team's Inbox opens.
- From a delegated account into a team it is one switch: the account switch to `mine`, then the team scope, with one generation.
- Back to the whole of `mine` is the same scope change, to `WholeAccountScope`.
- A start keeps the scope like the account: `team=<rootId>` in the web URL, the last scope next to the last account in the Android and iOS app.
- Back or Forward to an entry of another scope runs the scope change. A URL folder outside the team is handled as gone. A notification tap or an intent opens the email in the scope of its folder: the team for a team folder, `WholeAccountScope` otherwise.

### What the scope narrows

| Area | In a team scope |
|---|---|
| Folder tree | Only the children of the root, at the top level. No personal folders, no other team, no Starred or Action required, no labels section. The team's own Inbox is the only Inbox shown |
| Default folder | The team's Inbox (`isFirstLevelTeamSystemFolder(map, PresentationMailbox.inboxRole)`, matched by name). A team with no Inbox opens its first folder |
| Create folder | A new top-level folder goes under the team root |
| Email list, flags, move, delete | Unchanged: they already act on the folder shown |
| Search | A search with no folder is narrowed to an `OR` of `inMailbox` over the team's folders (a new filter, `inMailbox` takes one id today). A folder filter outside the team is replaced by the team |
| Composer | The identity whose email is `teamEmailAddress` is preselected. Sent, Drafts and Outbox already follow that identity (`getSentMailboxIdForComposer` and the like). If no identity has that email, the default identity is used |
| Settings | Reachable, since the account is `mine` |
| "me" | My address, as on `mine` |

### Ended membership

- When the root is destroyed or missing from the folder list of `mine` (removed from the team, team deleted), the scope goes back to `WholeAccountScope` with a toast, even while a composer is open. The composer stays open, since it is `mine`. A start whose `team` is gone does the same.
- No local data is deleted: the team's folders and emails are cached under `mine` and go away with the normal mailbox and email cache updates.

### Switcher

Team mailboxes are the third group of the switcher ("Team mailboxes", DS-1..3, web and mobile), listed from the team roots of `mine`. While a delegated account is shown they come from the cache of `mine`, and a `Mailbox` change in `changed[mine]` refreshes them. No design system change is needed.

### Tickets

Tracked in their own issue once the work starts, after the ADR-0114 entry points.

| Id | Ticket |
|---|---|
| TM-1 | `MailboxScope`, the team target of the switch, the start (`team` in the URL, last scope on mobile), Back and notification taps across scopes, ended membership |
| TM-2 | Folder tree, default folder, folder creation under the root, virtual folders and labels hidden in a team scope |
| TM-3 | Search narrowed to the team, composer identity preselected |
| TM-4 | Third group of the switcher (web and mobile) and its E2E scenarios |

## Consequences

- No new account, no new push channel, no cache change: a team scope only narrows what the views of `mine` show and search.
- Only the folder tree, the default folder, folder creation, search and the composer read the scope. The readers of ADR-0114 T-02 keep their account.
- The whole-account view of `mine` keeps its "Team mailboxes" section as today.
