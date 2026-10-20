import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/inline_image_cid_extension.dart';

class _FakeDioClient extends Fake implements DioClient {
  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async =>
      Uint8List.fromList([137, 80, 78, 71]);
}

/// A `cid:` image the composer loads comes back as `cid:` when the email is
/// sent: the transform inlines it with `id="cid:X"`, and the send path maps
/// that id back to the inline attachment.
void main() {
  const html = '<p>Hi</p><img src="cid:img-1" alt="logo">';
  const urls = {'img-1': 'https://fixture.invalid/download/img-1'};
  final attachment = Attachment(cid: 'img-1', name: 'logo.png');

  setUp(() {
    PlatformInfo.isTestingForWeb = true;
  });

  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
  });

  Future<String> restore(TransformConfiguration configuration) =>
      HtmlTransform(_FakeDioClient(), const HtmlEscape()).transformToHtml(
        htmlContent: html,
        transformConfiguration: configuration,
        mapCidImageDownloadUrl: urls,
      );

  final factories = <String, TransformConfiguration Function()>{
    'forEditDraftsEmail': TransformConfiguration.forEditDraftsEmail,
    'forRestoreEmail': TransformConfiguration.forRestoreEmail,
  };

  for (final entry in factories.entries) {
    test('${entry.key} then send restores cid: images', () async {
      final out = await restore(entry.value());
      expect(
        parse(out).querySelector('img')!.attributes['src'],
        startsWith('data:image/'),
      );

      final (sent, inline) = {'img-1': attachment}
          .replaceUploadedImagesWithCid(parse(out).body!.innerHtml);

      expect(parse(sent).querySelector('img')!.attributes['src'], 'cid:img-1');
      expect(inline, {attachment});
    });
  }

  test('an image that loses its cid id is not restored', () async {
    final out = await restore(TransformConfiguration.forRestoreEmail());
    final document = parse(out);
    document.querySelector('img')!.attributes.remove('id');

    final (sent, inline) = {'img-1': attachment}
        .replaceUploadedImagesWithCid(document.body!.innerHtml);

    expect(
      parse(sent).querySelector('img')!.attributes['src'],
      startsWith('data:image/'),
    );
    expect(inline, isEmpty);
  });
}
