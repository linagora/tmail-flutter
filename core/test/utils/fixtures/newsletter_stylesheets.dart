// Stylesheets copied verbatim from MIT-licensed open-source email templates,
// used to check that sanitizing keeps their responsive and dark mode rules.
// `keptInMedia` lists, per `@media` prelude, declarations (whitespace removed,
// lowercase) that every pipeline must keep; `keptOutsideMedia` does the same
// for the plain rules next to them.

class NewsletterStylesheet {
  final String name;
  final String source;
  final String html;
  final Map<String, List<String>> keptInMedia;
  final List<String> keptOutsideMedia;

  const NewsletterStylesheet({
    required this.name,
    required this.source,
    required this.html,
    required this.keptInMedia,
    required this.keptOutsideMedia,
  });
}

const newsletterStylesheets = <NewsletterStylesheet>[
  NewsletterStylesheet(
    name: 'Cerberus responsive template',
    source: 'https://github.com/emailmonday/Cerberus',
    html: r'''<style>
            * {
                font-family: sans-serif !important;
            }
        </style><style>

        /* What it does: Tells the email client that both light and dark styles are provided. A duplicate of meta color-scheme meta tag above. */
        :root {
          color-scheme: light dark;
          supported-color-schemes: light dark;
        }

        /* What it does: Remove spaces around the email design added by some email clients. */
        /* Beware: It can remove the padding / margin and add a background color to the compose a reply window. */
        html,
        body {
            margin: 0 auto !important;
            padding: 0 !important;
            height: 100% !important;
            width: 100% !important;
        }

        /* What it does: Stops email clients resizing small text. */
        * {
            -ms-text-size-adjust: 100%;
            -webkit-text-size-adjust: 100%;
        }

        /* What it does: Centers email on Android 4.4 */
        div[style*="margin: 16px 0"] {
            margin: 0 !important;
        }

        /* What it does: forces Samsung Android mail clients to use the entire viewport */
        #MessageViewBody, #MessageWebViewDiv{
            width: 100% !important;
        }

        /* What it does: Stops Outlook from adding extra spacing to tables. */
        table,
        td {
            mso-table-lspace: 0pt !important;
            mso-table-rspace: 0pt !important;
        }

        /* What it does: Replaces default bold style. */
        th {
        	font-weight: normal;
        }

        /* What it does: Fixes webkit padding issue. */
        table {
            border-spacing: 0 !important;
            border-collapse: collapse !important;
            table-layout: fixed !important;
            margin: 0 auto !important;
        }

        /* What it does: Prevents Windows 10 Mail from underlining links despite inline CSS. Styles for underlined links should be inline. */
        a {
            text-decoration: none;
        }

        /* What it does: Uses a better rendering method when resizing images in IE. */
        img {
            -ms-interpolation-mode:bicubic;
        }

        /* What it does: A work-around for email clients meddling in triggered links. */
        a[x-apple-data-detectors],  /* iOS */
        .unstyle-auto-detected-links a,
        .aBn {
            border-bottom: 0 !important;
            cursor: default !important;
            color: inherit !important;
            text-decoration: none !important;
            font-size: inherit !important;
            font-family: inherit !important;
            font-weight: inherit !important;
            line-height: inherit !important;
        }

        /* What it does: Prevents Gmail from changing the text color in conversation threads. */
        .im {
            color: inherit !important;
        }

        /* What it does: Prevents Gmail from displaying a download button on large, non-linked images. */
        .a6S {
           display: none !important;
           opacity: 0.01 !important;
		}
		/* If the above doesn't work, add a .g-img class to any image in question. */
		img.g-img + div {
		   display: none !important;
		}

        /* What it does: Removes right gutter in Gmail iOS app: https://github.com/TedGoas/Cerberus/issues/89  */
        /* Create one of these media queries for each additional viewport size you'd like to fix */

        /* iPhone 4, 4S, 5, 5S, 5C, and 5SE */
        @media only screen and (min-device-width: 320px) and (max-device-width: 374px) {
            u ~ div .email-container {
                min-width: 320px !important;
            }
        }
        /* iPhone 6, 6S, 7, 8, and X */
        @media only screen and (min-device-width: 375px) and (max-device-width: 413px) {
            u ~ div .email-container {
                min-width: 375px !important;
            }
        }
        /* iPhone 6+, 7+, and 8+ */
        @media only screen and (min-device-width: 414px) {
            u ~ div .email-container {
                min-width: 414px !important;
            }
        }

    </style><style>

        /* What it does: Hover styles for buttons */
        .button-td,
        .button-a {
            transition: all 100ms ease-in;
        }
	    .button-td-primary:hover,
	    .button-a-primary:hover {
	        background: #555555 !important;
	        border-color: #555555 !important;
	    }

        /* Media Queries */
        @media screen and (max-width: 600px) {

            .email-container {
                width: 100% !important;
                margin: auto !important;
            }

            /* What it does: Forces table cells into full-width rows. */
            .stack-column,
            .stack-column-center {
                display: block !important;
                width: 100% !important;
                max-width: 100% !important;
                direction: ltr !important;
            }
            /* And center justify these ones. */
            .stack-column-center {
                text-align: center !important;
            }

            /* What it does: Generic utility class for centering. Useful for images, buttons, and nested tables. */
            .center-on-narrow {
                text-align: center !important;
                display: block !important;
                margin-left: auto !important;
                margin-right: auto !important;
                float: none !important;
            }
            table.center-on-narrow {
                display: inline-block !important;
            }

            /* What it does: Adjust typography on small screens to improve readability */
            .email-container p {
                font-size: 17px !important;
            }
        }

        /* Dark Mode Styles : BEGIN */
        @media (prefers-color-scheme: dark) {
            .email-bg {
                background: #111111 !important;
            }
            .darkmode-bg {
                background: #222222 !important;
            }
            h1,
            h2,
            h3,
            p,
            li,
            .darkmode-text,
            .email-container a:not([class]) {
                color: #F7F7F9 !important;
            }
            td.button-td-primary,
            td.button-td-primary a {
                background: #ffffff !important;
                border-color: #ffffff !important;
                color: #222222 !important;
            }
            td.button-td-primary:hover,
            td.button-td-primary a:hover {
                background: #cccccc !important;
                border-color: #cccccc !important;
            }
            .footer td {
                color: #aaaaaa !important;
            }
            .darkmode-fullbleed-bg {
                background-color: #0F3016 !important;
            }
        }
        /* Dark Mode Styles : END */
    </style><div class="email-container"><p>Body</p></div>''',
    keptInMedia: {
      '@mediaonlyscreenand(min-device-width:320px)and(max-device-width:374px)': [
        'min-width:320px!important',
      ],
      '@mediaonlyscreenand(min-device-width:375px)and(max-device-width:413px)': [
        'min-width:375px!important',
      ],
      '@mediaonlyscreenand(min-device-width:414px)': [
        'min-width:414px!important',
      ],
      '@mediascreenand(max-width:600px)': [
        'direction:ltr!important',
        'display:block!important',
        'display:inline-block!important',
        'font-size:17px!important',
        'margin-left:auto!important',
        'margin-right:auto!important',
        'margin:auto!important',
        'max-width:100%!important',
        'text-align:center!important',
        'width:100%!important',
      ],
      '@media(prefers-color-scheme:dark)': [
        'background-color:#0f3016!important',
        'background:#111111!important',
        'background:#222222!important',
        'background:#cccccc!important',
        'background:#ffffff!important',
        'border-color:#cccccc!important',
        'border-color:#ffffff!important',
        'color:#222222!important',
        'color:#aaaaaa!important',
        'color:#f7f7f9!important',
      ],
    },
    keptOutsideMedia: [
      'background:#555555!important',
      'border-bottom:0!important',
      'border-collapse:collapse!important',
      'border-color:#555555!important',
      'border-spacing:0!important',
      'color:inherit!important',
      'display:none!important',
      'font-family:inherit!important',
      'font-size:inherit!important',
      'font-weight:inherit!important',
      'font-weight:normal',
      'height:100%!important',
      'line-height:inherit!important',
      'margin:0!important',
      'margin:0auto!important',
      'opacity:0.01!important',
      'padding:0!important',
      'table-layout:fixed!important',
      'text-decoration:none',
      'text-decoration:none!important',
      'width:100%!important',
    ],
  ),
  NewsletterStylesheet(
    name: 'Responsive HTML email template by Lee Munroe',
    source: 'https://github.com/leemunroe/responsive-html-email-template',
    html: r'''<style>
    /* -------------------------------------
    GLOBAL RESETS
------------------------------------- */
    
    body {
      font-family: Helvetica, sans-serif;
      -webkit-font-smoothing: antialiased;
      font-size: 16px;
      line-height: 1.3;
      -ms-text-size-adjust: 100%;
      -webkit-text-size-adjust: 100%;
    }
    
    table {
      border-collapse: separate;
      mso-table-lspace: 0pt;
      mso-table-rspace: 0pt;
      width: 100%;
    }
    
    table td {
      font-family: Helvetica, sans-serif;
      font-size: 16px;
      vertical-align: top;
    }
    /* -------------------------------------
    BODY & CONTAINER
------------------------------------- */
    
    body {
      background-color: #f4f5f6;
      margin: 0;
      padding: 0;
    }
    
    .body {
      background-color: #f4f5f6;
      width: 100%;
    }
    
    .container {
      margin: 0 auto !important;
      max-width: 600px;
      padding: 0;
      padding-top: 24px;
      width: 600px;
    }
    
    .content {
      box-sizing: border-box;
      display: block;
      margin: 0 auto;
      max-width: 600px;
      padding: 0;
    }
    /* -------------------------------------
    HEADER, FOOTER, MAIN
------------------------------------- */
    
    .main {
      background: #ffffff;
      border: 1px solid #eaebed;
      border-radius: 16px;
      width: 100%;
    }
    
    .wrapper {
      box-sizing: border-box;
      padding: 24px;
    }
    
    .footer {
      clear: both;
      padding-top: 24px;
      text-align: center;
      width: 100%;
    }
    
    .footer td,
    .footer p,
    .footer span,
    .footer a {
      color: #9a9ea6;
      font-size: 16px;
      text-align: center;
    }
    /* -------------------------------------
    TYPOGRAPHY
------------------------------------- */
    
    p {
      font-family: Helvetica, sans-serif;
      font-size: 16px;
      font-weight: normal;
      margin: 0;
      margin-bottom: 16px;
    }
    
    a {
      color: #0867ec;
      text-decoration: underline;
    }
    /* -------------------------------------
    BUTTONS
------------------------------------- */
    
    .btn {
      box-sizing: border-box;
      min-width: 100% !important;
      width: 100%;
    }
    
    .btn > tbody > tr > td {
      padding-bottom: 16px;
    }
    
    .btn table {
      width: auto;
    }
    
    .btn table td {
      background-color: #ffffff;
      border-radius: 4px;
      text-align: center;
    }
    
    .btn a {
      background-color: #ffffff;
      border: solid 2px #0867ec;
      border-radius: 4px;
      box-sizing: border-box;
      color: #0867ec;
      cursor: pointer;
      display: inline-block;
      font-size: 16px;
      font-weight: bold;
      margin: 0;
      padding: 12px 24px;
      text-decoration: none;
      text-transform: capitalize;
    }
    
    .btn-primary table td {
      background-color: #0867ec;
    }
    
    .btn-primary a {
      background-color: #0867ec;
      border-color: #0867ec;
      color: #ffffff;
    }
    
    @media all {
      .btn-primary table td:hover {
        background-color: #ec0867 !important;
      }
      .btn-primary a:hover {
        background-color: #ec0867 !important;
        border-color: #ec0867 !important;
      }
    }
    
    /* -------------------------------------
    OTHER STYLES THAT MIGHT BE USEFUL
------------------------------------- */
    
    .last {
      margin-bottom: 0;
    }
    
    .first {
      margin-top: 0;
    }
    
    .align-center {
      text-align: center;
    }
    
    .align-right {
      text-align: right;
    }
    
    .align-left {
      text-align: left;
    }
    
    .text-link {
      color: #0867ec !important;
      text-decoration: underline !important;
    }
    
    .clear {
      clear: both;
    }
    
    .mt0 {
      margin-top: 0;
    }
    
    .mb0 {
      margin-bottom: 0;
    }
    
    .preheader {
      color: transparent;
      display: none;
      height: 0;
      max-height: 0;
      max-width: 0;
      opacity: 0;
      overflow: hidden;
      mso-hide: all;
      visibility: hidden;
      width: 0;
    }
    
    .powered-by a {
      text-decoration: none;
    }
    
    /* -------------------------------------
    RESPONSIVE AND MOBILE FRIENDLY STYLES
------------------------------------- */
    
    @media only screen and (max-width: 640px) {
      .main p,
      .main td,
      .main span {
        font-size: 16px !important;
      }
      .wrapper {
        padding: 8px !important;
      }
      .content {
        padding: 0 !important;
      }
      .container {
        padding: 0 !important;
        padding-top: 8px !important;
        width: 100% !important;
      }
      .main {
        border-left-width: 0 !important;
        border-radius: 0 !important;
        border-right-width: 0 !important;
      }
      .btn table {
        max-width: 100% !important;
        width: 100% !important;
      }
      .btn a {
        font-size: 16px !important;
        max-width: 100% !important;
        width: 100% !important;
      }
    }
    /* -------------------------------------
    PRESERVE THESE STYLES IN THE HEAD
------------------------------------- */
    
    @media all {
      .ExternalClass {
        width: 100%;
      }
      .ExternalClass,
      .ExternalClass p,
      .ExternalClass span,
      .ExternalClass font,
      .ExternalClass td,
      .ExternalClass div {
        line-height: 100%;
      }
      .apple-link a {
        color: inherit !important;
        font-family: inherit !important;
        font-size: inherit !important;
        font-weight: inherit !important;
        line-height: inherit !important;
        text-decoration: none !important;
      }
      #MessageViewBody a {
        color: inherit;
        text-decoration: none;
        font-size: inherit;
        font-family: inherit;
        font-weight: inherit;
        line-height: inherit;
      }
    }
    </style><div class="email-container"><p>Body</p></div>''',
    keptInMedia: {
      '@mediaall': [
        'background-color:#ec0867!important',
        'border-color:#ec0867!important',
        'color:inherit',
        'color:inherit!important',
        'font-family:inherit',
        'font-family:inherit!important',
        'font-size:inherit',
        'font-size:inherit!important',
        'font-weight:inherit',
        'font-weight:inherit!important',
        'line-height:100%',
        'line-height:inherit',
        'line-height:inherit!important',
        'text-decoration:none',
        'text-decoration:none!important',
        'width:100%',
      ],
      '@mediaonlyscreenand(max-width:640px)': [
        'border-radius:0!important',
        'font-size:16px!important',
        'max-width:100%!important',
        'padding-top:8px!important',
        'padding:0!important',
        'padding:8px!important',
        'width:100%!important',
      ],
    },
    keptOutsideMedia: [
      'background-color:#0867ec',
      'background-color:#f4f5f6',
      'background-color:#ffffff',
      'background:#ffffff',
      'border-collapse:separate',
      'border-color:#0867ec',
      'border-radius:16px',
      'border-radius:4px',
      'border:1pxsolid#eaebed',
      'border:solid2px#0867ec',
      'box-sizing:border-box',
      'color:#0867ec',
      'color:#0867ec!important',
      'color:#9a9ea6',
      'color:#ffffff',
      'color:transparent',
      'display:block',
      'display:inline-block',
      'display:none',
      'font-family:helvetica,sans-serif',
      'font-size:16px',
      'font-weight:bold',
      'font-weight:normal',
      'line-height:1.3',
      'margin-bottom:0',
      'margin-bottom:16px',
      'margin-top:0',
      'margin:0',
      'margin:0auto',
      'margin:0auto!important',
      'max-width:600px',
      'min-width:100%!important',
      'opacity:0',
      'overflow:hidden',
      'padding-bottom:16px',
      'padding-top:24px',
      'padding:0',
      'padding:12px24px',
      'padding:24px',
      'text-align:center',
      'text-align:left',
      'text-align:right',
      'text-decoration:none',
      'text-decoration:underline',
      'text-decoration:underline!important',
      'text-transform:capitalize',
      'vertical-align:top',
      'width:100%',
      'width:600px',
      'width:auto',
    ],
  ),
  NewsletterStylesheet(
    name: 'Antwort single-column template',
    source: 'https://github.com/InterNations/antwort',
    html: r'''<style>
body {
  margin: 0;
  padding: 0;
  -ms-text-size-adjust: 100%;
  -webkit-text-size-adjust: 100%;
}

table {
  border-spacing: 0;
}

table td {
  border-collapse: collapse;
}

.ExternalClass {
  width: 100%;
}

.ExternalClass,
.ExternalClass p,
.ExternalClass span,
.ExternalClass font,
.ExternalClass td,
.ExternalClass div {
  line-height: 100%;
}

.ReadMsgBody {
  width: 100%;
  background-color: #ebebeb;
}

table {
  mso-table-lspace: 0pt;
  mso-table-rspace: 0pt;
}

img {
  -ms-interpolation-mode: bicubic;
}

.yshortcuts a {
  border-bottom: none !important;
}

@media screen and (max-width: 599px) {
  .force-row,
  .container {
    width: 100% !important;
    max-width: 100% !important;
  }
}
@media screen and (max-width: 400px) {
  .container-padding {
    padding-left: 12px !important;
    padding-right: 12px !important;
  }
}
.ios-footer a {
  color: #aaaaaa !important;
  text-decoration: underline;
}
a[href^="x-apple-data-detectors:"],
a[x-apple-data-detectors] {
  color: inherit !important;
  text-decoration: none !important;
  font-size: inherit !important;
  font-family: inherit !important;
  font-weight: inherit !important;
  line-height: inherit !important;
}
</style><div class="email-container"><p>Body</p></div>''',
    keptInMedia: {
      '@mediascreenand(max-width:599px)': [
        'max-width:100%!important',
        'width:100%!important',
      ],
      '@mediascreenand(max-width:400px)': [
        'padding-left:12px!important',
        'padding-right:12px!important',
      ],
    },
    keptOutsideMedia: [
      'background-color:#ebebeb',
      'border-bottom:none!important',
      'border-collapse:collapse',
      'border-spacing:0',
      'color:#aaaaaa!important',
      'color:inherit!important',
      'font-family:inherit!important',
      'font-size:inherit!important',
      'font-weight:inherit!important',
      'line-height:100%',
      'line-height:inherit!important',
      'margin:0',
      'padding:0',
      'text-decoration:none!important',
      'text-decoration:underline',
      'width:100%',
    ],
  ),
];
