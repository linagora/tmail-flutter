@TestOn('chrome')

import 'dart:js_interop';

import 'package:core/presentation/utils/html_transformer/dom/hide_draft_signature_transformer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' show parse;
import 'package:web/web.dart' as web;

import 'html_transform_text_html_test.mocks.dart';

/// Browser check: `display: block !important` must not keep a nested draft
/// signature visible after [HideDraftSignatureTransformer].
void main() {
  final dioClient = MockDioClient();
  const transformer = HideDraftSignatureTransformer();

  test(
    'nested signature with display block !important is not visible after hide',
    () async {
      final document = parse(
        '<blockquote><div class="tmail-signature" '
        'style="display: block !important;">Sig</div></blockquote>',
      );
      await transformer.process(document: document, dioClient: dioClient);

      final host = web.HTMLDivElement()
        ..innerHTML = document.body!.innerHtml.toJS;
      web.document.body!.append(host);
      addTearDown(() => host.remove());

      final signature = host.querySelector('.tmail-signature');
      expect(signature, isNotNull);
      final display =
          web.window.getComputedStyle(signature!).getPropertyValue('display');
      expect(display, 'none');
    },
  );
}
