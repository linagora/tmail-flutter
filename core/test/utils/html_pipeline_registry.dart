import 'dart:io';

import 'package:core/presentation/utils/html_transformer/dom/add_lazy_loading_for_background_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_negative_margin_float_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/responsive_table_cell_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_plain_text_html_output_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/platform_info.dart';

import 'html_pipeline_rules.dart';

export 'html_pipeline_rules.dart';

enum HtmlPipelineTrust { raw, sanitized, user }

enum HtmlPipelineWiring { sanitizes, passesThrough, stripsStyles }

/// Which [HtmlTransform] entry point feeds the pipeline: `transformToHtml`
/// for HTML bodies, `transformToTextPlain` for `text/plain` bodies.
enum HtmlPipelineInput { html, plainText }

class HtmlPipelineRow {
  const HtmlPipelineRow({
    required this.name,
    String? factoryName,
    required this.create,
    required this.trust,
    required this.wiring,
    required this.rules,
    this.setPlatform,
    this.allowsContentEditable = false,
    this.input = HtmlPipelineInput.html,
    this.knownGap,
  }) : factoryName = factoryName ?? name;

  final String name;
  final String factoryName;
  final TransformConfiguration Function() create;
  final HtmlPipelineTrust trust;
  final HtmlPipelineWiring wiring;
  final HtmlPipelineRules rules;
  final void Function()? setPlatform;
  final bool allowsContentEditable;
  final HtmlPipelineInput input;

  /// A known bug that breaks this pipeline's contract, with what it is. The
  /// contract tests skip with this reason until the fix lands; the wiring
  /// and lock tests still record what the pipeline really does.
  final String? knownGap;

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
      ..._composerPipelines(),
      ..._readingPipelines(),
      ..._otherPipelines(),
    ];

/// Pipelines that feed the composer: replies, drafts and signatures.
List<HtmlPipelineRow> _composerPipelines() => [
      HtmlPipelineRow(
        name: 'forReplyForwardEmail',
        create: TransformConfiguration.forReplyForwardEmail,
        trust: HtmlPipelineTrust.sanitized,
        wiring: HtmlPipelineWiring.passesThrough,
        rules: const HtmlPipelineRules(composer: true),
      ),
      HtmlPipelineRow(
        name: 'forReplyForwardEmptyEmail',
        create: TransformConfiguration.forReplyForwardEmptyEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(composer: true),
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forDraftsEmail',
        create: TransformConfiguration.forDraftsEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(displayOn: [DisplayViewer.drafts]),
      ),
      HtmlPipelineRow(
        name: 'forEditDraftsEmail-vm',
        factoryName: 'forEditDraftsEmail',
        create: TransformConfiguration.forEditDraftsEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(composer: true),
        setPlatform: () => PlatformInfo.isTestingForWeb = false,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forEditDraftsEmail-web',
        factoryName: 'forEditDraftsEmail',
        create: TransformConfiguration.forEditDraftsEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(composer: true),
        setPlatform: () => PlatformInfo.isTestingForWeb = true,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forSignatureIdentity',
        create: TransformConfiguration.forSignatureIdentity,
        trust: HtmlPipelineTrust.user,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(
          displayOn: [DisplayViewer.signatureNative, DisplayViewer.signatureWeb],
        ),
      ),
      HtmlPipelineRow(
        name: 'forComposerSignature',
        create: TransformConfiguration.forComposerSignature,
        trust: HtmlPipelineTrust.user,
        wiring: HtmlPipelineWiring.passesThrough,
        rules: const HtmlPipelineRules(composer: true),
      ),
    ];

/// Pipelines that show a received email or attachment.
List<HtmlPipelineRow> _readingPipelines() => [
      HtmlPipelineRow(
        name: 'forPreviewEmailOnWeb',
        create: TransformConfiguration.forPreviewEmailOnWeb,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(
          displayOn: [DisplayViewer.web],
          preservation: true,
        ),
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forPreviewEmail',
        create: TransformConfiguration.forPreviewEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(
          displayOn: [DisplayViewer.native, DisplayViewer.ios],
          preservation: true,
        ),
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forPreviewEmailOnPlatform-vm',
        factoryName: 'forPreviewEmailOnPlatform',
        create: TransformConfiguration.forPreviewEmailOnPlatform,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(sameAs: 'forPreviewEmail'),
        setPlatform: () => PlatformInfo.isTestingForWeb = false,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forPreviewEmailOnPlatform-web',
        factoryName: 'forPreviewEmailOnPlatform',
        create: TransformConfiguration.forPreviewEmailOnPlatform,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(sameAs: 'forPreviewEmailOnWeb'),
        setPlatform: () => PlatformInfo.isTestingForWeb = true,
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forPlainTextEmail',
        create: TransformConfiguration.forPlainTextEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(
          displayOn: [DisplayViewer.native, DisplayViewer.web, DisplayViewer.ios],
          preservation: true,
        ),
        input: HtmlPipelineInput.plainText,
      ),
      HtmlPipelineRow(
        name: 'standardConfiguration',
        create: () => TransformConfiguration.standardConfiguration,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(preservation: true),
      ),
      HtmlPipelineRow(
        name: 'forAttachmentPreview',
        create: TransformConfiguration.forAttachmentPreview,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(displayOn: [DisplayViewer.attachment]),
      ),
    ];

/// Restore, print and calendar pipelines.
List<HtmlPipelineRow> _otherPipelines() => [
      HtmlPipelineRow(
        name: 'forRestoreEmail',
        create: TransformConfiguration.forRestoreEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(composer: true),
        allowsContentEditable: true,
      ),
      HtmlPipelineRow(
        name: 'forPrintEmail',
        create: TransformConfiguration.forPrintEmail,
        trust: HtmlPipelineTrust.sanitized,
        wiring: HtmlPipelineWiring.stripsStyles,
        rules: const HtmlPipelineRules(displayOn: [DisplayViewer.print]),
      ),
      HtmlPipelineRow(
        name: 'forCalendarEvent',
        create: TransformConfiguration.forCalendarEvent,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: const HtmlPipelineRules(
          displayOn: [DisplayViewer.calendarNative, DisplayViewer.calendarWeb],
        ),
      ),
    ];

/// Every public `factory TransformConfiguration.x(` or
/// `static [final|const] TransformConfiguration [get] x` member.
final _pipelineMember = RegExp(
  r'(?:factory TransformConfiguration\.|static (?:final |const )?TransformConfiguration (?:get )?)([a-zA-Z]\w*)',
);

/// Generic builders that every pipeline is made from, not pipelines.
const _pipelineBuilders = {'create', 'fromDomTransformers', 'fromTextTransformers'};

Set<String> htmlPipelineFactoryNamesFromSource(String source) => _pipelineMember
    .allMatches(source)
    .map((match) => match.group(1)!)
    .where((name) => !_pipelineBuilders.contains(name))
    .toSet();

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

/// The HTML pipelines whose observed [wiring] matches, one per factory.
Map<String, TransformConfiguration Function()> pipelineFactoriesWired(
  HtmlPipelineWiring wiring,
) =>
    {
      for (final row in htmlPipelineRegistry().reversed)
        if (row.takesHtml && row.wiring == wiring) row.factoryName: row.create,
    };

/// Rows no rule suite checks; the contract test requires none.
List<String> rowsWithoutRules(Iterable<HtmlPipelineRow> rows) =>
    [for (final row in rows) if (row.rules.isEmpty) row.name];

/// The row whose output [viewer] shows for an HTML or a text/plain body.
HtmlPipelineRow? displayPipelineFor(
  DisplayViewer viewer, {
  required bool plainText,
}) =>
    htmlPipelineRegistry()
        .where(
          (row) =>
              row.rules.displayOn.contains(viewer) &&
              row.takesHtml != plainText,
        )
        .firstOrNull;
