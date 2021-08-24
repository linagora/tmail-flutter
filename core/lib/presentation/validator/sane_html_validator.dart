
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

final _allowedElements = <String>{
  'H1',
  'H2',
  'H3',
  'H4',
  'H5',
  'H6',
  'H7',
  'H8',
  'BR',
  'B',
  'I',
  'STRONG',
  'EM',
  'A',
  'PRE',
  'CODE',
  'IMG',
  'TT',
  'DIV',
  'INS',
  'DEL',
  'SUP',
  'SUB',
  'P',
  'OL',
  'UL',
  'TABLE',
  'THEAD',
  'TBODY',
  'TFOOT',
  'BLOCKQUOTE',
  'DL',
  'DT',
  'DD',
  'KBD',
  'Q',
  'SAMP',
  'VAR',
  'HR',
  'RUBY',
  'RT',
  'RP',
  'LI',
  'TR',
  'TD',
  'TH',
  'S',
  'STRIKE',
  'SUMMARY',
  'DETAILS',
  'CAPTION',
  'FIGURE',
  'FIGCAPTION',
  'ABBR',
  'BDO',
  'CITE',
  'DFN',
  'MARK',
  'SMALL',
  'SPAN',
  'TIME',
  'WBR',
};

final _alwaysAllowedAttributes = <String>{
  'abbr',
  'accept',
  'accept-charset',
  'accesskey',
  'action',
  'align',
  'alt',
  'aria-describedby',
  'aria-hidden',
  'aria-label',
  'aria-labelledby',
  'axis',
  'border',
  'cellpadding',
  'cellspacing',
  'char',
  'charoff',
  'charset',
  'checked',
  'clear',
  'cols',
  'colspan',
  'color',
  'compact',
  'coords',
  'datetime',
  'dir',
  'disabled',
  'enctype',
  'for',
  'frame',
  'headers',
  'height',
  'hreflang',
  'hspace',
  'ismap',
  'label',
  'lang',
  'maxlength',
  'media',
  'method',
  'multiple',
  'name',
  'nohref',
  'noshade',
  'nowrap',
  'open',
  'prompt',
  'readonly',
  'rel',
  'rev',
  'rows',
  'rowspan',
  'rules',
  'scope',
  'selected',
  'shape',
  'size',
  'span',
  'start',
  'summary',
  'tabindex',
  'target',
  'title',
  'type',
  'usemap',
  'valign',
  'value',
  'vspace',
  'width',
  'itemprop',
};

bool _alwaysAllowed(String _) => true;

bool _validLink(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.isScheme('https') ||
        uri.isScheme('http') ||
        uri.isScheme('mailto') ||
        !uri.hasScheme;
  } on FormatException {
    return false;
  }
}

bool _validUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.isScheme('https') || uri.isScheme('http') || !uri.hasScheme;
  } on FormatException {
    return false;
  }
}

final _citeAttributeValidator = <String, bool Function(String)>{
  'cite': _validUrl,
};

final _elementAttributeValidators =
  <String, Map<String, bool Function(String)>>{
    'A': {
      'href': _validLink,
    },
    'IMG': {
      'src': _alwaysAllowed,
      'longdesc': _validUrl,
    },
    'DIV': {
      'itemscope': _alwaysAllowed,
      'itemtype': _alwaysAllowed,
    },
    'BLOCKQUOTE': _citeAttributeValidator,
    'DEL': _citeAttributeValidator,
    'INS': _citeAttributeValidator,
    'Q': _citeAttributeValidator,
  };

/// An implementation of [html.NodeValidator] that only allows sane HTML tags
/// and attributes protecting against XSS.
///
/// Modeled after the [rules employed by Github][1] when sanitizing GFM (Github
/// Flavored Markdown). Notably this excludes CSS styles and other tags that
/// easily interferes with the rest of the page.
///
/// [1]: https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/sanitization_filter.rb
class SaneHtmlValidator {
  final bool Function(String)? allowElementId;
  final bool Function(String)? allowClassName;
  final bool Function(String)? allowAttributes;
  final Iterable<String>? Function(String)? addLinkRel;

  SaneHtmlValidator({
    required this.allowElementId,
    required this.allowClassName,
    required this.allowAttributes,
    required this.addLinkRel,
  });

  String sanitize(String htmlString) {
    final root = html_parser.parseFragment(htmlString);
    _sanitize(root);
    return root.outerHtml;
  }

  void _sanitize(Node node) {
    if (node is Element) {
      final tagName = node.localName!.toUpperCase();
      if (!_allowedElements.contains(tagName)) {
        node.remove();
        return;
      }
      node.attributes.removeWhere((k, v) {
        final attrName = k.toString();
        if (attrName == 'id') {
          return allowElementId == null || !allowElementId!(v);
        }
        if (attrName == 'class') {
          if (allowClassName == null) return true;
          node.classes.removeWhere((cn) => !allowClassName!(cn));
          return node.classes.isEmpty;
        }

        return !_isAttributeAllowed(tagName, attrName, v);
      });
      if (tagName == 'A') {
        final href = node.attributes['href'];
        if (href != null && addLinkRel != null) {
          final rels = addLinkRel!(href);
          if (rels != null && rels.isNotEmpty) {
            node.attributes['rel'] = rels.join(' ');
          }
        }
      }
    }
    if (node.hasChildNodes()) {
      // doing it in reverse order, because we could otherwise skip one, when a
      // node is removed...
      for (var i = node.nodes.length - 1; i >= 0; i--) {
        _sanitize(node.nodes[i]);
      }
    }
  }

  bool _isAttributeAllowed(String tagName, String attrName, String value) {
    if (_alwaysAllowedAttributes.contains(attrName)) return true;

    if (allowAttributes != null && allowAttributes!(attrName)) return true;

    // Special validators for special attributes on special tags (href/src/cite)
    final attributeValidators = _elementAttributeValidators[tagName];
    if (attributeValidators == null) {
      return false;
    }

    final validator = attributeValidators[attrName];
    if (validator == null) {
      return false;
    }

    return validator(value);
  }
}