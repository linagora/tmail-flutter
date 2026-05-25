import 'package:core/presentation/utils/html_transformer/dom/responsive_table_cell_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

bool _hasResponsiveTransformer(List transformers) =>
    transformers.any((t) => t is ResponsiveTableCellTransformer);

void main() {
  group('TransformConfiguration — ResponsiveTableCellTransformer membership', () {
    test('standardDomTransformers includes ResponsiveTableCellTransformer', () {
      expect(
        _hasResponsiveTransformer(TransformConfiguration.standardDomTransformers),
        isTrue,
      );
    });

    test('forPreviewEmailOnWeb includes ResponsiveTableCellTransformer', () {
      expect(
        _hasResponsiveTransformer(
          TransformConfiguration.forPreviewEmailOnWeb().domTransformers,
        ),
        isTrue,
      );
    });

    test('forPreviewEmail includes ResponsiveTableCellTransformer via standardConfiguration', () {
      expect(
        _hasResponsiveTransformer(
          TransformConfiguration.forPreviewEmail().domTransformers,
        ),
        isTrue,
      );
    });

    test('forReplyForwardEmail does NOT include ResponsiveTableCellTransformer', () {
      expect(
        _hasResponsiveTransformer(
          TransformConfiguration.forReplyForwardEmail().domTransformers,
        ),
        isFalse,
        reason: 'Reply/forward editor must not mutate quoted content table styles',
      );
    });

    test('forDraftsEmail does NOT include ResponsiveTableCellTransformer', () {
      expect(
        _hasResponsiveTransformer(
          TransformConfiguration.forDraftsEmail().domTransformers,
        ),
        isFalse,
        reason: 'Draft editor must not mutate table styles',
      );
    });

    test('forPrintEmail does NOT include ResponsiveTableCellTransformer', () {
      expect(
        _hasResponsiveTransformer(
          TransformConfiguration.forPrintEmail().domTransformers,
        ),
        isFalse,
        reason: 'Print configuration does not need responsive wrapping',
      );
    });
  });
}
