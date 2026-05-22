# 91. Fix auto-load-more infinite loop on large-screen devices

Date: 2026-05-22

## Status

Accepted

## Context

On Android 10 Pro XL, opening a mailbox triggered an infinite chain of load-more requests. Log confirmed:

```text
ThreadController::_isNonWebAutoLoadMore():
  maxScroll = 785.04, viewport = 816.33, isAutoLoadMore = true
```

Root cause: the condition `maxScrollExtent <= viewportDimension` is equivalent to *content height ≤ 2× viewport*, so on a large screen where 20 emails fill ~1.9× the viewport, auto-load kept firing after every page until the server ran out of emails. Smaller phones were unaffected because their content overflows 2× viewport after the first page.

## Decision

**Non-web:** Change auto-load threshold from `maxScrollExtent <= viewportDimension` to `maxScrollExtent <= 0` — trigger only when content has not yet filled the viewport.

**Web:** Change estimated-height check from `totalHeight <= viewport` to `totalHeight < viewport` (strict) to avoid an extra load at the exact boundary.

**Pagination:** Replace `canLoadMore = emailList.isNotEmpty` with `canLoadMore = emailList.length >= maxCountEmails`. A partial-page response means no more pages exist — no need to show Load More or make an empty request.

Both detection methods extracted into `AutoLoadMorePolicy` for testability.

## Consequences

- Infinite loop fixed on large-screen Android. Normal phones unaffected — the new condition only changes behaviour when content fits within the viewport, which doesn't occur on smaller screens after the first page.
- Load More button hidden correctly when mailbox has fewer emails than one page.
- Unit tests and widget tests added for all three logic changes.
