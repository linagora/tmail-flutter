# 25. Hide Horizontal scroll bar in Email detail view

Date: 2023-04-24

## Status

- Issue: [#1743](https://github.com/linagora/tmail-flutter/issues/1743)

## Context

In email view always show horizontal scroll bar in Email detail view and don't wrap text instead

## Root cause

The horizontal scrollbar appears when the content inside the body element is wider than the width of the viewport. By default, the overflow property is set to "visible", which means that the content can overflow the element's boundaries.

## Decision

When you set `overflow-x: hidden`; on the body element, it prevents the content from overflowing the element's boundaries in the horizontal direction, 
effectively disabling the horizontal scrollbar. However, if you don't set this property and the content is wider than the viewport, 
the scrollbar will appear to allow the user to scroll horizontally to see the content that is outside the viewport.
## Consequences

- Hide Horizontal scroll bar in Email detail view
