import 'package:core/presentation/utils/html_transformer/dom/remove_negative_margin_float_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/responsive_table_cell_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

bool _hasResponsiveTransformer(List transformers) =>
    transformers.any((t) => t is ResponsiveTableCellTransformer);

bool _hasNegativeMarginFloatTransformer(List transformers) =>
    transformers.any((t) => t is RemoveNegativeMarginFloatTransformer);

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

  group('TransformConfiguration — RemoveNegativeMarginFloatTransformer membership', () {
    test('standardDomTransformers includes RemoveNegativeMarginFloatTransformer', () {
      expect(
        _hasNegativeMarginFloatTransformer(TransformConfiguration.standardDomTransformers),
        isTrue,
      );
    });

    test('forPreviewEmail includes RemoveNegativeMarginFloatTransformer via standardConfiguration', () {
      expect(
        _hasNegativeMarginFloatTransformer(
          TransformConfiguration.forPreviewEmail().domTransformers,
        ),
        isTrue,
      );
    });

    test('forPreviewEmailOnWeb includes RemoveNegativeMarginFloatTransformer', () {
      expect(
        _hasNegativeMarginFloatTransformer(
          TransformConfiguration.forPreviewEmailOnWeb().domTransformers,
        ),
        isTrue,
      );
    });

    test('forReplyForwardEmail does NOT include RemoveNegativeMarginFloatTransformer', () {
      expect(
        _hasNegativeMarginFloatTransformer(
          TransformConfiguration.forReplyForwardEmail().domTransformers,
        ),
        isFalse,
        reason: 'Reply/forward editor operates on draft content, not received email rendering',
      );
    });

    test('forDraftsEmail does NOT include RemoveNegativeMarginFloatTransformer', () {
      expect(
        _hasNegativeMarginFloatTransformer(
          TransformConfiguration.forDraftsEmail().domTransformers,
        ),
        isFalse,
        reason: 'Draft editor operates on composed content, not received email rendering',
      );
    });

    test('forPrintEmail does NOT include RemoveNegativeMarginFloatTransformer', () {
      expect(
        _hasNegativeMarginFloatTransformer(
          TransformConfiguration.forPrintEmail().domTransformers,
        ),
        isFalse,
        reason: 'Print pipeline renders the original email faithfully without layout adjustments',
      );
    });
  });
}
