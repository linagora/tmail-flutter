Closes #4869

## What changed
Every search `Email/query` (new search, load-more, refresh) goes through `SearchEmailNotifier.execute`. This PR makes that the single place that prevents duplicates:

- Each execution now resolves a `SearchQueryKey` (intent type, account, resolved filter, trash/spam ids, properties, collapseThreads, limit, position, lastEmailId). Two executions with equal keys would send the exact same `Email/query`.
- If a **new search** or **load-more** resolves to the same key as the **latest** request still in flight, it joins that request and gets the same result future. No second query is sent.
- Nothing is lost:
  - A superseded request (no longer the latest) is never joined, because its result is dropped.
  - Once a query completes, an identical search queries again, so a user who re-runs a search still gets fresh results.
  - **Websocket refreshes are never joined**: a refresh must see the server state that triggered it, and an earlier in-flight query may predate that state.

## Root cause
Reading the code, I could not isolate the one caller that dispatches twice. Every trigger path I followed (search bar submit, advanced search, quick filters, URL search, refresh coordinator) dispatches one intent. No Flutter toolchain was available to trace the requests at runtime. The fix therefore sits at the single executor seam, so the duplicate is dropped whatever triggers it.

## Tests
`search_email_notifier_test.dart`:
- New tests:
  - two identical in-flight new searches → 1 query
  - two identical in-flight load-mores → 1 query
  - an identical search after the first one completes → queries again
  - a new search with a different filter → not joined
  - refreshes → never joined
  - a new search superseded by a refresh → not joined
- Changed test: `a stale response never overwrites a newer result` used to fire two *identical* concurrent searches, which are now coalesced by design. Its two searches now use different filters, so it still covers the stale-response case.

**Not run:** these tests were not run, because this environment has no Flutter/Dart SDK. CI needs to confirm them.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

---
*Generated automatically*
