
class HtmlTemplate {
  static const String fontLink = '<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">';
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

  static const String previewEMLFileCssStyle = '''
    <style> 
      body {
        font-family: Arial, 'Inter', sans-serif;
        color: #333;
        margin: 0;
        padding: 0;
      }
  
      .email-container {
        display: flex;
        flex-direction: column;
        gap: 10px;
        padding: 16px;
      }
  
      .email-subject {
        font-weight: bold;
        font-size: 16px;
        color: #333;
        margin-bottom: 10px;
      }
  
      .email-header {
        display: flex;
        align-items: flex-start;
        gap: 10px;
      }
      
      .circle {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        background: linear-gradient(to bottom, #a8e4d1, #56c2a6);
        font-size: 18px;
        font-weight: bold;
        color: white;
        text-transform: uppercase;
        flex-shrink: 0;
      }
  
      .email-info {
        display: flex;
        flex-direction: column;
        flex-grow: 1;
      }
  
      .sender {
        font-weight: bold;
        color: #333;
      }
  
      .sender-email {
        font-size: 12px;
        color: #666;
      }
  
      .recipients {
        font-size: 12px;
        color: #666;
        margin-top: 5px;
        word-wrap: break-word;
        line-height: 1.5;
      }
  
      .email-meta {
        display: flex;
        align-items: center;
        gap: 5px;
      }
  
      .attachment-icon {
        width: 16px;
        height: 16px;
      }
  
      .email-date {
        font-size: 12px;
        color: #666;
        white-space: nowrap;
      }
  
      .email-body {
        font-size: 14px;
        color: #333;
        margin-top: 10px;
        margin-left: 40px;
      }
  
      .attachments {
        margin-top: 15px;
        padding-top: 10px;
        border-top: 1px solid #ddd;
        margin-left: 40px;
      }
  
      .attachment-title {
        font-weight: bold;
        color: #333;
        margin-bottom: 10px;
        font-size: 14px;
      }
  
      .attachment-item {
        display: flex;
        align-items: flex-start;
        gap: 10px;
        font-size: 12px;
        color: #666;
        margin-bottom: 10px;
        cursor: pointer;
        padding: 5px;
        transition: background-color 0.3s, box-shadow 0.3s;
      }
  
      .attachment-item:hover {
        background-color: #f5f5f5;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
      }
  
      .attachment-item .icon {
        width: 20px;
        height: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: #f2f2f2;
        border-radius: 50%;
        color: #007bff;
      }
  
      .attachment-item .file-details {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
      }
  
      .attachment-item .file-name {
        font-weight: bold;
      }
  
      .attachment-item .file-size {
        font-size: 12px;
        color: #666;
      }
     </style>
  ''';

  static const String markDownAndASCIIArtStyleCSS = 'display: block; font-family: monospace; white-space: pre; margin: 1em 0px;';
}