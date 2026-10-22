# 116. Switch to a team mailbox

Date: 2026-10-22

## Status

Proposed

## Related ADRs

- [ADR-0114](./0114-delegated-mailbox-access.md) — `ActiveAccount`, the switch flow and the switcher this ADR extends

## Context

- A team mailbox is a folder tree of an account: a root with namespace `TeamMailbox[...]` (`isTeamMailboxRoot`) and its folders. Today the folder tree of `mine` shows my teams under "Team mailboxes", next to my personal folders. A delegated account acts as its owner, so its folder tree shows the owner's teams the same way.
- A team usually has an identity with its address, and when it is picked the composer already files Sent, Drafts and Outbox in the team's folders (`emailTeamMailBoxes`).
- Users want to work in one team as if it were its own mailbox, picked in the same switcher as the mailboxes delegated to them (ADR-0114, a third group of the switcher, DS-1..3).
- ADR-0114 is built so that this needs no change to its tickets: a team scope keeps the shown account, so push, caches, Settings and the readers classified in T-02 are untouched.

## Decision

### Model

The shown team is a second dimension next to `ActiveAccount`, not an account:

```dart
sealed class MailboxScope {}
class WholeAccountScope extends MailboxScope {}
class TeamMailboxScope extends MailboxScope {
  final AccountId accountId; // the account that holds the team, mine or delegated
  final MailboxId rootId;
  final String teamEmailAddress; // root.emailTeamMailBoxes
}
```

- `mailboxScopeProvider` is Riverpod state, `WholeAccountScope` by default. A team scope is valid only while its `accountId` is the shown account, so an account switch resets it to `WholeAccountScope` unless the switch targets a team of the new account.
- A team scope never changes `ActiveAccount`, so every account reader classified in T-02 keeps its account. Push, caches and URLs of folders and emails are those of the shown account, unchanged.

### Switching

- `AccountSwitchNotifier` gets one more target, a team of an account. The rules of a switch apply (refused while a composer is open or another switch runs, input blocked, a new generation). For a team of the shown account no account is loaded: the scope changes and the team's Inbox opens.
- Into a team of another account it is one switch: the account switch to that account, then the team scope, with one generation. A failed, cancelled or timed-out account switch rolls back both, as in ADR-0114.
- Back to the whole account is the same scope change, to `WholeAccountScope`.
- A start keeps the scope like the account: `team=<rootId>` in the web URL, next to `account` on a delegated account, the last scope next to the last account in the Android and iOS app.
- Back or Forward to an entry of another scope runs the scope change. A URL folder outside the team is handled as gone. A notification tap or an intent opens the email in the account of the notification and the scope of its folder: the team for a team folder, `WholeAccountScope` otherwise.

### What the scope narrows

| Area | In a team scope |
|---|---|
| Folder tree | Only the children of the root, at the top level. No personal folders, no other team, no Starred or Action required, no labels section. The team's own Inbox is the only Inbox shown |
| Default folder | The team's Inbox (`isFirstLevelTeamSystemFolder(map, PresentationMailbox.inboxRole)`, matched by name). A team with no Inbox opens its first folder |
| Create folder | A new top-level folder goes under the team root |
| Email list, flags, move, delete | Unchanged: they already act on the folder shown |
| Search | A search with no folder is narrowed to an `OR` of `inMailbox` over the team's folders (a new filter, `inMailbox` takes one id today). A folder filter outside the team is replaced by the team |
| Composer | The identity whose email is `teamEmailAddress` is preselected. Sent, Drafts and Outbox already follow that identity (`getSentMailboxIdForComposer` and the like). If no identity has that email, the default identity is used |
| Settings | Reachable on a team of `mine`. Hidden on a team of a delegated account, like the rest of that account (ADR-0114) |
| "me" | As in the whole account: my addresses on a team of `mine`, the owner's on a team of a delegated account |

### Ended membership

- When the root is destroyed or missing from the folder list of its account (removed from the team, team deleted), the scope goes back to `WholeAccountScope` with a toast, even while a composer is open. The composer stays open, since the account does not change. A start whose `team` is gone does the same. When the delegation of that account ends, ADR-0114 switches to `mine`, which resets the scope.
- No local data is deleted: the team's folders and emails are cached under their account and go away with the normal mailbox and email cache updates.

### Switcher

Team mailboxes are the third group of the switcher ("Team mailboxes", DS-1..3, web and mobile), listed from the team roots of `mine` and, while a delegated account is shown, from the team roots of that account under its owner's name. The teams of a delegated account that is not shown are not listed, since its folders are loaded only when it is shown. While a delegated account is shown, the teams of `mine` come from the cache of `mine`, and a `Mailbox` change in `changed[mine]` refreshes them. No design system change is needed.

### Tickets

Tracked in their own issue once the work starts, after the ADR-0114 entry points.

| Id | Ticket |
|---|---|
| TM-1 | `MailboxScope`, the team target of the switch (teams of `mine` and of a delegated account), the start (`team` in the URL, last scope on mobile), Back and notification taps across scopes, ended membership |
| TM-2 | Folder tree, default folder, folder creation under the root, virtual folders and labels hidden in a team scope |
| TM-3 | Search narrowed to the team, composer identity preselected |
| TM-4 | Third group of the switcher (web and mobile), with the teams of the shown delegated account, and its E2E scenarios |

## Consequences

- No new account, no new push channel, no cache change: a team scope only narrows what the views of the shown account show and search.
- Only the folder tree, the default folder, folder creation, search and the composer read the scope. The readers of ADR-0114 T-02 keep their account.
- The whole-account view of every account keeps its "Team mailboxes" section as today.
