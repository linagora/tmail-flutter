
import 'package:flutter/material.dart';

class HtmlTemplate {
  static const String printDocumentCssStyle = '''
    <style> 
      $fontFaceStyle 
      
      body,td,div,p,a,input {
        font-family: 'Inter', sans-serif;
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

  static const String fontFaceStyle = '''
    @font-face {
      font-family: 'Inter';
      src: url("/assets/fonts/Inter/Inter-Regular.ttf") format("truetype");
      font-weight: 400;
      font-style: normal;
    }
    
    @font-face {
      font-family: 'Inter';
      src: url("/assets/fonts/Inter/Inter-Medium.ttf") format("truetype");
      font-weight: 500;
      font-style: medium;
    }
    
    @font-face {
      font-family: 'Inter';
      src: url("/assets/fonts/Inter/Inter-SemiBold.ttf") format("truetype");
      font-weight: 600;
      font-style: semi-bold;
    }
    
    @font-face {
      font-family: 'Inter';
      src: url("/assets/fonts/Inter/Inter-Bold.ttf") format("truetype");
      font-weight: 700;
      font-style: bold;
    }
    
    body {
      font-family: 'Inter', sans-serif;
    }
  ''';

  static String defaultFontStyle({double fontSize = 14}) => '''
    body {
      font-weight: 400;
      font-size: ${fontSize}px;
      font-style: normal;
    }
    
    p {
      margin: 0px;
    }
  ''';

  static const String defaultEditorFontStyle = '''
   #editor, .note-editable, .note-frame {
      font-size: 16px;
      color: #222222;
    }
    
    p {
      margin: 0px;
    }
  ''';

  static const String previewEMLFileCssStyle = '''
    <style> 
      $fontFaceStyle

      body {
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

  static String webCustomInternalStyleCSS({
    bool useDefaultFontStyle = false,
    bool customScrollbar = false,
  }) => '''
    <style>
      ${HtmlTemplate.fontFaceStyle}
      
      ${useDefaultFontStyle ? HtmlTemplate.defaultEditorFontStyle : ''}
      
      ${customScrollbar ? '''
        html, .note-editable, .note-codable {
          overflow: auto;
        }
        
        html::-webkit-scrollbar, .note-editable::-webkit-scrollbar, .note-codable::-webkit-scrollbar {
          width: 6px;
          height: 6px;
        }
  
        html::-webkit-scrollbar-thumb, .note-editable::-webkit-scrollbar-thumb, .note-codable::-webkit-scrollbar-thumb {
          background-color: #c1c1c1;
          border-radius: 10px;
          min-height: 70px;
        }
        
       html::-webkit-scrollbar-track, .note-editable::-webkit-scrollbar-track, .note-codable::-webkit-scrollbar-track {
          background: transparent;
          border-radius: 10px;
        }
        
        /* Browsers without `::-webkit-scrollbar-*` support */
        @supports not selector(::-webkit-scrollbar) {
            html, .note-editable, .note-codable {
              scrollbar-width: thin;
              scrollbar-color: #c1c1c1 transparent;
            }
        }
      ''' : ''}
    </style>
  ''';

  static String mobileCustomInternalStyleCSS({
    bool useDefaultFontStyle = false,
    TextDirection direction = TextDirection.ltr,
  }) => '''
    ${HtmlTemplate.fontFaceStyle}
  
    ${useDefaultFontStyle ? HtmlTemplate.defaultEditorFontStyle : ''}
      
    #editor {
      direction: ${direction.name};
    }
    
    #editor .tmail-signature {
      text-align: ${direction == TextDirection.rtl ? 'right' : 'left'};
    }
  ''';

  static const String disableScrollingStyleCSS = '''
    html, body {
      overflow: hidden;
      overscroll-behavior: none;
      scrollbar-width: none; /* Firefox */
      -ms-overflow-style: none; /* IE/Edge */
    }
    ::-webkit-scrollbar {
        display: none;
      }
  ''';
}