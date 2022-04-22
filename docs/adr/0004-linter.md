# 3. Integrate linter into app

Date: 2022-04-22

## Status

Accepted

## Context

- Use linter to encourage good coding practices
- Helps optimize and increase application performance

## Decision

- To use we follow these steps:
    + Depend on this package as a `dev_dependency` by running `flutter pub add --dev flutter_lints`.
    + Create an `analysis_options.yaml` file at the root of the package (alongside the `pubspec.yaml` file) and include: `package:flutter_lints/flutter.yaml` from it.

## Official document

- [flutter_lints](https://pub.dev/packages/flutter_lints)

## Consequences

- The code is written standard according to the linter toolkit. Performance is improved.
