import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

class _OfflineDioClient extends Fake implements DioClient {}

/// Behaviour of the web "edit draft" pipeline as the composer sees it: which
/// identity signatures reach the editor visible. Asserts on the final HTML
/// only, not on which transformer produced it.
void main() {
  setUp(() => PlatformInfo.isTestingForWeb = true);
  tearDown(() => PlatformInfo.isTestingForWeb = false);

  Future<String> reopenDraft(String html) =>
      HtmlTransform(_OfflineDioClient(), const HtmlEscape()).transformToHtml(
        htmlContent: html,
        transformConfiguration: TransformConfiguration.forEditDraftsEmail(),
      );

  bool isHidden(Element signature) {
    final style = (signature.attributes['style'] ?? '').toLowerCase();
    return RegExp(r'display\s*:\s*none').hasMatch(style);
  }

  List<Element> topLevelSignatures(String html) =>
      parse(html).querySelectorAll('body > .tmail-signature');

  List<Element> nestedSignatures(String html) =>
      parse(html).querySelectorAll('blockquote .tmail-signature');

  group('reopening a draft', () {
    test('keeps the identity signature visible', () async {
      final out = await reopenDraft(
        '<div>Hello</div><div class="tmail-signature">Sig</div>',
      );

      final signatures = topLevelSignatures(out);
      expect(signatures, hasLength(1));
      expect(isHidden(signatures.single), isFalse);
    });

    test('keeps a signature with an explicit display: block visible', () async {
      final out = await reopenDraft(
        '<div>Hello</div>'
        '<div class="tmail-signature" style="display: block">Sig</div>',
      );

      final signatures = topLevelSignatures(out);
      expect(signatures, hasLength(1));
      expect(isHidden(signatures.single), isFalse);
    });

    test('keeps the identity signature visible when the draft also quotes '
        'another message', () async {
      final out = await reopenDraft(
        '<div>Reply</div><div class="tmail-signature">Mine</div>'
        '<blockquote><div>Original</div></blockquote>',
      );

      final signatures = topLevelSignatures(out);
      expect(signatures, hasLength(1));
      expect(isHidden(signatures.single), isFalse);
    });

    test('does not hide the signature after being reopened twice', () async {
      const draft = '<div>Hello</div><div class="tmail-signature">Sig</div>';

      final once = await reopenDraft(draft);
      final twice = await reopenDraft(once);

      expect(twice, once);
      expect(isHidden(topLevelSignatures(twice).single), isFalse);
    });

    test('hides a signature that only exists inside quoted content', () async {
      final out = await reopenDraft(
        '<div>Reply</div>'
        '<blockquote><div class="tmail-signature">Quoted</div></blockquote>',
      );

      final signatures = nestedSignatures(out);
      expect(signatures, hasLength(1));
      expect(isHidden(signatures.single), isTrue);
    });
  });
}
