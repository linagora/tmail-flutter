
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
      
      .tmail-signature {
        text-align: ${direction == TextDirection.rtl ? 'right' : 'left'};
        margin: 16px 0px 16px 0px;
      }
    
      .tmail-signature-button,
      .tmail-signature-button * {
        box-sizing: border-box;
      }
    
      .tmail-signature-button {
        padding: 6px 40px 6px 16px;
        border-radius: 4px;
        color: #fff;
        background-image: url("data:image/svg+xml,%3Csvg width='20' height='20' viewBox='0 0 20 20' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M10.0003 11.8319L5.53383 8.1098C5.18027 7.81516 4.6548 7.86293 4.36016 8.21649C4.06553 8.57006 4.1133 9.09553 4.46686 9.39016L9.46686 13.5568C9.7759 13.8144 10.2248 13.8144 10.5338 13.5568L15.5338 9.39016C15.8874 9.09553 15.9352 8.57006 15.6405 8.21649C15.3459 7.86293 14.8204 7.81516 14.4669 8.1098L10.0003 11.8319Z' fill='%23AEAEC0'/%3E%3C/svg%3E%0A");
        background-repeat: no-repeat;
        background-position: right 16px center;
        background-color: #FFFFFF;
        border-radius: 36px;
        border-style: solid;
        border-color: var(--m-3-syslight-outline-shadow-outline-variant, #cac4d0);
        border-width: 0.5px;
        flex-direction: row;
        gap: 8px;
        align-items: center;
        justify-content: flex-start;
        flex-shrink: 0;
        position: relative;
        cursor: pointer;
        color: var(--m-3-syslight-tetirary-tertiary, #8c9caf);
        text-align: left;
        font: var(--m-3-body-large-2, 400 17px/24px "Inter", sans-serif);
      }
    
      .tmail-signature-content {
        padding: 12px;
        overflow: hidden;
      }
    </style>
    </head>
    <body ${direction == TextDirection.rtl ? 'dir="rtl"' : ''} style = "overflow-x: hidden">
    <div class="tmail-content">$content</div>
    ${javaScripts ?? ''}
    </body>
    </html> 
  ''';
}