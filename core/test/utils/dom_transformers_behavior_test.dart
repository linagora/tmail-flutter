import 'dart:typed_data';

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

  group('BlockQuotedTransformer', () {
    const transformer = BlockQuotedTransformer();

    test('injects quote border styles', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<blockquote><p>quoted</p></blockquote>',
      );
      expect(
        document.querySelector('blockquote')!.attributes['style'],
        contains('border-left: 2px solid #eee'),
      );
    });

    test('no-op without blockquote', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<p>plain</p>',
      );
      expect(document.querySelector('p')!.text, 'plain');
      expect(document.querySelector('blockquote'), isNull);
    });
  });

  group('BlockCodeTransformer', () {
    const transformer = BlockCodeTransformer();

    test('styles pre blocks', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<pre>code</pre>',
      );
      expect(
        document.querySelector('pre')!.attributes['style'],
        contains('overflow: auto'),
      );
    });

    test('no-op without pre', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<p>code</p>',
      );
      expect(document.querySelector('p')!.attributes.containsKey('style'), isFalse);
    });
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

    test('no-op without signature', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<p>body</p>',
      );
      expect(document.querySelector('.tmail-signature-blocked'), isNull);
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

    test('no-op without signature', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<p>body</p>',
      );
      expect(document.outerHtml, contains('<p>body</p>'));
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

    test('no-op without buttons', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<p>keep</p>',
      );
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

    test('no-op without background-image', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<div style="color:red;"></div>',
      );
      expect(document.querySelector('div')!.attributes.containsKey('lazy'), isFalse);
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

    test('no-op without lazy', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<div style="color:red;"></div>',
      );
      expect(document.querySelector('div')!.attributes['style'], 'color:red;');
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

    test('no-op without loading', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<img src="https://example.com/a.png">',
      );
      expect(document.querySelector('img')!.attributes['src'], 'https://example.com/a.png');
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

    test('no-op without max-width', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<img src="x.png" style="height:auto;">',
      );
      expect(document.querySelector('img')!.attributes['style'], 'height:auto;');
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

    test('no-op without style tags', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<p>keep</p>',
      );
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

    test('no-op without script', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<p>keep</p>',
      );
      expect(document.querySelector('p')!.text, 'keep');
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

    test('no-op when loading is already set', () async {
      final document = await run(
        (doc) => transformer.process(document: doc, dioClient: dioClient),
        '<img src="https://example.com/a.png" loading="eager">',
      );
      expect(document.querySelector('img')!.attributes['loading'], 'eager');
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
}
