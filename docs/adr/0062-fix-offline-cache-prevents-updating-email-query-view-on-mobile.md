# 62. Fix offline cache prevents updating email query view on mobile

Date: 2025-04-03

## Status

- Issues:
  - [Offline cache prevents updating email query view #3507](https://github.com/linagora/tmail-flutter/issues/3507)

## Context

- When we perform too many actions on multiple emails `(Mark as read, mark as star, move, delete, etc.)`, 
`Email/get` from the value of `Email/changes` will throw an error.

```json
[
    "error",
    {
        "type": "requestTooLarge",
        "description": "Too many items in an email read at level FULL. Got 183 items instead of maximum 100."
    },
    "c2"
]
```

- Some emails in the `update` of the `Email/change` response were not found in `Email/get`. But we still update newState of email.


## Decision

- To solve this problem we propose the most optimal solution which is
We will add a `Clean cache & Get all emails` action when the user performs `Pull down to refresh`

Now when user performs `Pull down to refresh` action. There will be 2 actions performed
- If the drag distance is shorter `< 200px` will perform `Refresh` action (`Just call get all emails`)
- If the drag distance is shorter `>= 200px` will perform `Deep Refresh` action (`Call clean cache and get all emails`)


## Consequences

- No lost emails when displayed on list on mobile
