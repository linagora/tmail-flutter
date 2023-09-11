# 30. Fix refresh token with OIDC using `QueuedInterceptor`

Date: 2023-09-11

## Status

- Issue: 

[1974](https://github.com/linagora/tmail-flutter/issues/1974)

## Context

- Requests still return `401` after retrieving a new token. The application automatically logs out

## Root cause

- When executing tasks concurrently, they are pushed into the `Queue` along with the old `header` values (the old authentication is retained). 
So when the first request receives a `401` error and tries to get a new token, it will be updated with the new authentication header value.

## Decision

- Use `QueuedInterceptor` to serialize `requests/responses/errors` before they enter the interceptor. 
If there are multiple concurrent requests, the request is added to a queue before entering the interceptor. 
Only one request at a time enters the interceptor, and after that request is processed by the interceptor, the next request will enter the interceptor.
- Try to make a `retry` request up to 3 times when receiving a `401` error. Aims to update the new token value on `memmory` to requests in the `queue`.

## Consequences

- The following `requests` were completed successfully. The application is not automatically logged out
