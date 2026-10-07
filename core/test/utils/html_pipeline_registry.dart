import 'dart:io';

import 'package:core/presentation/utils/html_transformer/dom/add_lazy_loading_for_background_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_negative_margin_float_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/responsive_table_cell_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_plain_text_html_output_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/platform_info.dart';

enum HtmlPipelineTrust { raw, sanitized, user }

enum HtmlPipelineWiring { sanitizes, passesThrough, stripsStyles }

/// Which [HtmlTransform] entry point feeds the pipeline: `transformToHtml`
/// for HTML bodies, `transformToTextPlain` for `text/plain` bodies.
enum HtmlPipelineInput { html, plainText }

class HtmlPipelineRow {
  const HtmlPipelineRow({
    required this.name,
    required this.factoryName,
    required this.create,
    required this.trust,
    required this.wiring,
    this.setPlatform,
    this.allowsContentEditable = false,
    this.input = HtmlPipelineInput.html,
  });

  final String name;
  final String factoryName;
  final TransformConfiguration Function() create;
  final HtmlPipelineTrust trust;
  final HtmlPipelineWiring wiring;
  final void Function()? setPlatform;
  final bool allowsContentEditable;
  final HtmlPipelineInput input;

  bool get takesHtml => input == HtmlPipelineInput.html;

  TransformConfiguration build() {
    setPlatform?.call();
    return create();
  }
}

/// HTML pipelines must run [StandardizeHtmlSanitizingTransformers];
/// text/plain pipelines sanitize their escaped output with
/// [SanitizePlainTextHtmlOutputTransformer] instead.
bool pipelineHasSanitizer(
  TransformConfiguration config, {
  HtmlPipelineInput input = HtmlPipelineInput.html,
}) =>
    config.textTransformers.any(
      (transformer) => input == HtmlPipelineInput.html
          ? transformer is StandardizeHtmlSanitizingTransformers
          : transformer is SanitizePlainTextHtmlOutputTransformer,
    );

bool pipelineAllowsContentEditable(TransformConfiguration config) => config
    .textTransformers
    .whereType<StandardizeHtmlSanitizingTransformers>()
    .any(
      (transformer) =>
          transformer.allowAttributes?.contains('contenteditable') == true,
    );

bool pipelineHasDisplayOnly(TransformConfiguration config) =>
    config.domTransformers.any(
      (transformer) =>
          transformer is ResponsiveTableCellTransformer ||
          transformer is RemoveNegativeMarginFloatTransformer ||
          transformer is AddLazyLoadingForBackgroundImageTransformer,
    );

List<HtmlPipelineRow> htmlPipelineRegistry() => [
      HtmlPipelineRow(
        name: 'forReplyForwardEmail',
        factoryName: 'forReplyForwardEmail',
        create: TransformConfiguration.forReplyForwardEmail,
        trust: HtmlPipelineTrust.sanitized,
        wiring: HtmlPipelineWiring.passesThrough,
      ),
      HtmlPipelineRow(
        name: 'forReplyForwardEmptyEmail',
        factoryName: 'forReplyForwardEmptyEmail',
        create: TransformConfiguration.forReplyForwardEmptyEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forDraftsEmail',
        factoryName: 'forDraftsEmail',
        create: TransformConfiguration.forDraftsEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
      ),
      HtmlPipelineRow(
        name: 'forEditDraftsEmail-vm',
        factoryName: 'forEditDraftsEmail',
        create: TransformConfiguration.forEditDraftsEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        setPlatform: () => PlatformInfo.isTestingForWeb = false,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forEditDraftsEmail-web',
        factoryName: 'forEditDraftsEmail',
        create: TransformConfiguration.forEditDraftsEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        setPlatform: () => PlatformInfo.isTestingForWeb = true,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forPreviewEmailOnWeb',
        factoryName: 'forPreviewEmailOnWeb',
        create: TransformConfiguration.forPreviewEmailOnWeb,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forPreviewEmail',
        factoryName: 'forPreviewEmail',
        create: TransformConfiguration.forPreviewEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forPreviewEmailOnPlatform-vm',
        factoryName: 'forPreviewEmailOnPlatform',
        create: TransformConfiguration.forPreviewEmailOnPlatform,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        setPlatform: () => PlatformInfo.isTestingForWeb = false,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forPreviewEmailOnPlatform-web',
        factoryName: 'forPreviewEmailOnPlatform',
        create: TransformConfiguration.forPreviewEmailOnPlatform,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        setPlatform: () => PlatformInfo.isTestingForWeb = true,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forRestoreEmail',
        factoryName: 'forRestoreEmail',
        create: TransformConfiguration.forRestoreEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forPrintEmail',
        factoryName: 'forPrintEmail',
        create: TransformConfiguration.forPrintEmail,
        trust: HtmlPipelineTrust.sanitized,
        wiring: HtmlPipelineWiring.stripsStyles,
      ),
      HtmlPipelineRow(
        name: 'forSignatureIdentity',
        factoryName: 'forSignatureIdentity',
        create: TransformConfiguration.forSignatureIdentity,
        trust: HtmlPipelineTrust.user,
        wiring: HtmlPipelineWiring.sanitizes,
      ),
      HtmlPipelineRow(
        name: 'forComposerSignature',
        factoryName: 'forComposerSignature',
        create: TransformConfiguration.forComposerSignature,
        trust: HtmlPipelineTrust.user,
        wiring: HtmlPipelineWiring.passesThrough,
      ),
      HtmlPipelineRow(
        name: 'forCalendarEvent',
        factoryName: 'forCalendarEvent',
        create: TransformConfiguration.forCalendarEvent,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
      ),
      HtmlPipelineRow(
        name: 'forPlainTextEmail',
        factoryName: 'forPlainTextEmail',
        create: TransformConfiguration.forPlainTextEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        input: HtmlPipelineInput.plainText,
      ),
      HtmlPipelineRow(
        name: 'standardConfiguration',
        factoryName: 'standardConfiguration',
        create: () => TransformConfiguration.standardConfiguration,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
      ),
      HtmlPipelineRow(
        name: 'forAttachmentPreview',
        factoryName: 'forAttachmentPreview',
        create: TransformConfiguration.forAttachmentPreview,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
      ),
    ];

Set<String> htmlPipelineFactoryNamesFromSource(String source) {
  final factories = RegExp(r'factory TransformConfiguration\.(for[A-Z]\w*)\(')
      .allMatches(source)
      .map((match) => match.group(1)!)
      .toSet();
  if (source.contains('static TransformConfiguration standardConfiguration')) {
    factories.add('standardConfiguration');
  }
  return factories;
}

String htmlPipelineTransformConfigurationSource() {
  final cwd = Directory.current.path;
  for (final path in [
    '$cwd/lib/presentation/utils/html_transformer/transform_configuration.dart',
    '$cwd/core/lib/presentation/utils/html_transformer/transform_configuration.dart',
  ]) {
    final file = File(path);
    if (file.existsSync()) return file.readAsStringSync();
  }
  throw StateError('Missing transform_configuration.dart from $cwd');
}

Map<String, TransformConfiguration Function()> sanitizingPipelineFactories() {
  final factories = <String, TransformConfiguration Function()>{};
  for (final row in htmlPipelineRegistry()) {
    if (!row.takesHtml || row.wiring != HtmlPipelineWiring.sanitizes) continue;
    factories.putIfAbsent(row.factoryName, () => row.create);
  }
  return factories;
}

Map<String, TransformConfiguration Function()> passThroughPipelineFactories() {
  final factories = <String, TransformConfiguration Function()>{};
  for (final row in htmlPipelineRegistry()) {
    if (!row.takesHtml || row.wiring != HtmlPipelineWiring.passesThrough) {
      continue;
    }
    factories.putIfAbsent(row.factoryName, () => row.create);
  }
  return factories;
}
