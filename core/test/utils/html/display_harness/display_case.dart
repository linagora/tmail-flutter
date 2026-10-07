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

/// Runs the production pipeline for [displayCase]: the viewer's transform
/// configuration (or `forPlainTextEmail` for `text/plain`), the offline image
/// swap, the viewer's document builder, then an iframe at the pane width.
Future<DisplayRender> renderDisplayCase(DisplayCase displayCase) async {
  final fixture = displayCase.fixture;
  final transformed = fixture.isPlainText
      ? _htmlTransform.transformToTextPlain(
          content: fixture.html,
          transformConfiguration: TransformConfiguration.forPlainTextEmail(),
        )
      : await _htmlTransform.transformToHtml(
          htmlContent: fixture.html,
          transformConfiguration: displayCase.viewer.transformConfiguration(),
        );
  final document = displayCase.viewer.buildDocument(
    swapImagesForOffline(transformed),
    displayCase.width,
    direction: displayCase.direction,
  );
  final frame = await DisplayFrame.render(
    document,
    displayCase.width,
    label: displayCase.label,
  );
  return DisplayRender(displayCase, transformed, document, frame);
}

/// Every fixture of [corpus] on every viewer and width.
Iterable<DisplayCase> displayCases({
  List<HtmlEmailCorpusFixture> corpus = htmlEmailCorpus,
  Iterable<DisplayViewer> viewers = DisplayViewer.values,
}) sync* {
  for (final fixture in corpus) {
    for (final viewer in viewers) {
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
