
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/add_lazy_loading_for_background_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/hide_draft_signature_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/block_code_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/block_quoted_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_collapsed_signature_button_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_lazy_loading_for_background_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_lazy_loading_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_max_width_in_image_style_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_style_tag_outside_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_tooltip_link_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/sanitize_hyper_link_tag_in_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/script_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/signature_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/utils/platform_info.dart';

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

  factory TransformConfiguration.fromDomTransformers(List<DomTransformer> domTransformers) => TransformConfiguration(domTransformers, []);

  factory TransformConfiguration.fromTextTransformers(
    List<TextTransformer> textTransformers
  ) => TransformConfiguration([], textTransformers);

  factory TransformConfiguration.forReplyForwardEmail() => TransformConfiguration.fromDomTransformers([
    if (PlatformInfo.isWeb)
      const RemoveTooltipLinkTransformer(),
    const SignatureTransformer(),
    const RemoveCollapsedSignatureButtonTransformer(),
    const ImageTransformer(),
  ]);

  factory TransformConfiguration.forDraftsEmail() => TransformConfiguration.create(
    customDomTransformers: [const ImageTransformer()]
  );
  factory TransformConfiguration.forEditDraftsEmail() => TransformConfiguration.create(
    customDomTransformers: [
      ...TransformConfiguration.forDraftsEmail().domTransformers,
      const HideDraftSignatureTransformer()
    ]
  );

  factory TransformConfiguration.forPreviewEmailOnWeb() => TransformConfiguration.create(
    customDomTransformers: [
      const RemoveScriptTransformer(),
      const BlockQuotedTransformer(),
      const BlockCodeTransformer(),
      SanitizeHyperLinkTagInHtmlTransformer(useTooltip: true),
      const ImageTransformer(),
      const AddLazyLoadingForBackgroundImageTransformer(),
      const RemoveCollapsedSignatureButtonTransformer(),
    ]
  );

  factory TransformConfiguration.forPreviewEmail() => TransformConfiguration.standardConfiguration;

  factory TransformConfiguration.forRestoreEmail() => TransformConfiguration.create(
    customDomTransformers: [const ImageTransformer()]
  );

  factory TransformConfiguration.forPrintEmail() => TransformConfiguration.fromDomTransformers([
    if (PlatformInfo.isWeb)
      const RemoveTooltipLinkTransformer(),
    const RemoveLazyLoadingForBackgroundImageTransformer(),
    const RemoveLazyLoadingImageTransformer(),
    const RemoveCollapsedSignatureButtonTransformer(),
    const RemoveStyleTagOutsideTransformer(),
    const RemoveMaxWidthInImageStyleTransformer(),
  ]);

  /// Provides easy access to a standard configuration that does not block external images.
  static TransformConfiguration standardConfiguration = TransformConfiguration(
    standardDomTransformers,
    standardTextTransformers
  );

  /// Provides an easy option to customize a configuration.
  ///
  /// Any specified [customDomTransformers] or [customTextTransformers] are being appended to the standard transformers.
  static TransformConfiguration create({
    List<DomTransformer>? customDomTransformers,
    List<TextTransformer>? customTextTransformers
  }) {
    final domTransformers = (customDomTransformers != null && customDomTransformers.isNotEmpty)
      ? customDomTransformers
      : standardDomTransformers;

    final textTransformers = (customTextTransformers != null && customTextTransformers.isNotEmpty)
      ? customTextTransformers
      : standardTextTransformers;

    return TransformConfiguration(
      domTransformers,
      textTransformers
    );
  }

  static List<DomTransformer> standardDomTransformers = [
    const RemoveScriptTransformer(),
    const BlockQuotedTransformer(),
    const BlockCodeTransformer(),
    SanitizeHyperLinkTagInHtmlTransformer(useTooltip: PlatformInfo.isWeb),
    const ImageTransformer(),
    const AddLazyLoadingForBackgroundImageTransformer(),
    const RemoveCollapsedSignatureButtonTransformer(),
  ];

  static const List<TextTransformer> standardTextTransformers = [
    StandardizeHtmlSanitizingTransformers(),
  ];
}