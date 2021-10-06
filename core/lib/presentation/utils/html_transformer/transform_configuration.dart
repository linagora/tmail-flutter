
import 'package:core/presentation/utils/html_transformer/dom/blockquote_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/link_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/meta_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/script_transformers.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/table_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/convert_tags_text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/linebreak_text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/links_text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';

/// Contains the configuration for all transformations.
class TransformConfiguration {

  /// Should external images be blocked?
  final bool blockExternalImages;

  /// The maximum width for embedded images. It make sense to limit this to reduce the generated HTML size.
  final int? maxImageWidth;

  /// The list of DOM transformers being used
  final List<DomTransformer> domTransformers;

  /// The list of text transformers that are used before a plain text message without HTML part is converted into HTML
  final List<TextTransformer> textTransformers;

  /// Creates a new transform configuration
  ///
  /// Compare [create] to have an easier to use building function
  const TransformConfiguration(
    this.blockExternalImages,
    this.maxImageWidth,
    this.domTransformers,
    this.textTransformers
  );

  /// Provides easy access to a standard configuration that does not block external images.
  static const TransformConfiguration standardConfiguration = TransformConfiguration(
    false,
    standardMaxImageWidth,
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
      blockExternalImages ?? false,
      maxImageWidth,
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
    SetStyleBlockQuoteTransformer(),
    SetStyleTableTransformer(),
  ];

  static const List<TextTransformer> standardTextTransformers = [
    ConvertTagsTextTransformer(),
    LinksTextTransformer(),
    LineBreakTextTransformer(),
  ];
}