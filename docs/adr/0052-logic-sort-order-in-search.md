# 52. Logic Sort Order in search

Date: 2024-10-07

## Status

Accepted

## Context

- Using `sort` by `Subject`, `Sender` or `Relevance` together with `filter` by `conditions` with `before` or `after` date results in incorrect `Email/query` response results.
- ISSUE: https://github.com/linagora/tmail-flutter/pull/2360

```json
{
    "using": [
        "urn:ietf:params:jmap:core",
        "urn:ietf:params:jmap:mail",
        "urn:apache:james:params:jmap:mail:shares"
    ],
    "methodCalls": [
        [
            "Email/query",
            {
                "accountId": "3cd281b49cxxxxxxxxexx",
                "filter": {
                    "operator": "AND",
                    "conditions": [
                        {
                            "before": "2023-11-10T16:46:32.000Z",
                            "text": "firstname99"
                        }
                    ]
                },
                "sort": [
                    {
                        "isAscending": true,
                        "property": "subject"
                    }
                ],
                "limit": 20
            },
            "c0"
        ],
        [
            "Email/get",
            {
                "accountId": "3cd281b49cxxxxxxxxexx",
                "#ids": {
                    "resultOf": "c0",
                    "name": "Email/query",
                    "path": "/ids/*"
                },
                "properties": [
                    "id",
                    "subject",
                    "from",
                    "to",
                    "cc",
                    "bcc",
                    "keywords",
                    "size",
                    "receivedAt",
                    "sentAt",
                    "preview",
                    "hasAttachment",
                    "replyTo",
                    "mailboxIds",
                    "header:X-MEETING-UID:asText"
                ]
            },
            "c1"
        ]
    ]
}
```

## Decision

Brief the logic flows when click `Sort Order` in search:

- To sort by `Subject`, `Sender` or `Relevance` we will have to use the `position` property of `filter`

```json
{
    "using": [
        "urn:ietf:params:jmap:core",
        "urn:ietf:params:jmap:mail",
        "urn:apache:james:params:jmap:mail:shares"
    ],
    "methodCalls": [
        [
            "Email/query",
            {
                "accountId": "3cd281b49cxxxxxxxxexx",
                "filter": {
                    "operator": "AND",
                    "conditions": [
                        {
                            "text": "firstname99"
                        }
                    ]
                },
                "sort": [
                    {
                        "isAscending": true,
                        "property": "subject"
                    }
                ],
                "limit": 20,
                "position": 20
            },
            "c0"
        ],
        [
            "Email/get",
            {
                "accountId": "3cd281b49cxxxxxxxxexx",
                "#ids": {
                    "resultOf": "c0",
                    "name": "Email/query",
                    "path": "/ids/*"
                },
                "properties": [
                    "id",
                    "subject",
                    "from",
                    "to",
                    "cc",
                    "bcc",
                    "keywords",
                    "size",
                    "receivedAt",
                    "sentAt",
                    "preview",
                    "hasAttachment",
                    "replyTo",
                    "mailboxIds",
                    "header:X-MEETING-UID:asText"
                ]
            },
            "c1"
        ]
    ]
}
```

- As for `sort` by `Most Recent` and `Oldest` we need to use `before` and `after` in `conditions` of `filter`

```json
{
    "using": [
        "urn:ietf:params:jmap:core",
        "urn:ietf:params:jmap:mail",
        "urn:apache:james:params:jmap:mail:shares"
    ],
    "methodCalls": [
        [
            "Email/query",
            {
                "accountId": "3cd281b49cxxxxxxxxexx",
                "filter": {
                    "operator": "AND",
                    "conditions": [
                        {
                            "before": "2023-11-10T16:46:32.000Z",
                            "text": "firstname99"
                        }
                    ]
                },
                "sort": [
                    {
                        "isAscending": true,
                        "property": "receivedAt"
                    }
                ],
                "limit": 20
            },
            "c0"
        ],
        [
            "Email/get",
            {
                "accountId": "3cd281b49cxxxxxxxxexx",
                "#ids": {
                    "resultOf": "c0",
                    "name": "Email/query",
                    "path": "/ids/*"
                },
                "properties": [
                    "id",
                    "subject",
                    "from",
                    "to",
                    "cc",
                    "bcc",
                    "keywords",
                    "size",
                    "receivedAt",
                    "sentAt",
                    "preview",
                    "hasAttachment",
                    "replyTo",
                    "mailboxIds",
                    "header:X-MEETING-UID:asText"
                ]
            },
            "c1"
        ]
    ]
}
```

## Consequences

- Any changes to the `Sort Order` logic in search must be updated in this ADR.
