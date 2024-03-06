
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

  static const String printDocumentCssStyle = '''
    <style> 
      body,td,div,p,a,input {
        font-family: arial, sans-serif;
      }
    
      body, td {
        font-size: 13px;
      }
      
      a:link, a:active {
        color: #1155CC;
        text-decoration: none;
      }
      
      a:hover {
        text-decoration: underline;
        cursor: pointer;
      }
      
      a:visited{
        color: #6611CC;
      }
      
      img {
         border: 0px
      }
      
      pre {
         white-space: pre;
         white-space: -moz-pre-wrap;
         white-space: -o-pre-wrap;
         white-space: pre-wrap;
         word-wrap: break-word;
         max-width: 800px;
         overflow: auto;
      }
      
      .logo {
         position: relative;
      }
     </style>
  ''';
}