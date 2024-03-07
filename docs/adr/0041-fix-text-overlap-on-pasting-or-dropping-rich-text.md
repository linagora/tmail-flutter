# 41. Fix text overlap on pasting or dropping rich text

Date: 2024-03-07

## Status

Accepted

## Context

- When copy-pasting or drag-dropping rich text from LibreOffice to email composer, text is overlapped on the same line

## Decision

1. Have a js script to change the `line-height` style of all elements that has their `line-height` modified to 100%
2. HtmlEditor has onPaste callback, trigger the `line-height` script here
3. Add listener to `drop` event using js and also trigger `line-height` script here

## Consequences

- Even if the content available that's not pasted or dropped will get reformatted. Currently our composer doesn't support changing text line height, so the impact will not affect avaiable content yet.
