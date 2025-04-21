# 59. Web Socket Ping Strategy

Date: 2024-12-16

## Status

Accepted

## Context

- Echo ping method takes too much resources from the server
- Server implemented ping frame

## Decision

- Twake Mail no longer have to implement Echo ping
- Browser will automatically send pong frame as default implementation
- Echo ping will still be left as an option in `env.file` through `WS_ECHO_PING`
  - Set it to `true` if you want to use Echo ping
  - Set it to `false` or left it as is if you don't want to use Echo ping

## Consequences

- Server resources used will be reduced
