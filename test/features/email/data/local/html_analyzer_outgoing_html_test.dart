import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/utils/html/active_html_content_stripper.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:uuid/uuid.dart';

import 'html_analyzer_outgoing_html_test.mocks.dart';

// DioClient: required by the HtmlTransform constructor.
// FileUploader, Uuid: required by the HtmlAnalyzer constructor; not used
// when the content has no base64 image.
@GenerateNiceMocks([
  MockSpec<DioClient>(),
  MockSpec<FileUploader>(),
  MockSpec<Uuid>(),
])
void main() {
  // A body that starts with a <style> element, as the web editor returns it
  // for content pasted or written in the code view. HTML parsers hoist a
  // leading <style> into <head>, so keeping only `body.innerHtml` drops it
  // and the recipient loses the formatting.
  const styledBody =
      '<style>p.mark{color:blue}</style><p class="mark">direct</p>'
      '<div class="tmail-signature"><span class="tmail_signature_prefix">-- </span><br>Bob<br></div>';

  late HtmlAnalyzer htmlAnalyzer;

  setUp(() {
    htmlAnalyzer = HtmlAnalyzer(
      HtmlTransform(MockDioClient(), const HtmlEscape()),
      MockFileUploader(),
      MockUuid(),
    );
  });

  group('HtmlAnalyzer outgoing HTML:', () {
    test(
      'removeCollapsedExpandedSignatureEffect SHOULD keep a leading style element',
    () async {
      final result = await htmlAnalyzer.removeCollapsedExpandedSignatureEffect(
        emailContent: styledBody,
      );

      expect(result, contains('<style>p.mark{color:blue}</style>'));
      expect(result, contains('<p class="mark">direct</p>'));
    });

    test(
      'the send pipeline SHOULD keep a leading style element',
    () async {
      // Same steps, in the same order, as ComposerRepositoryImpl.generateEmail.
      final withInlineImages = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: styledBody,
        inlineAttachments: {},
        uploadUri: null,
      );
      var content = withInlineImages.value1;
      content = await htmlAnalyzer.removeCollapsedExpandedSignatureEffect(
        emailContent: content,
      );
      content = ActiveHtmlContentStripper.strip(content);
      content = HtmlUtils.wrapPlainTextLinks(content);

      expect(content, contains('<style>p.mark{color:blue}</style>'));
      expect(content, contains('<p class="mark">direct</p>'));
    });
  });
}
