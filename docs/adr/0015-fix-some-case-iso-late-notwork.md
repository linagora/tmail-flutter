# 15. Fix some case isolate notwork (#867)

Date: 2022-08-28

## Status

- Issue: Fix some case isolate notwork

## Context

- Root cause: When you make a request through this client, it opens a connection to the HTTP server,
and may maintain the connection after the request completes. The HttpClient cannot be sent through
a SendPort of IsoLate when it has open connections.

## Decision

- Make a new HttpClient to send through the compute function.

## Consequences

- isolate working like normal