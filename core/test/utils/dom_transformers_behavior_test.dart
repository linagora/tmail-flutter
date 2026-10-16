import 'dart:typed_data';

import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/add_lazy_loading_for_background_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/block_code_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/block_quoted_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/hide_draft_signature_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_collapsed_signature_button_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_lazy_loading_for_background_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_lazy_loading_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_max_width_in_image_style_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_style_tag_outside_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/script_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/signature_transformers.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:mockito/mockito.dart';

import 'html_transform_text_html_test.mocks.dart';

void main() {
  final dioClient = MockDioClient();

  Future<Document> run(
    Future<void> Function(Document document) process,
    String html,
  ) async {
    final document = parse(html);
    await process(document);
    return document;
  }

  Future<Document> processWith(DomTransformer transformer, String html) => run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        html,
      );

  String? styleOf(Document document, String selector) =>
      document.querySelector(selector)?.attributes['style'];

  group('style-injecting transformers', () {
    for (final (transformer, html, selector, style) in <(DomTransformer, String, String, String)>[
      (const BlockQuotedTransformer(), '<blockquote><p>quoted</p></blockquote>', 'blockquote',
          'border-left: 2px solid #eee'),
      (const BlockCodeTransformer(), '<pre>code</pre>', 'pre', 'overflow: auto'),
    ]) {
      test('${transformer.runtimeType} styles $selector', () async {
        expect(styleOf(await processWith(transformer, html), selector), contains(style));
      });

    }
  });

  group('SignatureTransformer', () {
    const transformer = SignatureTransformer();

    test('rewrites tmail-signature to blocked class', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<div class="tmail-signature">Sig</div>',
      );
      expect(
        document.querySelector('.tmail-signature-blocked')?.text,
        'Sig',
      );
      expect(document.querySelector('.tmail-signature'), isNull);
    });
  });

  group('HideDraftSignatureTransformer', () {
    const transformer = HideDraftSignatureTransformer();

    test('hides a visible signature', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<div class="tmail-signature" style="display: block;">Sig</div>',
      );
      expect(
        document.querySelector('.tmail-signature')!.attributes['style'],
        contains('display: none'),
      );
    });
  });

  group('RemoveCollapsedSignatureButtonTransformer', () {
    const transformer = RemoveCollapsedSignatureButtonTransformer();

    test('removes signature toggle buttons', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<div class="tmail-signature-button">...</div><p>keep</p>',
      );
      expect(document.querySelector('.tmail-signature-button'), isNull);
      expect(document.querySelector('p')!.text, 'keep');
    });
  });

  group('AddLazyLoadingForBackgroundImageTransformer', () {
    const transformer = AddLazyLoadingForBackgroundImageTransformer();

    test('moves background-image url to data-src and marks lazy', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<div style="color:red; background-image: url(https://cdn.example/bg.png);"></div>',
      );
      final element = document.querySelector('div')!;
      expect(element.attributes['data-src'], 'https://cdn.example/bg.png');
      expect(element.attributes.containsKey('lazy'), isTrue);
      expect(element.attributes['style'], isNot(contains('background-image')));
    });
  });

  group('RemoveLazyLoadingForBackgroundImageTransformer', () {
    const transformer = RemoveLazyLoadingForBackgroundImageTransformer();

    test('restores background-image from data-src', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<div lazy data-src="https://cdn.example/bg.png" style="color:red;"></div>',
      );
      final element = document.querySelector('div')!;
      expect(element.attributes['style'], contains('background-image:url(https://cdn.example/bg.png)'));
      expect(element.attributes.containsKey('lazy'), isFalse);
      expect(element.attributes.containsKey('data-src'), isFalse);
    });
  });

  group('RemoveLazyLoadingImageTransformer', () {
    const transformer = RemoveLazyLoadingImageTransformer();

    test('strips loading from images', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<img src="https://example.com/a.png" loading="lazy">',
      );
      expect(document.querySelector('img')!.attributes.containsKey('loading'), isFalse);
    });
  });

  group('RemoveMaxWidthInImageStyleTransformer', () {
    const transformer = RemoveMaxWidthInImageStyleTransformer();

    test('removes max-width:100% from image style', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<img src="x.png" style="max-width:100%; height:auto;">',
      );
      expect(
        document.querySelector('img')!.attributes['style'],
        isNot(contains('max-width:100%')),
      );
    });
  });

  group('RemoveStyleTagOutsideTransformer', () {
    const transformer = RemoveStyleTagOutsideTransformer();

    test('removes style tags', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<style>.x{color:red}</style><p>keep</p>',
      );
      expect(document.querySelector('style'), isNull);
      expect(document.querySelector('p')!.text, 'keep');
    });
  });

  group('RemoveScriptTransformer', () {
    const transformer = RemoveScriptTransformer();

    test('removes script tags', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<p>Before</p><script>alert(1)</script><p>After</p>',
      );
      expect(document.querySelector('script'), isNull);
      expect(document.body!.text, contains('Before'));
    });
  });

  group('ImageTransformer', () {
    const transformer = ImageTransformer();

    test('adds loading=lazy on http(s) images', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<img src="https://example.com/a.png">',
      );
      expect(document.querySelector('img')!.attributes['loading'], 'lazy');
    });

    test('rewrites cid src to a data URI when the map hits', () async {
      PlatformInfo.isTestingForWeb = true;
      addTearDown(() => PlatformInfo.isTestingForWeb = false);

      when(dioClient.get(any, options: anyNamed('options'))).thenAnswer(
        (_) async => Uint8List.fromList([1, 2, 3, 4]),
      );

      final document = parse('<img src="cid:img-1" data-mimetype="image/png">');
      await transformer.process(
        document: document,
        dioClient: dioClient,
        mapUrlDownloadCID: {'img-1': 'https://jmap.example/blob/img-1'},
      );

      final src = document.querySelector('img')!.attributes['src']!;
      expect(src, startsWith('data:image/png;base64,'));
      expect(document.querySelector('img')!.attributes['id'], 'cid:img-1');
    });

    test('keeps cid src when the download map misses', () async {
      final document = await run(
        (doc) => transformer.process(
          document: doc,
          dioClient: dioClient,
          mapUrlDownloadCID: const {},
        ),
        '<img src="cid:missing">',
      );
      expect(document.querySelector('img')!.attributes['src'], 'cid:missing');
    });
  });

  group('transformers leave HTML without their target unchanged', () {
    for (final (transformer, html) in <(DomTransformer, String)>[
      (const BlockQuotedTransformer(), '<p>plain</p>'),
      (const BlockCodeTransformer(), '<p>plain</p>'),
      (const SignatureTransformer(), '<p>body</p>'),
      (const HideDraftSignatureTransformer(), '<p>body</p>'),
      (const RemoveCollapsedSignatureButtonTransformer(), '<p>keep</p>'),
      (const AddLazyLoadingForBackgroundImageTransformer(), '<div style="color:red;"></div>'),
      (const RemoveLazyLoadingForBackgroundImageTransformer(), '<div style="color:red;"></div>'),
      (const RemoveLazyLoadingImageTransformer(), '<img src="https://example.com/a.png">'),
      (const RemoveMaxWidthInImageStyleTransformer(), '<img src="x.png" style="height:auto;">'),
      (const RemoveStyleTagOutsideTransformer(), '<p>keep</p>'),
      (const RemoveScriptTransformer(), '<p>keep</p>'),
      (const ImageTransformer(), '<img src="https://example.com/a.png" loading="eager">'),
    ]) {
      test('${transformer.runtimeType} leaves $html unchanged', () async {
        expect((await processWith(transformer, html)).outerHtml, parse(html).outerHtml);
      });
    }
  });
}
