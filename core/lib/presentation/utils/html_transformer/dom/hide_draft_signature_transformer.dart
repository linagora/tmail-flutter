import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
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
    final trimmed = currentStyle?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'display: none !important;';
    }

    final kept = <String>[];
    for (final part in trimmed.split(';')) {
      final declaration = part.trim();
      if (declaration.isEmpty) continue;
      if (declaration.toLowerCase().startsWith('display:')) continue;
      kept.add(declaration);
    }
    kept.add('display: none !important');
    return '${kept.join('; ')};';
  }
}
