import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/css_declaration_splitter.dart';
import 'package:html/dom.dart';

class HideDraftSignatureTransformer extends DomTransformer {

  const HideDraftSignatureTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID
  }) async {
    try {
      // A top-level signature is not re-applied on load, so it must stay visible.
      if (document.querySelector('body > .tmail-signature') != null) return;
      final signature = document.querySelector('.tmail-signature');
      if (signature == null) return;
      signature.attributes['style'] =
          styleWithHiddenSignature(signature.attributes['style']);
    } catch (e) {
      logWarning('$runtimeType::process:Exception = $e');
    }
  }

  /// Drops any existing `display` declaration (including `!important`) and sets
  /// `display: none !important` so a sender `display: block !important` cannot
  /// keep a nested draft signature visible.
  static String styleWithHiddenSignature(String? currentStyle) {
    const hidden = 'display: none !important;';
    final trimmed = currentStyle?.trim();
    if (trimmed == null || trimmed.isEmpty) return hidden;

    final declarations = CssDeclarationSplitter.splitTopLevel(trimmed);
    // Malformed CSS would swallow an appended declaration; hiding wins.
    if (declarations == null) return hidden;

    final kept = <String>[];
    for (final part in declarations) {
      final declaration = part.trim();
      final body = declaration.endsWith(';')
          ? declaration.substring(0, declaration.length - 1).trim()
          : declaration;
      if (body.isEmpty || _isDisplayDeclaration(body)) continue;
      kept.add(body);
    }
    kept.add('display: none !important');
    return '${kept.join('; ')};';
  }

  static bool _isDisplayDeclaration(String declaration) {
    final colon = declaration.indexOf(':');
    return colon != -1 &&
        declaration.substring(0, colon).trim().toLowerCase() == 'display';
  }
}
