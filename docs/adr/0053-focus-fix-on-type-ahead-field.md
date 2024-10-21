# 53. Focus fix on TypeAheadField

Date: 2024-10-21

## Status

Accepted

## Context

- Twake Mail use flutter_typeahead library to suggest result when user type in text field
- TypeAheadField of flutter_typeahead's logic of Focus handling has error, which results in user cannot use "Tab" key to move from one text field to another

## Decision

- Fork the library and update the source code at https://github.com/linagora/flutter_typeahead/tree/fix/5.0.2-textfield-tab, then use the fork dependency
- Open an issue at https://github.com/AbdulRahmanAlHamali/flutter_typeahead/issues/607

## Consequences

- The Focus is properly handled
- Fork dependency will be replaced by official fix once the above issue is resolved
