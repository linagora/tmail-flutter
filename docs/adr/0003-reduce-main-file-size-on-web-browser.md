# 3. Reduce main file size on Web Browser

Date: 2022-04-04

## Status

Accepted

## Context

- Reduce `main.dart.js` file size at web browser startup

## Decision

- We use [Lazily loading](https://dart.dev/guides/language/language-tour#lazily-loading-a-library) which could split your code in multiple JavaScript files

## Consequences

- Significantly reduce the size of the generated `main.dart.js` file.
