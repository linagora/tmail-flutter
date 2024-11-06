# 53. Web socket data synchronization

Date: 2024-11-10

## Status

Accepted

## Context

- Currently Twake Mail web use Firebase Cloud Messaging to sync data on real time
- JMAP already implemented web socket push, which is more optimized for web

## Decision

- Web socket is implemented for real time update data for Twake Mail web

## Consequences

- Twake Mail web now no longer depends on Firebase Cloud Messaging, using web socket to update users' latest data
