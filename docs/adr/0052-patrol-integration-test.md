# 52. Patrol integration test

Date: 2024-04-10

## Status

Accepted

## Context

- A need for integration testing for Twake Mail mobile arised.
- The testing tool must be able to handle native UI and webview.

## Decision

- Patrol was chosen to write and test Twake Mail.

## Consequences

- Developers are now able to integration test Twake Mail
- Set up:
  - Run `dart pub global activate patrol_cli` to enable Patrol CLI
  - Test individual test locally with `patrol test -t path/to/test/dart/file`
  - Test every tests in a directory with `patrol test -t path/to/directory`
  - Remember to use `dart-define` neccessary for each test command
  - Read more about Patrol in [Patrol homepage](https://patrol.leancode.co/)
