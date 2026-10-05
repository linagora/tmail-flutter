import 'dart:convert';
import 'dart:io';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import 'html_transform_text_html_test.mocks.dart';

/// Which HTML pipeline runs the sanitizer is a security decision: this table
/// makes it explicit, so a pipeline that silently gains or loses the
/// sanitizer fails here. Update the table on purpose when that changes.
enum Wiring { sanitizes, passesThrough, stripsStyles }

void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
  });

  final expectedWiring = <String, (TransformConfiguration Function(), Wiring)>{
    'drafts': (TransformConfiguration.forDraftsEmail, Wiring.sanitizes),
    'edit drafts': (TransformConfiguration.forEditDraftsEmail, Wiring.sanitizes),
    'web viewer': (TransformConfiguration.forPreviewEmailOnWeb, Wiring.sanitizes),
    'mobile viewer': (TransformConfiguration.forPreviewEmail, Wiring.sanitizes),
    'restore': (TransformConfiguration.forRestoreEmail, Wiring.sanitizes),
    'signature identity': (TransformConfiguration.forSignatureIdentity, Wiring.sanitizes),
    'calendar event': (TransformConfiguration.forCalendarEvent, Wiring.sanitizes),
    'standard': (() => TransformConfiguration.standardConfiguration, Wiring.sanitizes),
    'reply forward': (TransformConfiguration.forReplyForwardEmail, Wiring.passesThrough),
    'reply forward empty': (TransformConfiguration.forReplyForwardEmptyEmail, Wiring.passesThrough),
    'composer signature': (TransformConfiguration.forComposerSignature, Wiring.passesThrough),
    'print': (TransformConfiguration.forPrintEmail, Wiring.stripsStyles),
  };

  // A flat stylesheet and an event handler: every sanitizer version removes
  // both, so the wiring is observed independently of the CSS policy.
  const probe = '<style>.x{color:red;position:fixed}</style>'
      '<p class="x" onclick="alert(1)">x</p>';

  Wiring observedWiring(String html) {
    final style = RegExp(r'<style[^>]*>(.*?)</style>', dotAll: true).firstMatch(html)?.group(1);
    if (style == null) return Wiring.stripsStyles;
    final sanitized = !style.contains('position') && !html.contains('onclick');
    return sanitized ? Wiring.sanitizes : Wiring.passesThrough;
  }

  test('covers every TransformConfiguration factory', () {
    final source = File('lib/presentation/utils/html_transformer/transform_configuration.dart').readAsStringSync();
    final factories = RegExp(r'factory TransformConfiguration\.(for\w+)\(\)').allMatches(source).length;

    // + 1 for standardConfiguration, which is a getter, not a factory.
    expect(expectedWiring.length, factories + 1, reason: 'a new pipeline needs a row in this table');
  });

  expectedWiring.forEach((pipeline, entry) {
    final (create, wiring) = entry;

    test('$pipeline ${wiring.name}', () async {
      final html = await htmlTransform.transformToHtml(
        htmlContent: probe,
        transformConfiguration: create(),
      );

      expect(observedWiring(html), wiring, reason: 'output: $html');
    });
  });
}
