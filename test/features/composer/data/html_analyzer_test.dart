import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:jmap_dart_client/jmap/core/id.dart' show Id;
import 'package:model/email/attachment.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:uuid/uuid.dart';
import 'html_analyzer_test.mocks.dart';

@GenerateMocks([HtmlTransform, FileUploader, Uuid])
void main() {
  group('HtmlAnalyzer::replaceImageBase64ToImageCID::', () {
    late HtmlAnalyzer htmlAnalyzer;
    late MockHtmlTransform mockHtmlTransform;
    late MockFileUploader mockFileUploader;
    late MockUuid mockUuid;

    setUp(() {
      mockHtmlTransform = MockHtmlTransform();
      mockFileUploader = MockFileUploader();
      mockUuid = MockUuid();
      htmlAnalyzer = HtmlAnalyzer(mockHtmlTransform, mockFileUploader, mockUuid);
    });

    test(
      'When HTML content has no base64 images,\n'
      'should return original content and empty attachments if no inline attachments exist',
    () async {
      const htmlContent = '<div>Hello World</div>';
      final inlineAttachments = <String, Attachment>{};
      final uploadUri = Uri.parse('https://example.com/upload');

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      expect(result.value1, htmlContent);
      expect(result.value2, isEmpty);
    });

    test(
      'When HTML content has an image with existing CID,\n'
      'should update src to CID format and include attachment in result',
    () async {
      const htmlContent = '<img id="cid:test123" src="data:image/png;base64,iVBORw0KGgo=">';
      final inlineAttachments = {
        'test123': Attachment(
          blobId: Id('test123'),
          type: MediaType('image', 'png'),
          disposition: ContentDisposition.inline,
          cid: 'test123',
        )
      };
      final uploadUri = Uri.parse('https://example.com/upload');

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      final document = parse(result.value1);
      final imgTag = document.querySelector('img');
      expect(imgTag?.attributes['src'], 'cid:test123');
      expect(imgTag?.attributes.containsKey('id'), isFalse);
      expect(result.value2.length, 1);
      expect(result.value2.first.cid, 'test123');
    });

    test(
      'When HTML content has an image with existing CID,\n'
      'but inlineAttachments is empty,\n'
      'should re-upload base64 succeeds then replace src with that CID and add attachment to result',
    () async {
      const htmlContent = '<img id="cid:test123" src="data:image/png;base64,iVBORw0KGgo=">';
      final inlineAttachments = <String, Attachment>{};
      final uploadUri = Uri.parse('https://example.com/upload');

      when(mockFileUploader.uploadAttachment(any, any, any))
        .thenAnswer((_) async => Attachment(
          blobId: Id('test123'),
          type: MediaType('image', 'png'),
          disposition: ContentDisposition.inline,
          cid: 'test123',
        ));

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      final document = parse(result.value1);
      final imgTag = document.querySelector('img');
      expect(imgTag?.attributes['src'], 'cid:test123');
      expect(imgTag?.attributes.containsKey('id'), isFalse);
      expect(result.value2.length, 1);
      expect(result.value2.first.cid, 'test123');
    });

    test(
      'When HTML content has a base64 image and upload succeeds,\n'
      'should replace src with new CID and add attachment to result',
    () async {
      const base64Data = 'iVBORw0KGgo=';
      const htmlContent = '<img src="data:image/png;base64,$base64Data">';
      final inlineAttachments = <String, Attachment>{};
      final uploadUri = Uri.parse('https://example.com/upload');

      when(mockUuid.v1()).thenReturn('new-uuid-123');
      when(mockFileUploader.uploadAttachment(any, any, any))
        .thenAnswer((_) async => Attachment(
          blobId: Id('blob123'),
          type: MediaType('image', 'png'),
          disposition: ContentDisposition.inline,
        ));

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      final document = parse(result.value1);
      final imgTag = document.querySelector('img');
      expect(imgTag?.attributes['src'], 'cid:new-uuid-123');
      expect(result.value2.length, 1);
      expect(result.value2.first.cid, 'new-uuid-123');
      verify(mockUuid.v1()).called(1);
      verify(mockFileUploader.uploadAttachment(any, any, uploadUri)).called(1);
    });

    test(
      'When upload URI is null and HTML has base64 images,\n'
      'should keep original src and not attempt uploads',
    () async {
      const htmlContent = '<img src="data:image/png;base64,iVBORw0KGgo=">';
      final inlineAttachments = <String, Attachment>{};

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: null,
      );

      expect(result.value1, htmlContent);
      expect(result.value2, isEmpty);
      verifyNever(mockFileUploader.uploadAttachment(any, any, any));
    });

    test(
      'When processing multiple base64 images,\n'
      'should replace each with a unique CID and add corresponding attachments',
    () async {
      const htmlContent = '''
        <img src="data:image/png;base64,iVBORw0KGgo=">
        <img src="data:image/jpeg;base64,/9j/4AAQSkZJRg==">
      ''';
      final inlineAttachments = <String, Attachment>{};
      final uploadUri = Uri.parse('https://example.com/upload');

      when(mockUuid.v1()).thenAnswer((_) => 'uuid1');

      when(mockFileUploader.uploadAttachment(any, any, any))
        .thenAnswer((_) async => Attachment(
          blobId: Id('blob123'),
          type: MediaType('image', 'png'),
          disposition: ContentDisposition.inline,
        ));

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      final document = parse(result.value1);
      final imgTags = document.querySelectorAll('img');
      expect(imgTags.length, 2);
      expect(imgTags[0].attributes['src'], contains('cid:'));
      expect(imgTags[1].attributes['src'], contains('cid:'));
      expect(result.value2.length, 2);
      verify(mockUuid.v1()).called(2);
      verify(mockFileUploader.uploadAttachment(any, any, uploadUri)).called(2);
    });

    test(
      'When processing 100 base64 images,\n'
      'should replace each with a unique CID and add corresponding attachments',
    () async {
      int countImage = 100;
      final htmlContent = '''
        ${List.generate(countImage, (index) => '<img src="data:image/jpeg;base64,/9j/4AAQSkZJRg==">').join(' ')}
      ''';
      final inlineAttachments = <String, Attachment>{};
      final uploadUri = Uri.parse('https://example.com/upload');

      when(mockUuid.v1()).thenAnswer((_) => 'uuid1');

      when(mockFileUploader.uploadAttachment(any, any, any))
        .thenAnswer((_) async => Attachment(
          blobId: Id('blob123'),
          type: MediaType('image', 'png'),
          disposition: ContentDisposition.inline,
        ));

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      final document = parse(result.value1);
      final imgTags = document.querySelectorAll('img');
      expect(imgTags.length, countImage);
      expect(imgTags.every((img) => img.attributes['src']!.contains('cid:')), isTrue);
      expect(result.value2.length, countImage);
      verify(mockUuid.v1()).called(countImage);
      verify(mockFileUploader.uploadAttachment(any, any, uploadUri)).called(countImage);
    });

    test(
      'When one image upload throws an exception out of multiple base64 images,\n'
      'should replace successful upload with CID and keep original src for failed one',
    () async {
      const htmlContent = '''
        <img src="data:image/png;base64,iVBORw0KGgo=">
        <img src="data:image/jpeg;base64,/9j/4AAQSkZJRg==">
      ''';
      final inlineAttachments = <String, Attachment>{};
      final uploadUri = Uri.parse('https://example.com/upload');

      when(mockUuid.v1()).thenAnswer((_) => 'uuid1');

      int uploadCallCount = 0;
      when(mockFileUploader.uploadAttachment(any, any, any))
        .thenAnswer((_) async {
          uploadCallCount++;
          if (uploadCallCount == 1) {
            return Attachment(
              blobId: Id('blob123'),
              type: MediaType('image', 'png'),
              disposition: ContentDisposition.inline,
            );
          } else {
            throw Exception('Upload failed for second image');
          }
        });

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      final document = parse(result.value1);
      final imgTags = document.querySelectorAll('img');
      expect(imgTags.length, 2);
      expect(imgTags[0].attributes['src'], 'cid:uuid1');
      expect(imgTags[1].attributes['src'], 'data:image/jpeg;base64,/9j/4AAQSkZJRg==');
      expect(result.value2.length, 1);
      expect(result.value2.first.cid, 'uuid1');
      verify(mockUuid.v1()).called(2);
      verify(mockFileUploader.uploadAttachment(any, any, uploadUri)).called(2);
    });

    test(
      'When all uploads throw exceptions for multiple base64 images,\n'
      'should keep original src for all images and add no attachments',
    () async {
      const htmlContent = '''
        <img src="data:image/png;base64,iVBORw0KGgo=">
        <img src="data:image/jpeg;base64,/9j/4AAQSkZJRg==">
      ''';
      final inlineAttachments = <String, Attachment>{};
      final uploadUri = Uri.parse('https://example.com/upload');

      when(mockUuid.v1()).thenAnswer((_) => 'uuid1');

      when(mockFileUploader.uploadAttachment(any, any, any))
        .thenThrow(Exception('Upload failed'));

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      final document = parse(result.value1);
      final imgTags = document.querySelectorAll('img');
      expect(imgTags.length, 2);
      expect(imgTags[0].attributes['src'], 'data:image/png;base64,iVBORw0KGgo=');
      expect(imgTags[1].attributes['src'], 'data:image/jpeg;base64,/9j/4AAQSkZJRg==');
      expect(result.value2.length, 0);
      verify(mockUuid.v1()).called(2);
      verify(mockFileUploader.uploadAttachment(any, any, uploadUri)).called(2);
    });

    test(
      'When processing an invalid base64 image that causes upload to throw an exception,\n'
      'should keep the original invalid src and add no attachments',
    () async {
      const htmlContent = '<img src="data:image/png;base64,invalid-base64-data">';
      final inlineAttachments = <String, Attachment>{};
      final uploadUri = Uri.parse('https://example.com/upload');

      when(mockUuid.v1()).thenAnswer((_) => 'uuid1');

      when(mockFileUploader.uploadAttachment(any, any, any))
        .thenThrow(Exception('Invalid base64 data'));

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      final document = parse(result.value1);
      final imgTags = document.querySelectorAll('img');
      expect(imgTags.length, 1);
      expect(imgTags[0].attributes['src'], 'data:image/png;base64,invalid-base64-data');
      expect(result.value2.length, 0);
      verify(mockUuid.v1()).called(1);
    });

    test(
      'When upload throws an exception for a base64 image,\n'
      'should keep the original src and add no attachments',
    () async {
      const htmlContent = '<img src="data:image/png;base64,iVBORw0KGgo=">';
      final inlineAttachments = <String, Attachment>{};
      final uploadUri = Uri.parse('https://example.com/upload');

      when(mockUuid.v1()).thenAnswer((_) => 'uuid1');

      when(mockFileUploader.uploadAttachment(any, any, any))
        .thenThrow(Exception('Upload failed'));

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      final document = parse(result.value1);
      final imgTags = document.querySelectorAll('img');
      expect(imgTags.length, 1);
      expect(imgTags[0].attributes['src'], 'data:image/png;base64,iVBORw0KGgo=');
      expect(result.value2.length, 0);
      verify(mockUuid.v1()).called(1);
      verify(mockFileUploader.uploadAttachment(any, any, any)).called(1);
    });

    test(
      'When HTML has both a base64 image (CID found) and a cid: image (download failed),\n'
      'should include attachments for both images in result',
    () async {
      // img1: converted to base64 with id="cid:img1" (normal flow)
      // img2: download failed, stayed as <img src="cid:img2"> (not in listImgTag)
      const htmlContent = '<img src="data:image/png;base64,iVBORw0KGgo=" id="cid:img1"> '
          '<img src="cid:img2">';
      final inlineAttachments = {
        'img1': Attachment(
          blobId: Id('blob1'),
          type: MediaType('image', 'png'),
          disposition: ContentDisposition.inline,
          cid: 'img1',
        ),
        'img2': Attachment(
          blobId: Id('blob2'),
          type: MediaType('image', 'png'),
          disposition: ContentDisposition.inline,
          cid: 'img2',
        ),
      };
      final uploadUri = Uri.parse('https://example.com/upload');

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      // Both attachments must be present so recipient can load both images
      expect(result.value2.length, 2);
      expect(result.value2.any((p) => p.cid == 'img1'), isTrue);
      expect(result.value2.any((p) => p.cid == 'img2'), isTrue);
    });
  });

  group('HtmlAnalyzer::replaceImageBase64ToImageCID - orphaned inline attachments::', () {
    late HtmlAnalyzer htmlAnalyzer;
    late MockHtmlTransform mockHtmlTransform;
    late MockFileUploader mockFileUploader;
    late MockUuid mockUuid;

    setUp(() {
      mockHtmlTransform = MockHtmlTransform();
      mockFileUploader = MockFileUploader();
      mockUuid = MockUuid();
      htmlAnalyzer = HtmlAnalyzer(mockHtmlTransform, mockFileUploader, mockUuid);
    });

    test(
      'When inlineAttachments has entries but HTML body has no cid: img reference,\n'
      'should return empty attachments (orphaned inline attachment must not be re-forwarded)',
    () async {
      // Simulates replying to a malformed Outlook email: the image is listed in
      // JMAP attachment metadata (inline + CID) but the HTML body never references it.
      const htmlContent = '<div>Hello World</div>';
      final inlineAttachments = {
        'orphan-cid': Attachment(
          blobId: Id('blob-orphan'),
          type: MediaType('image', 'png'),
          disposition: ContentDisposition.inline,
          cid: 'orphan-cid',
        ),
      };
      final uploadUri = Uri.parse('https://example.com/upload');

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      expect(result.value1, htmlContent);
      expect(result.value2, isEmpty);
      verifyNever(mockFileUploader.uploadAttachment(any, any, any));
    });

    test(
      'When inlineAttachments has entries and HTML has a matching cid: img reference,\n'
      'should return only the referenced attachment',
    () async {
      // img1 is referenced in the body (download failed, stays as cid:)
      // img2 is orphaned (not referenced in the body)
      const htmlContent = '<img src="cid:img1"><div>text</div>';
      final inlineAttachments = {
        'img1': Attachment(
          blobId: Id('blob1'),
          type: MediaType('image', 'png'),
          disposition: ContentDisposition.inline,
          cid: 'img1',
        ),
        'img2': Attachment(
          blobId: Id('blob2'),
          type: MediaType('image', 'png'),
          disposition: ContentDisposition.inline,
          cid: 'img2',
        ),
      };
      final uploadUri = Uri.parse('https://example.com/upload');

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      expect(result.value2.length, 1);
      expect(result.value2.any((p) => p.cid == 'img1'), isTrue);
      expect(result.value2.any((p) => p.cid == 'img2'), isFalse);
    });

    test(
      'When inlineAttachments is empty and HTML has no base64 images,\n'
      'should return empty attachments',
    () async {
      const htmlContent = '<div>Plain text, no images</div>';
      final inlineAttachments = <String, Attachment>{};
      final uploadUri = Uri.parse('https://example.com/upload');

      final result = await htmlAnalyzer.replaceImageBase64ToImageCID(
        emailContent: htmlContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );

      expect(result.value1, htmlContent);
      expect(result.value2, isEmpty);
    });
  });
}
