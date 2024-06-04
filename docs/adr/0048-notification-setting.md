# 48. Notification setting

Date: 2024-06-04

## Status

Accepted

## Context

- User need a way to tell and change notification configuration in-app
- However, no app is allowed directly change the device's settings by design
- With other third-party mails, app will redirect users to system settings if they desire to change it

## Decision
Twake Mail will follow the method of other third-party mails

## Consequences
The permission's status will always reflect system's configuration, and the system's configuration will be the single source of truth.