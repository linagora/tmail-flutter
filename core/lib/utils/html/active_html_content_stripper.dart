import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

/// Removes active content from HTML composed locally before it is sent or
/// saved, so that the application never originates a mail carrying script.
///
/// Unlike the display sanitizer, formatting is left untouched (no CSS or
/// attribute allow-list): only constructs able to run code, navigate or
/// submit data are removed.
class ActiveHtmlContentStripper {
  const ActiveHtmlContentStripper._();

  static const _activeElements =
      'script,iframe,frame,frameset,object,embed,applet,meta,base,link,'
      'form,input,button,textarea,select,noscript,template,portal';

  static const _svgAnimationElements = {
    'animate', 'animatemotion', 'animatetransform', 'set',
  };

  static const _urlAttributes = {
    'href', 'src', 'xlink:href', 'action', 'formaction', 'background',
    'poster', 'data', 'codebase', 'cite', 'longdesc', 'usemap', 'lowsrc',
    'dynsrc',
  };

  static final _ignoredUrlCharacters = RegExp(r'[\u0000- \u007f-\u009f]');
  static final _scriptSchemes = RegExp(r'^(javascript|vbscript|livescript|mocha):');
  static final _rasterDataImage = RegExp(r'^data:image/(png|jpe?g|gif|webp|bmp);');

  static String strip(String html) {
    if (html.trim().isEmpty) return html;

    try {
      final fragment = parser.parseFragment(html);

      for (final element in fragment.querySelectorAll(_activeElements)) {
        element.remove();
      }

      _removeSvgAnimations(fragment);

      for (final element in fragment.querySelectorAll('*')) {
        _stripAttributes(element);
      }

      return fragment.outerHtml;
    } catch (e) {
      logWarning('ActiveHtmlContentStripper::strip: Exception = $e');
      return html;
    }
  }

  // SMIL can animate an href to a javascript: URL, which attribute checks miss.
  static void _removeSvgAnimations(DocumentFragment fragment) {
    fragment
        .querySelectorAll('*')
        .where((element) => _svgAnimationElements.contains(element.localName?.toLowerCase()))
        .toList()
        .forEach((element) => element.remove());
  }

  static void _stripAttributes(Element element) {
    final attributeKeys = element.attributes.keys.toList();
    for (final key in attributeKeys) {
      final value = element.attributes[key] ?? '';
      if (_isActiveAttribute('$key'.toLowerCase(), value)) {
        element.attributes.remove(key);
      }
    }
  }

  static bool _isActiveAttribute(String name, String value) {
    if (name.startsWith('on')) return true;
    if (name == 'srcdoc') return true;
    return _urlAttributes.contains(name) && !_isSafeUrl(name, value);
  }

  static bool _isSafeUrl(String attributeName, String value) {
    final url = value.replaceAll(_ignoredUrlCharacters, '').toLowerCase();
    if (_scriptSchemes.hasMatch(url)) return false;
    if (url.startsWith('data:')) {
      return attributeName == 'src' && _rasterDataImage.hasMatch(url);
    }
    return true;
  }
}
