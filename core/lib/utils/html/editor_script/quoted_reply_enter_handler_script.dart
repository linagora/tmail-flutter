import 'package:core/utils/html/editor_script/web_editor_script.dart';

final class QuotedReplyEnterHandlerScript implements WebEditorScript {
  const QuotedReplyEnterHandlerScript();

  static final String _source = [
    QuotedReplyEnterHandlerSource.bootstrap,
    QuotedReplyEnterHandlerSource.logging,
    QuotedReplyEnterHandlerSource.contentGuard,
    QuotedReplyEnterHandlerSource.domLookup,
    QuotedReplyEnterHandlerSource.emptyAncestorCleanup,
    QuotedReplyEnterHandlerSource.editorSync,
    QuotedReplyEnterHandlerSource.quoteSplit,
    QuotedReplyEnterHandlerSource.taskQueue,
    QuotedReplyEnterHandlerSource.keydownHandler,
    QuotedReplyEnterHandlerSource.close,
  ].join('\n');

  @override
  String get name => 'registerQuotedReplyEnterKeyHandler';

  @override
  String get script => _source;
}

abstract final class QuotedReplyEnterHandlerSource {
  static const bootstrap = r'''
      (() => {
        const root = document.querySelector('.note-editor .note-editable');
        if (!root || typeof root.addEventListener !== 'function') return;
        if (root.dataset.quotedReplyEnterHandlerAttached) return;
        root.dataset.quotedReplyEnterHandlerAttached = 'true';''';

  static const logging = r'''
        function logHandlerError(context, error) {
          if (typeof console !== 'undefined'
              && console
              && typeof console.error === 'function') {
            console.error('[TwakeMail][QuotedReplyEnterHandler] ' + context, error);
          }
        }''';

  static const contentGuard = r'''
        function hasMeaningfulContent(node) {
          if (!node) return false;
          const text = typeof node.textContent === 'string'
            ? node.textContent.replace(/[\s\u200B\u200C\u200D\u2060\uFEFF]/g, '')
            : '';
          const selector = 'img, video, audio, iframe, table, hr, object, embed, svg, canvas, math, button, input, textarea, select, progress, meter, [contenteditable="false"]';
          return text !== '' || !!(
            (node.matches && node.matches(selector))
            || (node.querySelector && node.querySelector(selector))
          );
        }

        function hasMeaningfulContentBeforeCaret(block, caretRange) {
          const beforeRange = document.createRange();
          beforeRange.selectNodeContents(block);
          beforeRange.setEnd(caretRange.startContainer, caretRange.startOffset);
          return hasMeaningfulContent(beforeRange.cloneContents());
        }''';

  static const domLookup = r'''
        function isReplyBlock(element) {
          if (!element || typeof element.tagName !== 'string') return false;
          if (element.tagName === 'P' || element.tagName === 'LI') return true;
          if (/^H[1-6]$/.test(element.tagName)) return true;
          if (element.tagName !== 'DIV') return false;
          return !element.querySelector(
            'p, li, div, blockquote, table, ul, ol, h1, h2, h3, h4, h5, h6',
          );
        }

        function findReplyBlock(node) {
          let element = node && node.nodeType === 3 ? node.parentElement : node;
          while (element && element !== root) {
            if (isReplyBlock(element)) return element;
            element = element.parentElement;
          }
          return null;
        }

        function findOuterQuote(element) {
          let quote = null;
          while (element && element !== root) {
            if (element.tagName === 'BLOCKQUOTE') quote = element;
            element = element.parentElement;
          }
          return quote;
        }''';

  static const emptyAncestorCleanup = r'''
        function removeEmptyAncestors(element, quote) {
          let current = element;
          while (current && current !== quote && current !== root) {
            const parent = current.parentElement;
            if (!hasMeaningfulContent(current)) current.remove();
            current = parent;
          }
        }

        function removeLeadingEmptyContent(node) {
          let current = node;
          while (current && current.firstChild) {
            const child = current.firstChild;
            if (!hasMeaningfulContent(child)) {
              child.remove();
              continue;
            }
            current = child.nodeType === 1 ? child : null;
          }
        }''';

  static const editorSync = r'''
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

        function syncEditor() {
          try {
            const note = findSummernoteInstance();
            if (note) {
              note.summernote('editor.afterCommand');
              return;
            }
          } catch (error) {
            logHandlerError('syncEditor summernote command failed', error);
          }

          try {
            root.dispatchEvent(new Event('input', { bubbles: true }));
          } catch (error) {
            logHandlerError('syncEditor input dispatch failed', error);
          }
        }''';

  static const quoteSplit = r'''
        function createAnswer() {
          const answer = document.createElement('p');
          answer.innerHTML = '<br>';
          return answer;
        }

        function selectAnswer(answer, selection) {
          const answerRange = document.createRange();
          answerRange.setStart(answer, 0);
          answerRange.collapse(true);
          selection.removeAllRanges();
          selection.addRange(answerRange);
        }

        function insertFallbackAnswer(parent, reference, selection) {
          if (!parent || !root.contains(parent)) return false;
          const answer = createAnswer();
          const insertionPoint = reference && reference.parentNode === parent
            ? reference
            : null;
          parent.insertBefore(answer, insertionPoint);
          selectAnswer(answer, selection);
          return true;
        }

        function splitQuote(block, quote, afterRange, selection, trimLeadingContent) {
          if (!root.contains(quote)) return false;
          const quoteParent = quote.parentNode;
          const blockParent = block.parentElement;
          if (!quoteParent || !blockParent) return false;

          const trailingContents = afterRange.extractContents();
          if (trimLeadingContent) removeLeadingEmptyContent(trailingContents);
          const hasTrailingContents = hasMeaningfulContent(trailingContents);
          block.remove();
          removeEmptyAncestors(blockParent, quote);

          const answer = createAnswer();
          const trailingQuote = hasTrailingContents
            ? quote.cloneNode(false)
            : null;
          if (trailingQuote) trailingQuote.appendChild(trailingContents);

          const insertionPoint = quote.nextSibling;
          if (!hasMeaningfulContent(quote)) quote.remove();

          quoteParent.insertBefore(answer, insertionPoint);
          if (trailingQuote) {
            quoteParent.insertBefore(trailingQuote, answer.nextSibling);
          }

          selectAnswer(answer, selection);
          return true;
        }''';

  static const taskQueue = r'''
        function enqueue(task) {
          if (typeof window.queueMicrotask === 'function') {
            window.queueMicrotask(task);
          } else {
            window.setTimeout(task, 0);
          }
        }''';

  static const keydownHandler = r'''
        root.addEventListener('keydown', function (event) {
          try {
            if (event.key !== 'Enter'
                || event.isComposing
                || event.shiftKey
                || event.altKey
                || event.ctrlKey
                || event.metaKey) return;

            const selection = window.getSelection();
            if (!selection || selection.rangeCount !== 1) return;

            const caretRange = selection.getRangeAt(0);
            if (!caretRange.collapsed) return;

            const block = findReplyBlock(caretRange.startContainer);
            if (!block) return;
            if (block.closest && block.closest('td, th')) return;

            const isEmptyBlock = !hasMeaningfulContent(block);
            if (!isEmptyBlock
                && hasMeaningfulContentBeforeCaret(block, caretRange)) {
              return;
            }

            const quote = findOuterQuote(block);
            if (!quote) return;

            const afterRange = document.createRange();
            if (isEmptyBlock) {
              afterRange.setStartAfter(block);
            } else {
              afterRange.setStart(
                caretRange.startContainer,
                caretRange.startOffset,
              );
            }
            afterRange.setEnd(quote, quote.childNodes.length);

            const fallbackParent = quote.parentNode;
            const fallbackReference = quote.nextSibling;
            if (!fallbackParent) return;

            event.preventDefault();
            enqueue(function () {
              let handled = false;
              try {
                handled = splitQuote(
                  block,
                  quote,
                  afterRange,
                  selection,
                  !isEmptyBlock,
                );
              } catch (error) {
                logHandlerError('splitQuote failed', error);
                handled = false;
              }

              if (!handled) {
                try {
                  insertFallbackAnswer(
                    fallbackParent,
                    fallbackReference,
                    selection,
                  );
                } catch (error) {
                  logHandlerError('insertFallbackAnswer failed', error);
                }
              }

              syncEditor();
            });
          } catch (error) {
            logHandlerError('keydown handler failed', error);
          }
        }, true);''';

  static const close = '      })();';
}
