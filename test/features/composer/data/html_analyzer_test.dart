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
  });
}
