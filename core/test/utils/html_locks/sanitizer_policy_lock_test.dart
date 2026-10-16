@TestOn('vm')

import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' show parseFragment;

import 'html_lock_golden.dart';

/// Locks what the email sanitizer keeps, observed through the production
/// entry point ([StandardizeHtmlSanitizingTransformers]) rather than the
/// sanitize_html fork's internals. A fork bump or policy edit that allows a
/// new tag/attribute/CSS property/URL scheme — or drops one we rely on —
/// fails here with the exact entry that changed.
void main() {
  const sanitizer = StandardizeHtmlSanitizingTransformers();
  const htmlEscape = HtmlEscape();

  String sanitize(String html) => sanitizer.process(html, htmlEscape);

  group('sanitizer policy lock', () {
    test('tags', () {
      final lines = _tagCandidates.map((tag) {
        final probe = _tagProbe(tag);
        final kept = parseFragment(sanitize(probe.html))
                .querySelector(probe.selector) !=
            null;
        return '${kept ? 'keep' : 'drop'}  $tag';
      });
      expectMatchesHtmlLock('sanitizer_policy/tags.txt', lines.join('\n'));
    });

    test('attributes', () {
      final lines = _attributeCandidates.map((candidate) {
        final (tag, attribute, value) = candidate;
        final html = _voidTags.contains(tag)
            ? '<$tag $attribute="$value">'
            : '<$tag $attribute="$value">x</$tag>';
        final element = parseFragment(sanitize(html)).querySelector(tag);
        final kept = element?.attributes[attribute];
        final result = kept == null
            ? 'drop'
            : kept == value
                ? 'keep'
                : 'keep -> "$kept"';
        return '$result  $tag[$attribute="$value"]';
      });
      expectMatchesHtmlLock('sanitizer_policy/attributes.txt', lines.join('\n'));
    });

    test('inline css', () {
      final lines = _cssCandidates.map((declaration) {
        final element = parseFragment(
          sanitize('<div style="$declaration">x</div>'),
        ).querySelector('div');
        final style = element?.attributes['style']?.trim() ?? '';
        return '$declaration  =>  ${style.isEmpty ? '<dropped>' : style}';
      });
      expectMatchesHtmlLock('sanitizer_policy/css.txt', lines.join('\n'));
    });

    test('url schemes', () {
      final lines = <String>[];
      for (final (tag, attribute) in const [('a', 'href'), ('img', 'src')]) {
        for (final url in _urlCandidates) {
          final html = tag == 'img'
              ? '<img $attribute="$url" alt="x">'
              : '<a $attribute="$url">x</a>';
          final element = parseFragment(sanitize(html)).querySelector(tag);
          final kept = element?.attributes[attribute];
          lines.add(
            '${kept == null ? 'drop' : kept == url ? 'keep' : 'keep -> "$kept"'}'
            '  $tag[$attribute="$url"]',
          );
        }
      }
      expectMatchesHtmlLock('sanitizer_policy/urls.txt', lines.join('\n'));
    });
  });
}

class _TagProbe {
  const _TagProbe(this.html, this.selector);

  final String html;
  final String selector;
}

const _voidTags = {
  'br', 'hr', 'img', 'wbr', 'col', 'input', 'meta', 'link', 'base', 'embed',
  'area', 'source', 'track', 'param',
};

const _svgChildren = {
  'g', 'path', 'polygon', 'rect', 'circle', 'ellipse', 'line', 'polyline',
  'text', 'animate', 'set', 'animatemotion', 'animatetransform', 'mpath',
  'foreignobject', 'use', 'image',
};

/// Tags the parser only keeps inside a parent (a `td` outside a table is
/// dropped by the parser, not the sanitizer), wrapped in that parent.
const _tagsInContext = {
  'tr': '<table><tbody><tr><td>x</td></tr></tbody></table>',
  'td': '<table><tbody><tr><td>x</td></tr></tbody></table>',
  'tbody': '<table><tbody><tr><td>x</td></tr></tbody></table>',
  'th': '<table><tbody><tr><th>x</th></tr></tbody></table>',
  'thead': '<table><thead><tr><td>x</td></tr></thead></table>',
  'tfoot': '<table><tfoot><tr><td>x</td></tr></tfoot></table>',
  'caption': '<table><caption>x</caption></table>',
  'colgroup': '<table><colgroup><col></colgroup><tbody><tr><td>x</td></tr></tbody></table>',
  'col': '<table><colgroup><col></colgroup><tbody><tr><td>x</td></tr></tbody></table>',
  'li': '<ul><li>x</li></ul>',
  'dt': '<dl><dt>x</dt></dl>',
  'dd': '<dl><dd>x</dd></dl>',
  'rt': '<ruby>x<rt>y</rt></ruby>',
  'rp': '<ruby>x<rp>y</rp></ruby>',
  'summary': '<details><summary>x</summary></details>',
  'figcaption': '<figure><figcaption>x</figcaption></figure>',
  'option': '<select><option>x</option></select>',
};

_TagProbe _tagProbe(String tag) {
  final html = _tagsInContext[tag] ??
      (_svgChildren.contains(tag)
          ? '<svg><$tag></$tag></svg>'
          : _voidTags.contains(tag)
              ? '<div><$tag></div>'
              : '<div><$tag>x</$tag></div>');
  return _TagProbe(html, tag);
}

const _tagCandidates = [
  // Text and structure.
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'br', 'hr', 'div', 'span', 'pre',
  'code', 'tt', 'kbd', 'samp', 'var', 'b', 'i', 'u', 's', 'strike', 'strong',
  'em', 'small', 'big', 'mark', 'sub', 'sup', 'ins', 'del', 'q', 'cite',
  'abbr', 'dfn', 'time', 'bdo', 'bdi', 'wbr', 'font', 'center', 'blink',
  'marquee', 'address', 'blockquote', 'section', 'article', 'aside', 'header',
  'footer', 'nav', 'main', 'figure', 'figcaption', 'details', 'summary',
  'ruby', 'rt', 'rp', 'a', 'img', 'picture', 'source', 'video', 'audio',
  'track', 'canvas', 'map', 'area',
  // Lists and tables.
  'ol', 'ul', 'li', 'dl', 'dt', 'dd', 'table', 'caption', 'colgroup', 'col',
  'thead', 'tbody', 'tfoot', 'tr', 'th', 'td',
  // Document-level and active content.
  'style', 'script', 'noscript', 'template', 'iframe', 'frame', 'frameset',
  'object', 'embed', 'applet', 'param', 'base', 'link', 'meta', 'title',
  'form', 'input', 'button', 'textarea', 'select', 'option', 'label',
  'fieldset', 'legend', 'output', 'dialog', 'slot', 'portal', 'math',
  // SVG.
  'svg', 'g', 'path', 'polygon', 'rect', 'circle', 'ellipse', 'line',
  'polyline', 'text', 'use', 'image', 'foreignobject', 'animate', 'set',
  'animatemotion', 'animatetransform', 'mpath',
];

const _attributeCandidates = <(String, String, String)>[
  // Generic presentation / accessibility, on a div.
  ('div', 'id', 'main'),
  ('div', 'class', 'MsoNormal tmail-signature'),
  ('div', 'style', 'color: red'),
  ('div', 'title', 't'),
  ('div', 'lang', 'vi'),
  ('div', 'dir', 'rtl'),
  ('div', 'align', 'center'),
  ('div', 'hidden', 'hidden'),
  ('div', 'tabindex', '0'),
  ('div', 'role', 'button'),
  ('div', 'aria-label', 'l'),
  ('div', 'aria-hidden', 'true'),
  ('div', 'data-x', 'y'),
  ('div', 'data-filename', 'f.pdf'),
  ('div', 'data-mimetype', 'image/png'),
  ('div', 'public-asset-id', 'a1'),
  ('div', 'itemprop', 'name'),
  ('div', 'contenteditable', 'true'),
  ('div', 'draggable', 'true'),
  ('div', 'xmlns', 'http://www.w3.org/1999/xhtml'),
  // Event handlers and form/navigation attributes.
  ('div', 'onclick', 'alert(1)'),
  ('div', 'onmouseover', 'alert(1)'),
  ('div', 'onanimationstart', 'alert(1)'),
  ('div', 'onfocus', 'alert(1)'),
  ('div', 'autofocus', 'autofocus'),
  ('div', 'srcdoc', '<script>alert(1)</script>'),
  ('div', 'formaction', 'https://evil.example'),
  ('div', 'action', 'https://evil.example'),
  ('div', 'background', 'https://example.com/bg.png'),
  // Tables.
  ('table', 'width', '600'),
  ('table', 'height', '100'),
  ('table', 'border', '0'),
  ('table', 'cellpadding', '0'),
  ('table', 'cellspacing', '0'),
  ('table', 'bgcolor', '#ffffff'),
  ('table', 'background', 'https://example.com/bg.png'),
  ('td', 'colspan', '2'),
  ('td', 'rowspan', '2'),
  ('td', 'valign', 'top'),
  ('td', 'nowrap', 'nowrap'),
  // Links.
  ('a', 'target', '_blank'),
  ('a', 'rel', 'noopener'),
  ('a', 'name', 'anchor'),
  ('a', 'download', 'f.pdf'),
  ('a', 'ping', 'https://track.example'),
  ('a', 'hreflang', 'en'),
  // Images.
  ('img', 'alt', 'a'),
  ('img', 'width', '600'),
  ('img', 'height', '400'),
  ('img', 'loading', 'lazy'),
  ('img', 'srcset', 'https://example.com/a.png 2x'),
  ('img', 'usemap', '#m'),
  ('img', 'longdesc', 'https://example.com/d'),
  ('img', 'onerror', 'alert(1)'),
  // Quotes.
  ('blockquote', 'cite', 'https://example.com/q'),
  ('blockquote', 'type', 'cite'),
  // Fonts.
  ('font', 'color', 'red'),
  ('font', 'face', 'Arial'),
  ('font', 'size', '3'),
  // SVG.
  ('svg', 'width', '10'),
  ('svg', 'viewbox', '0 0 10 10'),
  ('svg', 'onload', 'alert(1)'),
];

const _cssCandidates = [
  // Typography.
  'color: red', 'font-family: Arial', 'font-size: 14px', 'font-weight: bold',
  'font-style: italic', 'font: 12px Arial', 'line-height: 1.5',
  'letter-spacing: 1px', 'word-spacing: 2px', 'text-align: center',
  'text-decoration: underline', 'text-transform: uppercase',
  'text-indent: 10px', 'text-shadow: 1px 1px red', 'white-space: nowrap',
  'word-wrap: break-word', 'word-break: break-all', 'overflow-wrap: anywhere',
  'text-overflow: ellipsis', 'vertical-align: top', 'direction: rtl',
  'unicode-bidi: embed', 'writing-mode: vertical-rl',
  // Box model.
  'margin: 10px', 'margin-left: -40px', 'padding: 10px', 'border: 1px solid red',
  'border-radius: 4px', 'border-collapse: collapse', 'box-sizing: border-box',
  'width: 600px', 'max-width: 100%', 'min-width: 320px', 'height: 100px',
  'max-height: 500px',
  // Layout.
  'display: none', 'display: flex', 'display: grid', 'float: left',
  'clear: both', 'overflow: hidden', 'overflow-x: auto', 'table-layout: fixed',
  'flex: 1', 'flex-direction: column', 'justify-content: center',
  'align-items: center', 'gap: 8px', 'grid-template-columns: 1fr 1fr',
  'columns: 2',
  // Positioning and stacking (overlay / clickjacking surface).
  'position: fixed', 'position: absolute', 'position: relative',
  'top: 0', 'left: 0', 'z-index: 9999', 'transform: scale(2)',
  'visibility: hidden', 'opacity: 0.5', 'clip-path: circle(50%)',
  'pointer-events: none', 'cursor: pointer', 'zoom: 2',
  // Backgrounds.
  'background-color: #fff', 'background: red',
  'background-image: url(https://example.com/bg.png)',
  'background-image: url(javascript:alert(1))',
  'background-image: url(data:image/png;base64,iVBORw0KGgo=)',
  'background-size: cover', 'background-position: center',
  'background-repeat: no-repeat', 'list-style-image: url(https://example.com/b.png)',
  // Lists, SVG, misc.
  'list-style-type: square', 'fill: red', 'stroke: blue', 'box-shadow: 0 0 2px red',
  'animation: spin 1s', 'transition: all 1s', 'filter: blur(2px)',
  'content: "x"', 'outline: 1px solid red', 'user-select: none',
  'mso-line-height-rule: exactly', '-webkit-text-size-adjust: 100%',
  // Script-carrying values.
  'width: expression(alert(1))', 'behavior: url(x.htc)',
  '-moz-binding: url(x.xml)', 'color: red; background: url(javascript:alert(1))',
];

const _urlCandidates = [
  'https://example.com/a',
  'http://example.com/a',
  'mailto:someone@example.com',
  'tel:+84123456789',
  'sms:+84123456789',
  'cid:image-1',
  'data:image/png;base64,iVBORw0KGgo=',
  'data:image/svg+xml;base64,PHN2Zz48L3N2Zz4=',
  'data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==',
  'javascript:alert(1)',
  'JaVaScRiPt:alert(1)',
  ' javascript:alert(1)',
  'java&#x09;script:alert(1)',
  'vbscript:msgbox(1)',
  'file:///etc/passwd',
  'ftp://example.com/f',
  'blob:https://example.com/1',
  'about:blank',
  'intent://example#Intent;end',
  '//example.com/a',
  '/relative/path',
  'relative.html',
  '#anchor',
];
