import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

class _OfflineDioClient extends Fake implements DioClient {}

/// A received email loaded into the composer keeps the sender's links. The
/// editor's link tooltip opens an href with `window.open` in the app window,
/// so a relative href would open a route of the app itself (for example a
/// composer pre-filled by `/mailto?uri=...`).
void main() {
  tearDown(() => PlatformInfo.isTestingForWeb = false);

  Future<Document> transform(String html, TransformConfiguration configuration) async =>
      parse(await HtmlTransform(_OfflineDioClient(), const HtmlEscape()).transformToHtml(
        htmlContent: html,
        transformConfiguration: configuration,
      ));

  String? hrefOf(Document document, String text) => document
      .querySelectorAll('a')
      .singleWhere((anchor) => anchor.text == text)
      .attributes['href'];

  const relativeLinks = {
    'plain': '/mailto?uri=mailto%3Aattacker%40evil.test',
    'encoded-scheme': 'x%3A/../../mailto?uri=mailto%3Aattacker%40evil.test',
    'query': '?type=normal',
    'empty': '',
  };

  final untrustedPipelines = <String, TransformConfiguration Function()>{
    'edit as new on web': () {
      PlatformInfo.isTestingForWeb = true;
      return TransformConfiguration.forEditAsNewEmail();
    },
    'edit as new on mobile': () {
      PlatformInfo.isTestingForWeb = false;
      return TransformConfiguration.forEditAsNewEmail();
    },
    'reply to a message whose body is not loaded': TransformConfiguration.forReplyForwardEmptyEmail,
  };

  untrustedPipelines.forEach((name, createConfiguration) {
    group(name, () {
      for (final entry in relativeLinks.entries) {
        test('SHOULD drop the ${entry.key} relative href', () async {
          final document = await transform(
            '<p><a href="${entry.value}">${entry.key}</a></p>',
            createConfiguration(),
          );

          expect(hrefOf(document, entry.key), isNull);
        });
      }

      test('SHOULD keep absolute, mailto and fragment hrefs', () async {
        final document = await transform(
          '<a href="https://example.com/doc">web</a>'
          '<a href="mailto:bob@example.com">mail</a>'
          '<a href="#part-2">fragment</a>',
          createConfiguration(),
        );

        expect(hrefOf(document, 'web'), 'https://example.com/doc');
        expect(hrefOf(document, 'mail'), 'mailto:bob@example.com');
        expect(hrefOf(document, 'fragment'), '#part-2');
        for (final anchor in document.querySelectorAll('a')) {
          expect(anchor.attributes.containsKey('target'), isFalse);
          expect(anchor.attributes.containsKey('rel'), isFalse);
        }
      });

      test('SHOULD keep a drive link card with its href and contenteditable guard', () async {
        final document = await transform(
          '<a class="tmail-file-link-card" contenteditable="false" '
          'href="https://drive.example.com/f/1">card</a>',
          createConfiguration(),
        );

        final card = document.querySelector('a.tmail-file-link-card')!;
        expect(card.attributes['href'], 'https://drive.example.com/f/1');
        expect(card.attributes['contenteditable'], 'false');
      });
    });
  });

  group('reopening the user own draft', () {
    test('SHOULD leave its links untouched', () async {
      PlatformInfo.isTestingForWeb = true;
      final document = await transform(
        '<a href="https://example.com/a%20b">web</a>',
        TransformConfiguration.forEditDraftsEmail(),
      );

      final anchor = document.querySelector('a')!;
      expect(anchor.attributes['href'], 'https://example.com/a%20b');
      expect(anchor.attributes.containsKey('target'), isFalse);
      expect(anchor.attributes.containsKey('rel'), isFalse);
    });
  });
}
