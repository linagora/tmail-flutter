# 70. Email/get batch size limit fix for JMAP servers

Date: 2026-01-20

## Status

Accepted

## Context

When synchronizing emails via WebSocket state changes, the application uses `Email/changes` to get lists of created, updated, and destroyed email IDs, followed by `Email/get` to fetch the actual email data.

The original implementation used JMAP reference paths (`#ids` with `resultOf`) to chain these requests, allowing the server to automatically pass IDs from `Email/changes` to `Email/get`. However, this approach has two critical issues:

1. **Server limit violation**: Some JMAP servers (notably Stalwart) ignore the `maxChanges` parameter and return all changed IDs. When these IDs exceed the server's `maxObjectsInGet` limit (e.g., 50 for Stalwart), the `Email/get` request fails with "too many IDs" error.

2. **Unnecessary data fetching**: For push notifications, the application only displays up to 5 new emails (`FcmConstants.MAX_NUMBER_NEW_EMAILS_RETRIEVED`), but was fetching all created emails regardless of this UI constraint.

Related: ADR 0037 documented the "one-by-one" approach for full email fetching, but the batch fetching for partial properties still had this issue.

## Decision

1. **Separate requests instead of reference paths**: Replace the chained JMAP request pattern with separate HTTP requests:
   - First request: `Email/changes` to get the list of changed IDs
   - Subsequent requests: `Email/get` in batches respecting `maxObjectsInGet`

2. **Dynamic batch sizing**: Read the server's `maxObjectsInGet` capability and use it as the batch size, with a safe default of 50.

3. **Early termination optimization**: Add `maxCreatedEmailsToFetch` parameter to `getChanges()` to limit how many created emails are fetched:
   - FCM notifications use limit of 5 (matching UI constraint)
   - Other callers can specify their own limits or fetch all

4. **Reusable batched fetch method**: Extract `getEmailsByIdsBatched()` into `MailAPIMixin` for reuse across the codebase.

## Implementation

```dart
// In ThreadAPI.getChanges():
// Step 1: Get changed IDs (separate request)
final changesResult = await _getEmailChangesOnly(session, accountId, sinceState);

// Step 2: Batch fetch emails respecting maxObjectsInGet
final result = await getEmailsByIdsBatched(
  emailIds: createdIds,
  properties: propertiesCreated,
  maxEmailsToFetch: maxCreatedEmailsToFetch, // Optional limit
);
```

```dart
// In FCMRepositoryImpl.getNewReceiveEmailFromNotification():
final changesResponse = await _threadDataSource.getChanges(
  session, accountId, currentState,
  propertiesCreated: Properties({EmailProperty.id, EmailProperty.receivedAt}),
  maxCreatedEmailsToFetch: FcmConstants.MAX_NUMBER_NEW_EMAILS_RETRIEVED, // Limit to 5
);
```

## Consequences

### Positive

- **Compatibility**: Works with all JMAP servers regardless of how they handle `maxChanges`
- **Performance**: Fetches only the emails actually needed for the UI
- **Resilience**: Gracefully handles large numbers of changed emails
- **Maintainability**: Batching logic is centralized in `MailAPIMixin`

### Negative

- **Additional HTTP requests**: Requires multiple round-trips instead of a single chained request
- **Slightly more complex code**: Separate request handling vs. reference path chaining

### Trade-offs

The additional HTTP requests are acceptable because:
1. They prevent complete failure when ID counts exceed limits
2. The optimization for push notifications reduces total data transferred
3. Reference paths were unreliable across different JMAP implementations

## Files Changed

- `lib/features/base/mixin/mail_api_mixin.dart` - Added `getEmailsByIdsBatched()` method
- `lib/features/thread/data/network/thread_api.dart` - Refactored `getChanges()` to use separate requests
- `lib/features/thread/data/datasource/thread_datasource.dart` - Added `maxCreatedEmailsToFetch` parameter
- `lib/features/push_notification/data/repository/fcm_repository_impl.dart` - Uses new limit parameter
