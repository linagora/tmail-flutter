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
      final document = parser.parse(html);
      final body = document.body;
      if (body == null) return html;

      for (final element in body.querySelectorAll(_activeElements)) {
        element.remove();
      }

      for (final element in body.querySelectorAll('*')) {
        _stripAttributes(element);
      }

      return body.innerHtml;
    } catch (e) {
      logWarning('ActiveHtmlContentStripper::strip: Exception = $e');
      return html;
    }
  }

  static void _stripAttributes(Element element) {
    final attributeKeys = element.attributes.keys.toList();
    for (final key in attributeKeys) {
      final name = '$key'.toLowerCase();
      final value = element.attributes[key] ?? '';

      final isEventHandler = name.startsWith('on');
      final isFrameContent = name == 'srcdoc';
      final isUnsafeUrl = _urlAttributes.contains(name) && !_isSafeUrl(name, value);

      if (isEventHandler || isFrameContent || isUnsafeUrl) {
        element.attributes.remove(key);
      }
    }
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
