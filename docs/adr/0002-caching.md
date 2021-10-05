# 2. Caching

Date: 2021-10-05

## Status

Accepted

## Context

- Client always make requests to back-end to refresh the data, what put a lot of pressure on it.
- User need to wait a long time to see the mailbox and email.

## Decision

- Caching the data with the [Hive](https://github.com/hivedb/hive) dependencies 
Hive is a lightweight and blazing fast key-value database written in pure Dart. It support cross-platform: mobile, desktop and browser

- `changes` method allows a client to efficiently update the state of data (Mailbox and Email)

## Consequences

- Minimizing the requests to the back-end 
- Reducing the latency in the client

## Follow up works

- Pre-loading the bodies of the some latest unread messages
