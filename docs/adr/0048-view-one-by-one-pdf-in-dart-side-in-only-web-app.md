# 48. View one-by-one PDF in Dart side in only Web app

Date: 2024-05-17

## Status

Accepted

## Context

- In EmailView when the user clicks on an attachment, we should display a PDF viewer for the user.
- In PDF Viewer users can view full pages of the PDF file and can download or print it.

## Decision

- Create PDF Viewer with [pdf_render](https://github.com/linagora/flutter_pdf_render.git)
- Viewer will stay overlay in web app tab
- Actions supported: `Download`, `Print`, `Zoom In/Out`, `Show current/total pages` in viewer

## Consequences

- PDF viewer works well on all browsers (Chrome/Firefox/Edge/Safari/Opera)

## Improvement

- `Print name`: Some browsers (Firefox/Safari/Edge) use a random name to name the file when printing.
- `Jump to page`: When using the standard size of PDF pages to display in the viewer, the `jumpToPage` method of `pdf_render` does not work correctly. So we will temporarily disable it.
- `Drag the scrollbar`: Currently the pdf page is displayed in an `Interactive viewer` so does not interact with the `Scrollbar`