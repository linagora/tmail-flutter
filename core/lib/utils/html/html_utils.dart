
import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class HtmlUtils {
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
}
