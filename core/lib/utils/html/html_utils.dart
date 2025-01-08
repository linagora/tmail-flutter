import 'dart:convert';
import 'dart:math';

import 'js_interop_stub.dart' if (dart.library.html) 'dart:js_interop';
import 'dart:typed_data';

import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class HtmlUtils {
  static final random = Random();

  static const lineHeight100Percent = (
    script: '''
      document.querySelectorAll("*")
        .forEach((element) => {
          if (element.style.lineHeight !== "normal")
            element.style.lineHeight = "100%";
        });''',
    name: 'lineHeight100Percent');

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

  static String customCssStyleHtmlEditor({
    TextDirection direction = TextDirection.ltr,
    bool useDefaultFont = false,
  }) {
    if (PlatformInfo.isWeb) {
      return '''
        <style>
          ${useDefaultFont ? '''
            body {
              font-family: Arial, 'Inter', sans-serif;
              font-weight: 500;
              font-size: 16px;
              line-height: 24px;
            }
          ''' : ''}
        
          .note-editable {
            direction: ${direction.name};
          }
          
          .note-editable .tmail-signature {
            text-align: ${direction == TextDirection.rtl ? 'right' : 'left'};
          }
        </style>
      ''';
    } else if (PlatformInfo.isMobile) {
      return '''
        ${useDefaultFont ? '''
          body {
            font-family: Arial, 'Inter', sans-serif;
            font-weight: 500;
            font-size: 16px;
            line-height: 24px;
          }
        ''' : ''}
        
        #editor {
          direction: ${direction.name};
        }
        
        #editor .tmail-signature {
          text-align: ${direction == TextDirection.rtl ? 'right' : 'left'};
        }
      ''';
    } else {
      return '';
    }
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
    log('HtmlUtils::convertBase64ToImageResourceData:');
    mimeType = validateHtmlImageResourceMimeType(mimeType);
    if (!base64Data.endsWith('==')) {
      base64Data.append('==');
    }
    final imageResource = 'data:$mimeType;base64,$base64Data';
    return imageResource;
  }

  static String generateHtmlDocument({
    required String content,
    double? minHeight,
    double? minWidth,
    String? styleCSS,
    String? javaScripts,
    bool hideScrollBar = true,
    bool useDefaultFont = false,
    TextDirection? direction,
    double? contentPadding,
  }) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      ${useDefaultFont && PlatformInfo.isMobile
        ? '<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap" rel="stylesheet">'
        : ''}
      <style>
        ${useDefaultFont ? '''
          body {
            font-family: 'Inter', sans-serif;
            font-weight: 500;
            font-size: 16px;
            line-height: 24px;
          }
        ''' : ''}
        .tmail-content {
          min-height: ${minHeight ?? 0}px;
          min-width: ${minWidth ?? 0}px;
          overflow: auto;
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
      logError('AppUtils::openNewWindowByUrl:Exception = $e');
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
      logError('AppUtils::setWindowBrowserTitle:Exception = $e');
    }
  }
}
