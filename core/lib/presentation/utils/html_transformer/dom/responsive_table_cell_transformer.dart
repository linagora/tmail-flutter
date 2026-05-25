
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

/// Adds `overflow-wrap: anywhere` to every `<td>` and `<th>` element so that
/// long unbreakable strings (URLs, email addresses) wrap instead of causing
/// horizontal overflow on narrow screens.
///
/// `overflow-wrap: anywhere` (unlike `break-word`) reduces the intrinsic
/// min-content width of the cell to zero, which is required for
/// `table-layout: auto` tables to shrink columns to fit the viewport.
///
/// Cells that already declare `overflow-wrap` are left untouched to respect
/// the original email styling.
class ResponsiveTableCellTransformer extends DomTransformer {

  const ResponsiveTableCellTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final cells = document.querySelectorAll('td, th');
      if (cells.isEmpty) return;

      for (final cell in cells) {
        final currentStyle = cell.attributes['style'] ?? '';
        final hasOverflowWrapDeclaration = RegExp(
          r'(^|;)\s*overflow-wrap\s*:',
          caseSensitive: false,
        ).hasMatch(currentStyle);
        if (hasOverflowWrapDeclaration) continue;

        final trimmed = currentStyle.trimRight();
        final separator = trimmed.isEmpty ? '' : (trimmed.endsWith(';') ? ' ' : '; ');
        cell.attributes['style'] = '$trimmed${separator}overflow-wrap: anywhere;';
      }
    } catch (e) {
      logWarning('$runtimeType::process: Exception = $e');
    }
  }
}
