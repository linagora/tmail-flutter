
import 'package:flutter/material.dart';

const nameClassToolTip = 'tmail-tooltip';

const tooltipLinkCss = '''
  .$nameClassToolTip .tooltiptext {
    visibility: hidden;
    max-width: 400px;
    background-color: black;
    color: #fff;
    text-align: center;
    border-radius: 6px;
    padding: 5px 8px 5px 8px;
    white-space: nowrap; 
    overflow: hidden;
    text-overflow: ellipsis;
    position: absolute;
    z-index: 1;
  }
  .$nameClassToolTip:hover .tooltiptext {
    visibility: visible;
  }
''';

String generateHtml(String content, {
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
    ${javaScripts ?? ''}
    </head>
    <body ${direction == TextDirection.rtl ? 'dir="rtl"' : ''} style = "overflow-x: hidden">
    <div class="tmail-content">$content</div>
    </body>
    </html> 
  ''';
}

const bodyCssStyleForEditor = '''
  <style>
      blockquote {
        margin-left: 8px;
        margin-right: 8px;
        padding-left: 12px;
        padding-right: 12px;
        border-left: 5px solid #eee;
      }
      pre {
        display: block;
        padding: 10px;
        margin: 0 0 10px;
        font-size: 13px;
        line-height: 1.5;
        color: #333;
        word-break: break-all;
        word-wrap: break-word;
        background-color: #f5f5f5;
        border: 1px solid #ccc;
        border-radius: 4px;
        overflow: auto;
      }
  </style>
''';