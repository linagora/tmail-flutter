import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

class NormalizeLineHeightInStyleTransformer extends DomTransformer {
  const NormalizeLineHeightInStyleTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final elements = document.querySelectorAll('[style*="line-height"]');

      for (final element in elements) {
        final originalStyle = element.attributes['style'];
        if (originalStyle == null) continue;

        final updatedStyle = originalStyle.replaceAllMapped(
          RegExp(r'line-height\s*:\s*1px\s*;?', caseSensitive: false),
          (match) => '',
        );

        if (updatedStyle != originalStyle) {
          element.attributes['style'] = updatedStyle;
        }
      }
    } catch (e) {
      logError('$runtimeType::process: Exception = $e');
    }
  }
}
