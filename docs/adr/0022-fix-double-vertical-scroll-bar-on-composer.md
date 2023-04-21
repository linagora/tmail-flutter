# 22. Fix double vertical scroll bar when hide status bar

Date: 2023-04-21

## Status

- Issue: [#1740](https://github.com/linagora/tmail-flutter/issues/1740)

## Context

- Root cause: 
    - When we using `html_editor_enhanced` lib can't auto resize `HTML Iframe` when changing the size of the screen
    - `.note-editor.note-airframe .note-editing-area .note-editable,.note-editor.note-frame .note-editing-area .note-editable` has an overridden padding under the widgets
    - When enabling `Code View` modem has an overridden padding under the widgets. Can't see break line

## Decision

- Use `setFullScreen` to `HTML Iframe` for the purpose of automatically resizing when there are changes
- Remove padding of `.note-editor.note-airframe .note-editing-area .note-editable,.note-editor.note-frame .note-editing-area .note-editable`
- Enable resize editor `disableResizeEditor: false`
- Remove padding of `.note-editor.note-airframe .note-editing-area .note-codable,.note-editor.note-frame .note-editing-area .note-codable` when enabling `Code View` mode

## Consequences

- No longer appear two vertical scroll bars of content on the editor
- Automatically resize `HTML Iframe` for dimensions