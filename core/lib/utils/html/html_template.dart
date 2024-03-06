
class HtmlTemplate {
  static const String nameClassToolTip = 'tmail-tooltip';
  static const String tooltipLinkCss = '''
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

  static const String sampleHtmlDocument = '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      </head>
      <body</body>
    </html> 
  ''';
}