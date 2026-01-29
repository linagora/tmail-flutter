# 70. Email disappear from list - Issue #4274

Date: 2026-01-26

## Status

Proposed

## Context

### Issue Description
- **Issue**: [#4274 - Sometimes, Email disappear in email list](https://github.com/linagora/tmail-flutter/issues/4274)
- **Behavior**: 
  - User receives an email in inbox, reads it
  - Next morning, the email disappears from the mail list
  - Switching mailbox + refresh has no effect
  - The email can be seen with search
  - Logout/login makes the email magically reappear
- **Frequency**: Sometimes, affecting some users

### Root Cause Analysis

The problem occurs in the `combine()` method of `ListPresentationEmailExtension` used in `_refreshChangesAllEmailSuccess()` of `ThreadController`.

#### Problem Flow:

1. **Initial Display**: The user has a displayed email list (`emailsInCurrentMailbox`) that may contain more emails than the `defaultLimit` (20 emails).

2. **Refresh via WebSocket**: When a `refreshChanges` is triggered (via WebSocket or other mechanism), the `refreshChanges()` method in `ThreadRepositoryImpl` is called:
   ```dart
   final newEmailResponse = await Future.wait([
     mapDataSource[DataSourceType.local]!.getAllEmailCache(
       accountId,
       session.username,
       inMailboxId: emailFilter?.mailboxId,
       sort: sort,
       filterOption: emailFilter?.filterOption
     ),
     stateDataSource.getState(accountId, session.username, StateType.email)
   ]).then((List response) {
     return EmailsResponse(emailList: response.first, state: response.last);
   });

   if (!newEmailResponse.hasEmails()
       || (newEmailResponse.emailList?.length ?? 0) < ThreadConstants.defaultLimit.value) {
     // Fetch from network
   } else {
     yield newEmailResponse.copyWith(emailChangeResponse: emailChangeResponse);
   }
   ```

3. **Cache Problem**: If the local cache has >= `defaultLimit` (20) emails, `refreshChanges` returns only those. If an email was in the displayed list but is no longer in the cache (e.g., moved out of the top 20 after sorting, or modified in a way that removes it from the cache), it will not be returned.

4. **`combine()` Problem**: In `_refreshChangesAllEmailSuccess()`, the `combine()` method is called:
   ```dart
   final emailsBeforeChanges = mailboxDashBoardController.emailsInCurrentMailbox;
   final emailsAfterChanges = success.emailList;
   final newListEmail = emailsAfterChanges.combine(emailsBeforeChanges);
   ```

   Current `combine()` method:
   ```dart
   List<PresentationEmail> combine(List<PresentationEmail> listEmailBefore)  {
     return map((presentationEmail) {
       if (presentationEmail.id != null) {
         final emailBefore = listEmailBefore.findEmail(presentationEmail.id!);
         if (emailBefore != null) {
           return presentationEmail.toSelectedEmail(selectMode: emailBefore.selectMode);
         } else {
           return presentationEmail;
         }
       } else {
         return presentationEmail;
       }
     }).toList();
   }
   ```

   **The Problem**: This method only maps over `emailsAfterChanges`. It only keeps emails that are in `emailsAfterChanges`. If an email was in `emailsBeforeChanges` but is no longer in `emailsAfterChanges`, it completely disappears.

5. **Result**: Emails that were displayed but are no longer in the cache disappear from the list.

### Reproduction Scenarios

1. **Scenario 1 - Scroll and refresh**:
   - User scrolls and loads 30 emails (more than the defaultLimit of 20)
   - A refreshChanges is triggered
   - Cache returns only the first 20 emails
   - Emails 21-30 disappear

2. **Scenario 2 - Email moved out of cache**:
   - User has 25 emails displayed
   - An email is modified (e.g., moved to another mailbox, or modified in a way that changes its sort order)
   - The email falls out of the top 20 in the cache
   - A refreshChanges is triggered
   - The email disappears from the list

3. **Scenario 3 - Partially synchronized cache**:
   - Local cache is not fully synchronized with the server
   - A refreshChanges returns only emails from the cache
   - Emails that were displayed but are no longer in the cache disappear

4. **Scenario 4 - Refresh doesn't recover missing email**:
   - An email disappears from the list (scenario 1, 2, or 3)
   - User performs a pull-to-refresh
   - `getAllEmail()` detects that cache has >= 20 emails
   - It doesn't fetch from network and returns only local cache
   - Missing email is still not recovered
   - **Only logout/login solves the problem** because cache is cleared and `getAllEmail()` fetches from network

## Decision

### Problem Identified in Two Parts

The problem has two distinct but related causes:

1. **`combine()` Problem**: Displayed emails that are absent from cache disappear during a `refreshChanges`
2. **`getAllEmail()` Problem**: If cache has >= 20 emails, it doesn't fetch from network, even during a manual refresh

### Proposed Solution

#### Solution 1: Modify `combine()` (Recommended - Priority 1)

Modify the `combine()` method to preserve emails that were in `emailsBeforeChanges` but are no longer in `emailsAfterChanges`.

#### Option 1: Merge the two lists (Recommended)

Modify `combine()` to include all emails from `emailsBeforeChanges` that are not in `emailsAfterChanges`:

```dart
List<PresentationEmail> combine(List<PresentationEmail> listEmailBefore) {
  final result = <PresentationEmail>[];
  final emailsAfterMap = <EmailId, PresentationEmail>{};
  
  // Create a map of emails after for fast access
  for (final email in this) {
    if (email.id != null) {
      emailsAfterMap[email.id!] = email;
    }
  }
  
  // Add all emails after (with selectMode preservation if present before)
  for (final emailAfter in this) {
    if (emailAfter.id != null) {
      final emailBefore = listEmailBefore.findEmail(emailAfter.id!);
      if (emailBefore != null) {
        result.add(emailAfter.toSelectedEmail(selectMode: emailBefore.selectMode));
      } else {
        result.add(emailAfter);
      }
    } else {
      result.add(emailAfter);
    }
  }
  
  // Add emails that were before but are no longer after
  for (final emailBefore in listEmailBefore) {
    if (emailBefore.id != null && !emailsAfterMap.containsKey(emailBefore.id!)) {
      result.add(emailBefore);
    }
  }
  
  return result;
}
```

#### Option 2: Modify `refreshChanges` to always return all displayed emails

Modify `refreshChanges` in `ThreadRepositoryImpl` to include emails that were displayed but are no longer in the cache. However, this would require passing `emailsBeforeChanges` to `refreshChanges`, which creates coupling between the presentation layer and the repository layer.

#### Option 3: Use `getAllEmail` instead of `refreshChanges` when necessary

When `refreshChanges` returns fewer emails than those displayed, perform a complete `getAllEmail`. However, this can be costly in terms of performance.

#### Solution 2: Modify `getAllEmail()` to force network refresh (Priority 2)

Modify `getAllEmail()` to detect when a manual refresh is requested and force a network request even if cache has >= 20 emails.

**Option A**: Add a `forceNetwork` parameter to `getAllEmail()`:
```dart
Stream<EmailsResponse> getAllEmail(
  Session session,
  AccountId accountId,
  {
    bool forceNetwork = false, // New parameter
    // ... other parameters
  }
) async* {
  // ...
  if (forceNetwork || !localEmailResponse.hasEmails()
      || (localEmailResponse.emailList?.length ?? 0) < ThreadConstants.defaultLimit.value) {
    // Fetch from network
  }
}
```

**Option B**: Always synchronize with network during manual refresh, even if cache has >= 20 emails:
- Modify `onRefresh()` to call `getAllEmail()` with `getLatestChanges: true` and force synchronization
- Or modify the logic to always perform `_synchronizeCacheWithChanges()` even if cache has >= 20 emails

### Recommendation

**Solution 1 (Option 1)** is recommended as priority because:
- It preserves displayed emails without requiring additional network requests
- It maintains separation of concerns (merge logic stays in presentation layer)
- It's simple to implement and test
- It doesn't break existing API
- It solves the main email disappearance problem

**Solution 2** can be added as a complement to improve robustness, but it requires more modifications and may have performance impact.

## Consequences

### Advantages
- Displayed emails will no longer disappear from the list
- User experience will be improved
- No additional network requests needed
- Simple and maintainable solution

### Disadvantages
- The list may temporarily contain emails that are no longer in the cache
- These emails will be updated during the next complete `getAllEmail`
- Need to handle the case where an email has been deleted (it should not be preserved)

### Tests

Reproducible tests have been created:
- `test/model/extensions/list_presentation_email_combine_test.dart`: Unit test of the `combine()` method
- `test/features/thread/presentation/controller/thread_controller_email_disappear_test.dart`: Integration test of the problem

### Migration

The modification of `combine()` is backward compatible because:
- It preserves existing behavior for emails that are in `emailsAfterChanges`
- It only adds preservation of emails that were in `emailsBeforeChanges` but are no longer in `emailsAfterChanges`

### Notes

- We will also need to handle the case where an email has been deleted (destroyed) - it should not be preserved
- We may need to add logic to limit the number of preserved emails to avoid overly long lists
- This solution doesn't solve the problem if the cache is completely out of sync, but it prevents disappearance of already displayed emails

## References

- [Issue #4274](https://github.com/linagora/tmail-flutter/issues/4274)
- [ADR #17 - Email cache guideline](./0017-email-cache-guideline.md)
- [ADR #62 - Fix offline cache prevents updating email query view on mobile](./0062-fix-offline-cache-prevents-updating-email-query-view-on-mobile.md)
