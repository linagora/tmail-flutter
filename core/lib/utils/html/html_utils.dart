import 'js_interop_stub.dart' if (dart.library.html) 'dart:js_interop';
import 'dart:typed_data';

import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class HtmlUtils {
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
      console.log("unregisterDropListener");
      const editor = document.querySelector(".note-editable");
      const newEditor = editor.cloneNode(true);
      editor.parentNode.replaceChild(newEditor, editor);''',
    name: 'unregisterDropListener');

  static String customCssStyleHtmlEditor({TextDirection direction = TextDirection.ltr}) {
    if (PlatformInfo.isWeb) {
      return '''
        <style>
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
    mimeType = validateHtmlImageResourceMimeType(mimeType);
    if (!base64Data.endsWith('==')) {
      base64Data.append('==');
    }
    final imageResource = 'data:$mimeType;base64,$base64Data';
    log('HtmlUtils::convertBase64ToImageResourceData:imageResource: $imageResource');
    return imageResource;
  }

  static String generateHtmlDocument({
    required String content,
    double? minHeight,
    double? minWidth,
    String? styleCSS,
    String? javaScripts,
    bool hideScrollBar = true,
    TextDirection? direction
  }) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <style>
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
      <body ${direction == TextDirection.rtl ? 'dir="rtl"' : ''} style = "overflow-x: hidden">
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

  static get iframeFullScreenCssStyle => '''
      position: fixed;
      border: 0;
      width: 100%;
      height: 100%;''';

  static String pdfViewer(Uint8List bytes) {
    return '''
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8" />
        </head>
        <style>
          body {
            margin: 0;
          }

          iframe {
            ${HtmlUtils.iframeFullScreenCssStyle}
          }
        </style>
        <body></body>
        <script>
          const bytesJs = new Uint8Array(${bytes.toJS}).buffer;
          const blob = new Blob([bytesJs], { type: "application/pdf" });
          const url = URL.createObjectURL(blob);

          window.onload = function() {
            const iframe = document.createElement("iframe");
            iframe.src = url;
            document.body.appendChild(iframe);
          };
          window.addEventListener("beforeunload", function listener(event) {
            URL.revokeObjectURL(url);
            window.removeEventListener("beforeunload", listener);
          });
        </script>
      </html>''';
  }
}
