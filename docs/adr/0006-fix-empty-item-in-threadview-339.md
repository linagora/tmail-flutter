# 6. Fix Empty item in ThreadView (#339)

Date: 2022-04-27

## Status

- Issue: [#339](https://github.com/linagora/tmail-flutter/issues/339)

## Context

- Root cause: updated item fetch from `/changes` is inserted to `Hive` database without full properties

## Decision

- Not insert updated item to cache if cache not hit.

## Consequences

- No more items in the list without information
