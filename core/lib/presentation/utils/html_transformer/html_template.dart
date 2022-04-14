
final tooltipLinkCss = '''
  .tooltip .tooltiptext {
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
  .tooltip:hover .tooltiptext {
    visibility: visible;
  }
''';

String generateHtml(String content, {
  double? minHeight,
  double? minWidth,
  String? styleCSS,
  String? javaScripts
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
      }
      ${styleCSS ?? ''}
    </style>
    ${javaScripts ?? ''}
    </head>
    <body>
    <div class="tmail-content">${content}</div>
    </body>
    </html> 
  ''';
}