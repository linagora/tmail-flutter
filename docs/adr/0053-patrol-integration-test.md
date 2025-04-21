# 53. Patrol integration test

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
  - Install ngrok and jq
  - Open docker and Android emulator/connect Android device
  - Remember to use `dart-define` neccessary for each test command
  - Test individual test locally by edit `scripts/patrol-local-integration-test-with-docker.sh`
    - Replace `patrol test -v` with `patrol test -v -t path/to/test/file`
    - Run the `scripts/patrol-local-integration-test-with-docker.sh`
  - Test every tests locally by running `scripts/patrol-local-integration-test-with-docker.sh` script
  - Read more about Patrol in [Patrol homepage](https://patrol.leancode.co/)

## Limitations

- Backend docker container is initiated before Patrol tests run, and close after all tests have run. This lead to no data isolation between tests
- Patrol gives no way of accessing Docker from system, due to when it runs, it bundle all tests into a single apk, and apk cannot access the system's terminal
- Tried https://github.com/testcontainers/testcontainers-java but also failed, with the same reason as Patrol.
