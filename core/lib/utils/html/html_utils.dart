import 'dart:convert';
import 'dart:math';

import 'package:core/utils/html/html_template.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:html_unescape/html_unescape.dart';

import 'js_interop_stub.dart' if (dart.library.html) 'dart:js_interop';
import 'dart:typed_data';

import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class HtmlUtils {
  static const validTags = [
    'html','head','body','div','span','p','b','i','u','strong','em','a',
    'img','blockquote','ul','ol','li','table','tr','td','th','thead','tbody',
    'br','hr','h1','h2','h3','h4','h5','h6','pre','code'
  ];
  static final random = Random();
  static final htmlUnescape = HtmlUnescape();

  // ReDoS-safe regex patterns as const
  static final _htmlStartTagRegex = RegExp(r'<[a-zA-Z][^>\s]*[^>]*>');
  static final _htmlEndTagRegex = RegExp(r'</[a-zA-Z][^>]{0,128}>');
  static final _whitespaceNormalizationRegex = RegExp(r'\s+');
  static final _urlRegex = RegExp(
    r'''(?:https?://|ftp://|mailto:|file://|www\.)[^\s<.]+(?:\.[^\s<.]+)*(?<![.,:;!?"')\]])''',
    caseSensitive: false,
    multiLine: true,
  );
  static final _protocolRegex = RegExp(r'^(?:https?|ftp|mailto|file)');
  static final _tagRemovalRegex = RegExp(
    '</?(?:${validTags.map(RegExp.escape).join('|')})(?:\\s+[^>]*)?>',
    caseSensitive: false,
  );

  @visibleForTesting
  static RegExp get htmlStartTagRegex => _htmlStartTagRegex;

  @visibleForTesting
  static RegExp get htmlEndTagRegex => _htmlEndTagRegex;

  @visibleForTesting
  static RegExp get urlRegex => _urlRegex;

  static const removeLineHeight1px = (
    script: '''
      document.querySelectorAll('[style*="line-height"]').forEach(el => {
        if (el.style.lineHeight === "1px") {
          el.style.removeProperty("line-height");
        }
      });''',
    name: 'removeLineHeight1px');

  static const registerDropListener = (
    script: '''
      document.querySelector(".note-editable").addEventListener(
        "drop",
        (event) => window.parent.postMessage(
          JSON.stringify({"name": "registerDropListener"})))''',
    name: 'registerDropListener');

  static const unregisterDropListener = (
    script: '''
      const editor = document.querySelector(".note-editable");
      const newEditor = editor.cloneNode(true);
      editor.parentNode.replaceChild(newEditor, editor);''',
    name: 'unregisterDropListener');

  static ({String name, String script}) registerSelectionChangeListener(
    String viewId,
  ) =>
      (
        script: '''
      let lastSelectedText = '';

      const isDesktopEditor = () => !window.flutter_inappwebview

      const sendSelectionChangeMessage = (data) => {
        // When iframe
        if (window.parent) {
          window.parent.postMessage(
            JSON.stringify({
              ...data,
              viewId: '$viewId',
              name: 'onSelectionChange',
            }),
            '*'
          );
        }

        // When WebView
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('onSelectionChange', data);
        }
      };
      
      function getEditableFromSelection(selection) {
        const node = selection?.focusNode || selection?.anchorNode;
        const el = node?.nodeType === Node.ELEMENT_NODE ? node : node?.parentElement;

        if (isDesktopEditor()) {
          return (
            el?.closest('.note-editor .note-editable') ||
            document.querySelector('.note-editor .note-editable')
          );
        } else {
          return (
            el?.closest('#editor')
          );
        }
      }
      
      function clamp(v, min, max) {
        return Math.max(min, Math.min(max, v));
      }

      document.addEventListener('selectionchange', function() {
        const selection = window.getSelection();
        const selectedText = selection ? selection.toString().trim() : '';
      
        if (selectedText === lastSelectedText) return;
        lastSelectedText = selectedText;
      
        if (!selectedText || !selection || selection.rangeCount === 0) {
          sendSelectionChangeMessage({ hasSelection: false });
          return;
        }
      
        try {
          const editable = getEditableFromSelection(selection);
          if (!editable) {
            sendSelectionChangeMessage({ hasSelection: false });
            return;
          }
      
          const editableRect = editable.getBoundingClientRect();
          const padding = 8;
          const safeHeight = Math.max(editableRect.height, padding * 2);
      
          const range = selection.getRangeAt(0);
          const rects = range.getClientRects();
          if (!rects || rects.length === 0) {
            sendSelectionChangeMessage({ hasSelection: false });
            return;
          }
      
          const lastRect = rects[rects.length - 1];

          // Avoid native selection marks in mobile
          // Offset has been arbitrary determined to avoid selection marks on Android and iOS
          const buttonOffset = isDesktopEditor() ? { x: 0, y: 0 } : { x: 22, y: -20 };

          let x = lastRect.right - editableRect.left + buttonOffset.x;
          let y = lastRect.bottom - editableRect.top + buttonOffset.y;
      
          const isInside =
            lastRect.bottom >= editableRect.top &&
            lastRect.top <= editableRect.bottom &&
            lastRect.right >= editableRect.left &&
            lastRect.left <= editableRect.right;
      
          if (!isInside) {
            x = padding;
            y = safeHeight / 2;
          }
      
          x = clamp(x, padding, editableRect.width - padding);
          y = clamp(y, padding, safeHeight - padding);
      
          sendSelectionChangeMessage({
            hasSelection: true,
            selectedText,
            coordinates: {
              x,
              y,
              width: lastRect.width,
              height: lastRect.height,
            },
          });
        } catch (error) {
          console.error('Selection change error:', error);
          sendSelectionChangeMessage({ hasSelection: false });
        }
      });
    ''',
        name: 'onSelectionChange',
      );

  static const collapseSelectionToEnd = (
    script: '''
      (() => {
        const selection = window.getSelection();
        if (selection) {
          selection.collapseToEnd()
        }
      })();''',
    name: 'collapseSelectionToEnd');

  static const deleteSelectionContent = (
    script: '''
      (() => {
        const selection = window.getSelection();
        if (selection && selection.rangeCount > 0) {
          const range = selection.getRangeAt(0);
          range.deleteContents();
        }
      })();''',
    name: 'deleteSelectionContent');

  static recalculateEditorHeight({double? maxHeight}) => (
    script: '''
      const editable = document.querySelector('.note-editable');
      if (editable) {
        editable.style.height = $maxHeight + 'px';
      }
    ''',
    name: 'recalculateEditorHeight');

  static String customInlineBodyCssStyleHtmlEditor({
    TextDirection direction = TextDirection.ltr,
    double? horizontalPadding,
  }) {
    return '''
      <style>
        .note-frame, .note-tooltip-content, .note-popover {
          font-family: 'Inter', sans-serif;
          color: #222222;
        }
        
        .note-editable {
          direction: ${direction.name};
        }
        
        .note-editable .tmail-signature {
          text-align: ${direction == TextDirection.rtl ? 'right' : 'left'};
        }
        
        ${horizontalPadding != null
          ? '''
              .note-codable {
                padding: 10px ${horizontalPadding}px 0px ${horizontalPadding > 3 ? horizontalPadding - 3 : horizontalPadding}px;
                margin-right: 3px;
              }
              
              .note-editable {
                padding: 10px ${horizontalPadding}px 0px ${horizontalPadding > 3 ? horizontalPadding - 3 : horizontalPadding}px;
                margin-right: 3px;
              }
            '''
          : '''
              .note-editable {
                padding: 10px 10px 0px 10px;
              }
            '''}
      </style>
    ''';
  }

  static String validateHtmlImageResourceMimeType(String mimeType) {
    if (mimeType.endsWith('svg')) {
      mimeType = 'image/svg+xml';
    }
    log('HtmlUtils::validateHtmlImageResourceMimeType:mimeType: $mimeType');
    return mimeType;
  }

  static String convertBase64ToImageResourceData({
    required String base64Data,
    required String mimeType
  }) {
    if (!base64Data.endsWith('==')) {
      base64Data.append('==');
    }
    return 'data:$mimeType;base64,$base64Data';
  }

  static String generateHtmlDocument({
    required String content,
    double? minHeight,
    double? minWidth,
    String? styleCSS,
    String? javaScripts,
    bool hideScrollBar = true,
    bool useDefaultFontStyle = false,
    double fontSize = 14,
    TextDirection? direction,
    double? contentPadding,
  }) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <style>
        ${HtmlTemplate.fontFaceStyle}
        
        ${useDefaultFontStyle ? HtmlTemplate.defaultFontStyle(fontSize: fontSize) : ''}
        
        .tmail-content {
          min-height: ${minHeight ?? 0}px;
          min-width: ${minWidth ?? 0}px;
          overflow: auto;
          overflow-wrap: break-word;
          word-break: break-word;
        }
        ${hideScrollBar ? '''
          .tmail-content::-webkit-scrollbar {
            display: none;
          }
          .tmail-content {
            -ms-overflow-style: none;  /* IE and Edge */
            scrollbar-width: none;  /* Firefox */
          }
        ''' : ''}
        
        pre {
          white-space: pre-wrap;
        }
        
        table {
          white-space: normal !important;
        }
              
        @media only screen and (max-width: 600px) {
          table {
            width: 100% !important;
          }
          
          a {
            width: -webkit-fill-available !important;
          }
        }
        
        table, td, th {
          word-break: normal !important;
        }
        
        ${styleCSS ?? ''}
      </style>
      </head>
      <body ${direction == TextDirection.rtl ? 'dir="rtl"' : ''} style = "overflow-x: hidden; ${contentPadding != null ? 'margin: $contentPadding;' : ''}";>
      <div class="tmail-content">$content</div>
      ${javaScripts ?? ''}
      </body>
      </html> 
    ''';
  }

  static String createTemplateHtmlDocument({String? title}) {
    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          ${title != null ? '<title>$title</title>' : ''}
        </head>
        <body></body>
      </html> 
    ''';
  }

  static String generateSVGImageData(String base64Data) => 'data:image/svg+xml;base64,$base64Data';

  static void openNewTabHtmlDocument(String htmlDocument) {
    final blob = html.Blob([htmlDocument], Constant.textHtmlMimeType);

    final url = html.Url.createObjectUrlFromBlob(blob);

    html.window.open(url, '_blank');

    html.Url.revokeObjectUrl(url);
  }

  static String chromePdfViewer(Uint8List bytes, String fileName) {
    return '''
      <!DOCTYPE html>
      <html lang="en">
        <head>
        <meta charset="utf-8" />
        <title>$fileName</title>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.0.379/pdf.min.mjs" type="module"></script>
        <style>
          body {
            background-color: black;
          }

          #pdf-container {
            $_pdfContainerStyle
          }

          #pdf-viewer {
            $_pdfViewerStyle
          }

          #app-bar {
            $_pdfAppBarStyle
          }

          #download-btn {
            $_pdfDownloadButtonStyle
          }

          #file-info {
            $_pdfFileInfoStyle
          }

          #file-name {
            $_pdfFileNameStyle
          }
        </style>
        </head>
        <body>
          <div id="pdf-container">
            $_pdfAppbarElement
            <div id="pdf-viewer"></div>
          </div>

          <script type="module">
            function renderPage(pdfDoc, pageNumber, canvas) {
              pdfDoc.getPage(pageNumber).then(page => {
                const viewport = page.getViewport({ scale: 1 });
                canvas.height = viewport.height;
                canvas.width = viewport.width;

                const context = canvas.getContext('2d');
                const renderContext = {
                  canvasContext: context,
                  viewport: viewport
                };

                page.render(renderContext);
              });
            }

            const bytesJs = new Uint8Array(${bytes.toJS});
            const pdfContainer = document.getElementById('pdf-viewer');

            var { pdfjsLib } = globalThis;

            pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.0.379/pdf.worker.min.mjs';

            var loadingTask = pdfjsLib.getDocument(bytesJs);
            loadingTask.promise.then(function(pdf) {
              const numPages = pdf.numPages;

              for (let i = 1; i <= numPages; i++) {
                const pageContainer = document.createElement('div');
                pageContainer.classList.add('pdf-page');

                const canvas = document.createElement('canvas');
                canvas.id = `page-\${i}`;

                pageContainer.appendChild(canvas);
                pdfContainer.appendChild(pageContainer);

                renderPage(pdf, i, canvas);
              }
            }, function (reason) {
              console.error(reason);
            });

            ${_fileInfoScript(fileName)}

            ${_downloadButtonListenerScript(bytes, fileName)}
          </script>
        </body>
      </html>''';
  }

  static String safariPdfViewer(Uint8List bytes, String fileName) {
    final base64 = base64Encode(bytes);

    return '''
      <!DOCTYPE html>
      <html lang="en">
        <head>
        <meta charset="utf-8" />
        <title>$fileName</title>
        <style>
          body {
            background-color: black;
          }

          body, html {
            margin: 0;
            padding: 0;
            height: 100%;
          }
          
          #pdf-container {
            $_pdfContainerStyle
            overflow: hidden;
          }

          #pdf-viewer {
            $_pdfViewerStyle
            width: 100%;
            height: calc(100vh - 53px);
          }

          #app-bar {
            $_pdfAppBarStyle
          }

          #download-btn {
            $_pdfDownloadButtonStyle
          }

          #file-info {
            $_pdfFileInfoStyle
          }

          #file-name {
            $_pdfFileNameStyle
          }
        </style>
        </head>
        <body>
          <div id="pdf-container">
            $_pdfAppbarElement
            <div id="pdf-viewer"></div>
          </div>

          <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfobject/2.3.0/pdfobject.min.js"></script>
          <script>
            const bytesJs = new Uint8Array(${bytes.toJS});
            PDFObject.embed('data:application/pdf;base64,$base64', "#pdf-viewer");

            ${_fileInfoScript(fileName)}

            ${_downloadButtonListenerScript(bytes, fileName)}
          </script>
        </body>
      </html>''';
  }

  static void openFileViewer({
    required Uint8List bytes,
    required String fileName,
    String? mimeType
  }) {
    final blob = html.Blob([bytes], mimeType);
    final file = html.File([blob], fileName, {'type': mimeType});
    final url = html.Url.createObjectUrl(file);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  }

  static const String _pdfContainerStyle = '''
    display: flex;
    flex-direction: column;
    width: 100%;''';

  static const String _pdfViewerStyle = '''
    flex: 1; /* Allow viewer to fill remaining space */
    border: 1px solid #ddd;
    margin-left: auto;
    margin-right: auto;
    padding-top: 53px;
    border: none;''';

  static const String _pdfAppBarStyle = '''
    position: fixed; /* Fix app bar to top */
    top: 0;
    left: 0;
    right: 0; /* Stretch across entire viewport */
    display: flex;
    justify-content: space-between;
    padding: 5px 10px;
    background-color: #f0f0f0;
    z-index: 100; /* Ensure buttons stay on top */''';

  static const String _pdfDownloadButtonStyle = '''
    padding: 5px 10px;
    border: 1px solid #ddd;
    border-radius: 5px;
    cursor: pointer;
    margin-left: 10px;''';

  static const String _pdfFileInfoStyle = '''
    width: 30%;
    display: flex;
    align-items: center;
    padding: 5px 10px;''';

  static const String _pdfFileNameStyle = '''
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;''';

  static const String _pdfAppbarElement = '''
    <div id="app-bar">
      <div id="file-info">
        <span id="file-name" style="margin-right: 10px;"></span> 
        (<span id="file-size" style="white-space: nowrap;"></span>)
      </div>
      <div style="width: 10px;"></div>
      <div id="buttons">
        <button id="download-btn">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M19 20V18H5V20H19ZM19 10H15V4H9V10H5L12 17L19 10Z" fill="#7B7B7B"/>
          </svg>
        </button>
      </div>
    </div>''';

  static String _downloadButtonListenerScript(Uint8List bytes, String? fileName) {
    return '''
      const downloadBtn = document.getElementById('download-btn');
      downloadBtn.addEventListener('click', () => {
        const buffer = new Uint8Array(${bytes.toJS}).buffer;
        const blob = new Blob([buffer], { type: "application/pdf" });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.download = "$fileName";
        a.href = url;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
      });''';
  }

  static String _fileInfoScript(String? fileName) {
    return '''
      function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat(bytes / Math.pow(k, i)).toFixed(2) + ' ' + sizes[i];
      }

      const fileNameSpan = document.getElementById('file-name');
      fileNameSpan.textContent = "$fileName";

      const fileSizeSpan = document.getElementById('file-size');
      fileSizeSpan.textContent = formatFileSize(bytesJs.length);''';
  }

  static bool openNewWindowByUrl(
    String url,
    {
      int width = 800,
      int height = 600,
      bool isFullScreen = false,
      bool isCenter = true,
    }
  ) {
    try {
      if (isFullScreen) {
        html.window.open(url, '_blank');

        html.Url.revokeObjectUrl(url);
        return true;
      }

      final screenWidth = html.window.screen?.width ?? width;
      final screenHeight = html.window.screen?.height ?? height;

      int left, top;

      if (isCenter) {
        left = (screenWidth - width) ~/ 2;
        top = (screenHeight - height) ~/ 2;
      } else {
        left = random.nextInt(screenWidth ~/ 2);
        top = random.nextInt(screenHeight ~/ 2);
      }

      final options = 'width=$width,height=$height,top=$top,left=$left';

      html.window.open(url, '_blank', options);

      html.Url.revokeObjectUrl(url);

      return true;
    } catch (e) {
      logWarning('AppUtils::openNewWindowByUrl:Exception = $e');
      return false;
    }
  }

  static void setWindowBrowserTitle(String title) {
    try {
      final titleElements = html.window.document.getElementsByTagName('title');
      if (titleElements.isNotEmpty) {
        titleElements.first.text = title;
      }
    } catch (e) {
      logWarning('AppUtils::setWindowBrowserTitle:Exception = $e');
    }
  }

  static String unescapeHtml(String input) {
    try {
      return htmlUnescape.convert(input);
    } catch (e) {
      logWarning('HtmlUtils::unescapeHtml:Exception = $e');
      return input;
    }
  }

  static String removeWhitespace(String input) {
    return input
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .replaceAll('\t', '');
  }

  /// Returns true if the browser is Safari and its major version is less than 17.
  static bool isSafariBelow17() {
    try {
      final userAgent = html.window.navigator.userAgent;
      log('HtmlUtils::isOldSafari:UserAgent = $userAgent');
      final isSafari = userAgent.contains('Safari') && !userAgent.contains('Chrome');
      if (!isSafari) return false;

      final match = RegExp(r'Version/(\d+)\.').firstMatch(userAgent);
      if (match == null) return false;

      final version = int.tryParse(match.group(1)!);
      log('HtmlUtils::isOldSafari:Version = $version');
      return version != null && version < 17;
    } catch (e) {
      logWarning('HtmlUtils::isOldSafari:Exception = $e');
      return false;
    }
  }

  static String addQuoteToggle(String htmlString) {
    final likelyHtml = htmlString.contains(_htmlStartTagRegex) && // Contains a start tag
      htmlString.contains(_htmlEndTagRegex); // Contains an end tag

    if (!likelyHtml) {
      return htmlString; // Not likely HTML, return original
    }

    try {
      html.DomParser().parseFromString(htmlString, 'text/html');
    } catch (e) {
      return htmlString;
    }

    final containerElement = '<div class="quote-toggle-container" >$htmlString</div>';

    final containerDom = html.DomParser().parseFromString(containerElement, 'text/html');
    html.ElementList blockquotes = containerDom.querySelectorAll('.quote-toggle-container > blockquote');
    int currentSearchLevel = 1;

    while (blockquotes.isEmpty) {
      // Finish searching at level [currentSearchLevel]
      if (currentSearchLevel >= 3) return htmlString;
      // No blockquote elements found on first level, try another level
      blockquotes = containerDom.querySelectorAll('.quote-toggle-container${' > div' * currentSearchLevel} > blockquote');
      currentSearchLevel++;
    }

    final lastBlockquote = blockquotes.last;

    const buttonHtmlContent = '''
      <button class="quote-toggle-button collapsed" title="Show trimmed content">
          <span class="dot"></span>
          <span class="dot"></span>
          <span class="dot"></span>
      </button>''';

    // Parse the button HTML content as a fragment
    final tempDoc =
        html.DomParser().parseFromString(buttonHtmlContent, 'text/html');

    final buttonElement = tempDoc.querySelector('.quote-toggle-button');

    // Insert the button before the last blockquote
    if (lastBlockquote.parentNode != null && buttonElement != null) {
      lastBlockquote.parentNode!.insertBefore(buttonElement, lastBlockquote);
    }

    // Return the modified HTML string
    return containerDom.documentElement?.outerHtml ?? htmlString;
  }

  static String get quoteToggleStyle => '''
    <style>
      .quote-toggle-button + blockquote {
        display: block; /* Default display */
      }
      .quote-toggle-button.collapsed + blockquote {
        display: none;
      }
      .quote-toggle-button {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 20px;
        height: 20px;
        gap: 2px;
        background-color: #d7e2f5;
        padding: 0;
        margin: 8px 0;
        border-radius: 50%;
        transition: background-color 0.2s ease-in-out;
        border: none;
        cursor: pointer;
        -webkit-appearance: none;
        -moz-appearance: none;
        appearance: none;
        -webkit-user-select: none; /* Safari */
        -moz-user-select: none; /* Firefox */
        -ms-user-select: none; /* IE 10+ */
        user-select: none; /* Standard syntax */
        -webkit-user-drag: none; /* Prevent dragging on WebKit browsers (e.g., Chrome, Safari) */
      }
      .quote-toggle-button:hover {
        background-color: #cdcdcd !important;
      }
      .dot {
        width: 3.75px;
        height: 3.75px;
        background-color: #55687d;
        border-radius: 50%;
      }
    </style>''';

  static String get quoteToggleScript => '''
    <script>
      document.addEventListener('DOMContentLoaded', function() {
        const buttons = document.querySelectorAll('.quote-toggle-button');
        buttons.forEach(button => {
          button.onclick = function() {
            const blockquote = this.nextElementSibling;
            if (blockquote && blockquote.tagName === 'BLOCKQUOTE') {
              this.classList.toggle('collapsed');
              if (this.classList.contains('collapsed')) {
                this.title = 'Show trimmed content';
              } else {
                this.title = 'Hide expanded content';
              }
            }
          };
        });
      });
    </script>''';

  static String extractPlainText(
    String html, {
    bool removeQuotes = true,
    bool removeStyle = true,
    bool removeScript = true,
  }) {
    var cleaned = html;

    if (cleaned.isEmpty) return '';

    // Parse DOM
    final doc = parser.parse(cleaned);

    // Remove unwanted nodes by CSS selector
    if (removeQuotes) {
      doc.querySelectorAll('blockquote').forEach((e) => e.remove());
    }
    if (removeStyle) {
      doc.querySelectorAll('style').forEach((e) => e.remove());
    }
    if (removeScript) {
      doc.querySelectorAll('script').forEach((e) => e.remove());
    }

    cleaned = doc.outerHtml;

    // Decode HTML entities up to 5 times (&amp; → &, &nbsp; → space, &lt;div&gt; → <div>, ...)
    int iterations = 0;
    const maxIterations = 5;
    String decoded;
    do {
      decoded = cleaned;
      cleaned = htmlUnescape.convert(cleaned);
      iterations++;
    } while (decoded != cleaned && iterations < maxIterations);

    // Delete all remaining HTML tags → replace tag with space to avoid text sticking
    cleaned = cleaned.replaceAll(_tagRemovalRegex, ' ');

    // Normalize whitespace
    cleaned = cleaned.replaceAll(_whitespaceNormalizationRegex, ' ').trim();

    return cleaned;
  }

  static String wrapPlainTextLinks(String htmlString) {
    try {
      final document = parser.parse(htmlString);
      final container = document.body;

      if (container == null) return htmlString;

      _processNode(container, _urlRegex);

      return container.innerHtml;
    } catch (e) {
      logWarning('HtmlUtils::wrapPlainTextLinks:Exception = $e');
      return htmlString;
    }
  }

  static final _skipTags = {
    'a',
    'img',
    'video',
    'audio',
    'source',
    'link',
    'script',
    'iframe',
    'code',
    'pre',
  };

  static void _processNode(dom.Node node, RegExp urlRegex) {
    for (var child in node.nodes.toList()) {
      // Skip if node or parent node is in tag to skip
      final parentTag = child.parent?.localName;
      if (parentTag != null && _skipTags.contains(parentTag.toLowerCase())) {
        continue;
      }

      if (child.nodeType == dom.Node.TEXT_NODE) {
        final text = child.text ?? '';
        final matches = urlRegex.allMatches(text);

        if (matches.isEmpty) continue;

        final nodes = <dom.Node>[];
        int lastIndex = 0;

        for (final match in matches) {
          final url = match.group(0)!;
          final start = match.start;

          if (start > lastIndex) {
            nodes.add(dom.Text(text.substring(lastIndex, start)));
          }

          // ignore unsafe URLs
          if (url.toLowerCase().startsWith('javascript:') ||
              url.toLowerCase().startsWith('data:')) {
            nodes.add(dom.Text(url));
          } else {
            // Normalize href
            final href = url.startsWith(_protocolRegex)
                ? url
                : 'https://$url';

            final link = dom.Element.tag('a')
              ..attributes['href'] = href
              ..text = url;

            nodes.add(link);
          }

          lastIndex = match.end;
        }

        if (lastIndex < text.length) {
          nodes.add(dom.Text(text.substring(lastIndex)));
        }

        final parent = child.parent!;
        final index = parent.nodes.indexOf(child);

        parent.nodes.removeAt(index);
        parent.nodes.insertAll(index, nodes);
      } else {
        _processNode(child, urlRegex);
      }
    }
  }

  static String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}
