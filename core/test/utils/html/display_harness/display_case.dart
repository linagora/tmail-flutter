import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/html_emails/html_email_corpus.g.dart';
import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import 'display_frame.dart';
import 'display_viewer.dart';
import 'offline_images.dart';

export 'display_frame.dart';
export 'display_viewer.dart';

/// One fixture shown on one viewer at one email pane width.
class DisplayCase {
  const DisplayCase(this.fixture, this.viewer, this.width);

  final HtmlEmailCorpusFixture fixture;
  final DisplayViewer viewer;
  final int width;

  String get label =>
      '${fixture.category}/${fixture.name} @${viewer.label} ${width}px';

  /// `<category>/<fixture> @<viewer> <W>px: <rule>: <css path> <detail>`.
  String failure(String rule, String path, [String detail = '']) =>
      '$label: $rule: $path${detail.isEmpty ? '' : ' $detail'}';

  TextDirection? get direction => fixture.rtl ? TextDirection.rtl : null;
}

/// A [DisplayCase] after the app pipeline: [transformedHtml] is the
/// [HtmlTransform] output (remote URLs still in place, for attribute checks),
/// [document] what the viewer loads, [frame] the settled rendering.
class DisplayRender {
  const DisplayRender(this.displayCase, this.transformedHtml, this.document, this.frame);

  final DisplayCase displayCase;
  final String transformedHtml;
  final String document;
  final DisplayFrame frame;

  void dispose() => frame.dispose();
}

/// The display pipeline never downloads: fixtures have no CID map, and
/// remote images are swapped offline. Any call fails the test.
class _OfflineDioClient extends Fake implements DioClient {}

final _htmlTransform = HtmlTransform(_OfflineDioClient(), const HtmlEscape());

/// Copies every element's inline `style` to `data-sender-style` at
/// `DOMContentLoaded`, before the viewer scripts run on `load`, so checkers
/// can tell what a script changed from what the sender wrote. Test-only: it
/// adds an attribute and changes nothing the viewers read.
const _senderStyleSnapshotScript = '''
<script>
  document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('[style]').forEach(function(element) {
      element.setAttribute('data-sender-style', element.getAttribute('style'));
    });
  });
</script>
''';

String _withSenderStyleSnapshot(String document) {
  final head = document.indexOf('<head>');
  if (head < 0) return '$_senderStyleSnapshotScript$document';
  final at = head + '<head>'.length;
  return document.substring(0, at) + _senderStyleSnapshotScript + document.substring(at);
}

/// A deliberate break of one display mechanism, applied in the test only
/// (production code is never edited), to prove a rule notices it.
class DisplayMutation {
  const DisplayMutation({
    this.transformConfiguration,
    this.plainTextTransformConfiguration,
    this.document,
    this.quoteToggle = true,
  });

  /// Replaces the viewer's HTML transform configuration.
  final TransformConfiguration Function(DisplayViewer viewer)? transformConfiguration;

  /// Replaces [TransformConfiguration.forPlainTextEmail] for `text/plain`.
  final TransformConfiguration Function()? plainTextTransformConfiguration;

  /// Rewrites the built viewer document (strip a script or a CSS rule).
  final String Function(String document)? document;

  /// Builds the viewer document without the quote toggle.
  final bool quoteToggle;
}

/// Runs the production pipeline for [displayCase]: the viewer's transform
/// configuration (or `forPlainTextEmail` for `text/plain`), the offline image
/// swap, the viewer's document builder, then an iframe at the pane width.
/// A [mutation] (mutation tests only) breaks one step on purpose.
Future<DisplayRender> renderDisplayCase(
  DisplayCase displayCase, {
  DisplayMutation? mutation,
}) async {
  final fixture = displayCase.fixture;
  final transformed = fixture.isPlainText
      ? _htmlTransform.transformToTextPlain(
          content: fixture.html,
          transformConfiguration: mutation?.plainTextTransformConfiguration?.call() ??
              TransformConfiguration.forPlainTextEmail(),
        )
      : await _htmlTransform.transformToHtml(
          htmlContent: fixture.html,
          transformConfiguration:
              mutation?.transformConfiguration?.call(displayCase.viewer) ??
                  displayCase.viewer.transformConfiguration(),
        );
  final built = displayCase.viewer.buildDocument(
    swapImagesForOffline(transformed),
    displayCase.width,
    direction: displayCase.direction,
    quoteToggle: mutation?.quoteToggle ?? true,
  );
  final document = mutation?.document?.call(built) ?? built;
  final frame = await DisplayFrame.render(
    _withSenderStyleSnapshot(document),
    displayCase.width,
    label: displayCase.label,
  );
  return DisplayRender(displayCase, transformed, document, frame);
}

/// `--dart-define=DISPLAY_VIEWER=native|web|ios` limits a run to one viewer,
/// so CI can split the display suite into parallel jobs. Empty: all viewers.
const _viewerFilter = String.fromEnvironment('DISPLAY_VIEWER');

/// Every fixture of [corpus] on every viewer (of [viewers] that the
/// `DISPLAY_VIEWER` define keeps) and width.
Iterable<DisplayCase> displayCases({
  List<HtmlEmailCorpusFixture> corpus = htmlEmailCorpus,
  Iterable<DisplayViewer> viewers = DisplayViewer.values,
}) sync* {
  final selected = [
    for (final viewer in viewers)
      if (_viewerFilter.isEmpty || viewer.label == _viewerFilter) viewer,
  ];
  if (_viewerFilter.isNotEmpty &&
      !DisplayViewer.values.any((viewer) => viewer.label == _viewerFilter)) {
    throw ArgumentError.value(_viewerFilter, 'DISPLAY_VIEWER', 'unknown viewer');
  }
  for (final fixture in corpus) {
    for (final viewer in selected) {
      for (final width in viewer.widths) {
        yield DisplayCase(fixture, viewer, width);
      }
    }
  }
}

/// Renders [displayCase], runs [verify], and always removes the iframe.
Future<void> withDisplayCase(
  DisplayCase displayCase,
  Future<void> Function(DisplayRender render) verify,
) async {
  final render = await renderDisplayCase(displayCase);
  try {
    await verify(render);
  } finally {
    render.dispose();
  }
}
