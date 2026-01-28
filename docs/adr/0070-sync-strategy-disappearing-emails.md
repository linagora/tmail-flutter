# 0070 - Synchronization Strategy for Disappearing Emails (Cache Invalidation & Query Logic)

## Status

Accepted

## Context

We have identified a recurring synchronization issue where emails disappear from the user's Inbox view despite still existing on the server. This issue affects the reliability of the application and confuses users.

### The Scenario (Observed Behavior)

The issue typically manifests in the following sequence, as reported in [Issue #4274](https://github.com/linagora/tmail-flutter/issues/4274):

1. **Day 1:** A user receives "Email A" in their Inbox and reads it.
2. **Day 2:** The user opens the application, but "Email A" is no longer visible in the mail list.
3. **Troubleshooting attempts:**
* Switching mailboxes (e.g., to Sent and back to Inbox) does not restore the email.
* Clicking the standard UI "Refresh" button has no effect.
* **Crucially:** The email *can* be found using the Search function (proving data existence).


4. **Resolution:** The user is forced to **log out and log in**, which magically restores the email to the list.

### Root Cause Analysis

The behavior indicates a desynchronization between the local application state (Cache/UI) and the server. The fact that Logout/Login resolves the issue confirms that the local session cache holds stale or corrupted list data that standard soft-refreshes fail to invalidate.

## Decision

To resolve this, we are standardizing the **Cache Invalidation** triggers and introducing an **Environment-Controlled Query Strategy** for mailbox switching.

### 1. Standardization of Cache Invalidation Triggers

We define specific "Hard Actions" that must strictly trigger a complete cache clearance to ensure data freshness. We move away from "soft updates" for these specific interactions to guarantee the UI reflects the server state.

* **F5 (Browser Refresh):**
* **Action:** Triggers `clear cache`  Reloads application.


* **Logout:**
* **Action:** Triggers `clear cache` (Session wipe)  Redirects to login.


* **UI Refresh Button:**
* **Action:** Triggers `clear cache` explicitly for the current view  Re-fetches list from server.
* *Rationale:* Previously, this might have only requested a delta update. Now it forces a clean slate fetch for the current list.



### 2. Configurable Mailbox Switching Logic

The "Switch Mailbox" action triggers a data query. To prevent the specific conflict or race condition causing the disappearance of emails, we are introducing a feature flag to control the query behavior.

We will introduce a new environment variable `FORCE_EMAIL_QUERY`.

**Configuration:**
In the application's environment file (`env.file`):

```properties
# Controls the query strategy when switching mailboxes
FORCE_EMAIL_QUERY=false

```

**Logic Flow:**

* When a user switches mailboxes, the system checks the `FORCE_EMAIL_QUERY` flag.
* **Set to `false` (The Fix):** The application will utilize the optimized query logic (relying on the refined cache/fetch strategy) rather than forcing a heavy query that may be contributing to the state inconsistency observed in the issue.

## Consequences

### Positive

1. **Reliability:** Directly addresses the "disappearing email" bug, ensuring users always see their actual messages.
2. **User Experience:** Eliminates the need for users to perform a disruptive Logout/Login cycle to restore their view.
3. **Maintainability:** By externalizing the logic to an environment variable (`FORCE_EMAIL_QUERY`), we allow DevOps/Developers to toggle query behaviors in different environments without altering source code.
4. **Clarity:** clearly defines what "Refresh" implies for the system (Clear Cache vs. Delta Update).

### Negative

1. **Performance Overhead:** Forcing a `clear cache` on the UI Refresh button is more resource-intensive than a delta update, potentially leading to slightly longer loading spinners for users with large mailboxes.
2. **Configuration Risk:** Incorrectly setting `FORCE_EMAIL_QUERY` in production environments could revert the fix or alter application behavior unexpectedly.

## Implementation Steps

1. **Event Handling Update:**
* Refactor the **Refresh Button**, **F5**, and **Logout** handlers to ensure they explicitly call the `clearCache()` method before fetching new data.


2. **Environment Configuration:**
* Add `FORCE_EMAIL_QUERY` to the default `env.file` and set it to `false`.
* Update the `AppConfig` or `Environment` class to read this variable.


3. **Mailbox Logic Update:**
* Modify the `switchMailbox` function to check the boolean value of `FORCE_EMAIL_QUERY` and apply the corresponding query logic.


4. **Verification:**
* Reproduce the scenario (Read email -> Simulate wait/stale state -> Verify visibility).



## References

* **GitHub Issue:** [linagora/tmail-flutter#4274](https://github.com/linagora/tmail-flutter/issues/4274)