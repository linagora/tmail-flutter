# 21. Manage Changelog by Cider

Date: 2023-04-05

## Status

Accepted

## Context

- We did not manage Changedlog with the standard way

## Decision

Use Cider (https://pub.dev/packages/cider) to easier to manage changelog to follow [Changelog](https://keepachangelog.com/en/1.1.0/) format 

## Consequences

- We should add to the change log some `type` of change: `added`, `changed`, `deprecated`, `removed`, `fixed`, `security` in each PR with command
```
cider log <type> <description>
```

- In release phase, change the version in `pubspec.yaml` and dont forget to change the tag in cider template in the same file

- Then run:
```
cider release
```