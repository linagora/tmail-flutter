import 'html/display_harness/display_viewer.dart';

export 'html/display_harness/display_viewer.dart' show DisplayViewer;

/// The rule suites that check one pipeline's output. A row with none fails
/// the guard in transform_configuration_contract_test.
class HtmlPipelineRules {
  const HtmlPipelineRules({
    this.displayOn = const [],
    this.composer = false,
    this.preservation = false,
    this.sameAs,
  });

  /// Viewers whose display rules render this pipeline's output.
  final List<DisplayViewer> displayOn;

  /// Composer rules: preservation, idempotent round-trip, no display-only
  /// markup, drive cards keep contenteditable.
  final bool composer;

  /// Content preservation of the transform output.
  final bool preservation;

  /// Row name this pipeline must equal, transformer for transformer.
  final String? sameAs;

  bool get isEmpty =>
      displayOn.isEmpty && !composer && !preservation && sameAs == null;
}
