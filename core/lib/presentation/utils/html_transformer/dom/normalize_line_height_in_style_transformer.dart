import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

class NormalizeLineHeightInStyleTransformer extends DomTransformer {
  const NormalizeLineHeightInStyleTransformer();

  static const _removableLineHeights = ['1px', '100%'];

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final pattern = RegExp(
        r'line-height\s*:\s*(?:' + _removableLineHeights.join('|') + r')\s*;?',
        caseSensitive: false,
      );

      final elements = document.querySelectorAll('[style*="line-height"]');

      for (final element in elements) {
        final originalStyle = element.attributes['style'];
        if (originalStyle == null) continue;

        var updatedStyle = originalStyle.replaceAll(pattern, '').trim();

        // Remove extra spaces (>=2 spaces → 1 space)
        updatedStyle = updatedStyle.replaceAll(RegExp(r'\s{2,}'), ' ');

        if (updatedStyle != originalStyle) {
          if (updatedStyle.isEmpty) {
            element.attributes.remove('style');
          } else {
            element.attributes['style'] = updatedStyle;
          }
        }
      }
    } catch (e) {
      logError('$runtimeType::process: Exception = $e');
    }
  }
}
