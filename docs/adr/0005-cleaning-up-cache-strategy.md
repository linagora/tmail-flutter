# 5. Cleaning up cache strategy

Date: 2022-04-27

## Status

Accepted

## Context

- Cleaning up the emails in cache which email have `receivedAt` was over 30 days from today
- Cleaning up was triggered when user START the app on the first time of each day 

## Decision

- Cleaning up the emails in cache which email have `receivedAt` was over 10 days from today
- Cleaning up was triggered when every time user START the app 

## Consequences

- Cache is clean up more usually 
- Reduce the device's storage for the cache, may useful for user who have too many mails
