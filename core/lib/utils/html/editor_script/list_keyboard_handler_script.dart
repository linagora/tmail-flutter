import 'package:core/utils/html/editor_script/web_editor_script.dart';

/// Binds the usual list keyboard conventions (as in Gmail) to the web editor:
/// - `Tab` / `Shift+Tab` inside a list item nests / un-nests it, delegating to
///   the same Summernote `indent` / `outdent` commands as the toolbar buttons.
/// - `Enter` on an empty nested list item moves it up one level instead of
///   leaving the list, so the user keeps typing bullets at the parent level.
final class ListKeyboardHandlerScript implements WebEditorScript {
  const ListKeyboardHandlerScript();

  static final String _source = [
    ListKeyboardHandlerSource.bootstrap,
    ListKeyboardHandlerSource.logging,
    ListKeyboardHandlerSource.domLookup,
    ListKeyboardHandlerSource.editorCommand,
    ListKeyboardHandlerSource.keydownHandler,
    ListKeyboardHandlerSource.close,
  ].join('\n');

  @override
  String get name => 'registerListKeyboardHandler';

  @override
  String get script => _source;
}

abstract final class ListKeyboardHandlerSource {
  static const bootstrap = r'''
      (() => {
        const root = document.querySelector('.note-editor .note-editable');
        if (!root || typeof root.addEventListener !== 'function') return;
        if (root.dataset.listKeyboardHandlerAttached) return;
        root.dataset.listKeyboardHandlerAttached = 'true';''';

  static const logging = r'''
        function logHandlerError(context, error) {
          if (typeof console !== 'undefined'
              && console
              && typeof console.error === 'function') {
            console.error('[TwakeMail][ListKeyboardHandler] ' + context, error);
          }
        }''';

  static const domLookup = r'''
        function findListItem(node) {
          let element = node && node.nodeType === 3 ? node.parentElement : node;
          let listItem = null;
          while (element && element !== root) {
            if (element.tagName === 'TD' || element.tagName === 'TH') return null;
            if (!listItem && element.tagName === 'LI') listItem = element;
            element = element.parentElement;
          }
          return listItem;
        }

        // Summernote `indent` wraps an item with no previous sibling in an
        // empty parent item, so each Tab would add a stray bullet.
        function canNestListItem(item) {
          const previous = item.previousElementSibling;
          return !!previous && previous.tagName === 'LI';
        }

        function isNestedListItem(item) {
          const list = item.parentElement;
          let ancestor = list ? list.parentElement : null;
          while (ancestor && ancestor !== root) {
            if (/^(LI|UL|OL)$/.test(ancestor.tagName)) return true;
            ancestor = ancestor.parentElement;
          }
          return false;
        }

        function isEmptyListItem(item) {
          if (item.querySelector('li, ul, ol')) return false;
          const text = typeof item.textContent === 'string'
            ? item.textContent.replace(/[\s​‌‍⁠﻿]/g, '')
            : '';
          if (text !== '') return false;
          return !item.querySelector(
            'img, video, audio, iframe, table, hr, object, embed, svg, canvas, input, [contenteditable="false"]',
          );
        }

        function findCaretListItem() {
          const selection = window.getSelection();
          if (!selection || selection.rangeCount < 1) return null;
          return findListItem(selection.getRangeAt(0).startContainer);
        }''';

  static const editorCommand = r'''
        function findSummernoteInstance() {
          if (!window.jQuery) return null;
          const noteEditor = typeof root.closest === 'function'
            ? root.closest('.note-editor')
            : null;
          const source = noteEditor ? noteEditor.previousElementSibling : null;
          if (!source) return null;
          const note = window.jQuery(source);
          if (!note || typeof note.summernote !== 'function') return null;
          const initialized =
            typeof note.data === 'function' && note.data('summernote');
          return initialized ? note : null;
        }

        function runListCommand(event, command) {
          const note = findSummernoteInstance();
          if (!note) return;
          event.preventDefault();
          try {
            note.summernote(command);
          } catch (error) {
            logHandlerError(command + ' command failed', error);
          }
        }''';

  static const keydownHandler = r'''
        root.addEventListener('keydown', function (event) {
          try {
            if (event.defaultPrevented
                || event.isComposing
                || event.altKey
                || event.ctrlKey
                || event.metaKey) return;

            if (event.key === 'Tab') {
              const item = findCaretListItem();
              if (!item) return;
              if (!event.shiftKey && !canNestListItem(item)) {
                event.preventDefault();
                return;
              }
              runListCommand(event, event.shiftKey ? 'outdent' : 'indent');
              return;
            }

            if (event.key === 'Enter' && !event.shiftKey) {
              const selection = window.getSelection();
              if (!selection || selection.rangeCount !== 1) return;
              if (!selection.getRangeAt(0).collapsed) return;
              const item = findCaretListItem();
              if (!item || !isEmptyListItem(item) || !isNestedListItem(item)) return;
              runListCommand(event, 'outdent');
            }
          } catch (error) {
            logHandlerError('keydown handler failed', error);
          }
        }, true);''';

  static const close = '      })();';
}
