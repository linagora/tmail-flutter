# 117. Folder load-more with collapsed threads

Date: 2026-10-26

## Status

Proposed

## Context

- With thread view on (web, forced query), a folder row stands for a whole thread.
- Load-more paged by date (`receivedAt` of the last row). Older replies of listed threads
  matched that bound, so the same thread was listed twice.
- Load-more state was split across `canLoadMore`, `loadingMoreStatus` and stream callbacks, so
  late pages and websocket refreshes could append rows to a list that had been replaced.

## Decision

- `FolderLoadMore` owns the lifecycle: `Idle`, `InFlight(token)`, `Done`, `Deferred(pending)`.
  A response is applied only if its token is still in flight; leaving `InFlight` drops it.
- `FolderPaging` holds what differs by mode, chosen on each read from one callback:
  - `ByPosition` (collapsed): `position = listed rows + skipped server rows`; rows match by
    `threadId ?? id`; a short page ends the folder.
  - `ByDate` (not collapsed): unchanged; rows match by id; the folder ends on a short page
    or a page with nothing new.
- A collapsed or starred-folder websocket refresh holds load-more (`Deferred`); a page asked
  for or dropped meanwhile is sent once the refresh lands, against the new rows.
- Reload from the top, pull-to-refresh and a new search reset load-more to `Idle`.

## Consequences

- Each thread is listed once.
- Behaviour locked by tests:
  - `model/folder_load_more_test.dart`: transitions, stale tokens, hold/release, cursors,
    end-of-folder rules, row keys, mode switch.
  - `controller/thread_controller_folder_load_more_test.dart`: thread view off unchanged
    (date bound, id dedup, guards, failures, refreshes).
  - `controller/thread_controller_collapsed_folder_load_more_test.dart`: offset paging,
    skipped replies and shifted pages, retry, stale pages, refresh hold/resume, read limit,
    starred and user refreshes, search start drops folder pages.
  - `controller/thread_controller_test.dart`: short collapsed first page ends the folder.
  - Web e2e `collapsed_threads_*`: short page, new threads before/during load-more, deletes,
    unread filter, pull and deep refresh, starred refresh, tall screen, search-more.
