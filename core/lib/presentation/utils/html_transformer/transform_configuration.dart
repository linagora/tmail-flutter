
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/blockquoted_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/link_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/meta_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/script_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/convert_tags_text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/linebreak_text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/links_text_transformer.dart';

/// Contains the configuration for all transformations.
class TransformConfiguration {

  /// The list of DOM transformers being used
  final List<DomTransformer> domTransformers;

  /// The list of text transformers that are used before a plain text message without HTML part is converted into HTML
  final List<TextTransformer> textTransformers;

  /// Creates a new transform configuration
  ///
  /// Compare [create] to have an easier to use building function
  const TransformConfiguration(
    this.domTransformers,
    this.textTransformers
  );

  /// Provides easy access to a standard configuration that does not block external images.
  static const TransformConfiguration standardConfiguration = TransformConfiguration(
    standardDomTransformers,
    standardTextTransformers
  );

  /// Provides an easy option to customize a configuration.
  ///
  /// Any specified [customDomTransformers] or [customTextTransformers] are being appended to the standard transformers.
  static TransformConfiguration create({
    bool? blockExternalImages,
    int? maxImageWidth,
    List<DomTransformer>? customDomTransformers,
    List<TextTransformer>? customTextTransformers
  }) {
    final domTransformers = (customDomTransformers != null)
        ? [...standardDomTransformers, ...customDomTransformers]
        : [...standardDomTransformers];
    final textTransformers = (customTextTransformers != null)
        ? [...standardTextTransformers, ...customTextTransformers]
        : standardTextTransformers;
    maxImageWidth ??= standardMaxImageWidth;
    return TransformConfiguration(
      domTransformers,
      textTransformers
    );
  }

  static const int? standardMaxImageWidth = null;

  static const List<DomTransformer> standardDomTransformers = [
    ViewPortTransformer(),
    RemoveScriptTransformer(),
    ImageTransformer(),
    EnsureRelationNoReferrerTransformer(),
    BlockQuotedTransformer(),
  ];

  static const List<TextTransformer> standardTextTransformers = [
    ConvertTagsTextTransformer(),
    LinksTextTransformer(),
    LineBreakTextTransformer(),
  ];
}