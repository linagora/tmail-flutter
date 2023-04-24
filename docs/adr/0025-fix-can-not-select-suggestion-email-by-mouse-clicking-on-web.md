# 25. Fix can't select suggestion email by mouse clicking on web

Date: 2023-04-24

## Status

- Issue: [#1576](https://github.com/linagora/tmail-flutter/issues/1576)
- Issue: [#1753](https://github.com/linagora/tmail-flutter/issues/1753)

## Context

Tap events are not being simulated to overlay on the `Web/Desktop` but work fine on mobile devices. This worked fine until the previous release stable `3.3`

## Root cause

Because the thing that the overlay is attached to is a `TextField`, so in order to keep from unfocused the text field when tapping outside of it, you need to tell the overlay widget that it's part of the TextField for purposes of the `Tap outside` behavior

## Decision

- Try wrapping a `TextFieldTapRegion` around the `Material` in the overlay. So that when the tap arrives, it's considered `inside` of the text field.

## Consequences

- Widget on overlay work fine.
