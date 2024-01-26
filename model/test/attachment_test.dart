import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/model.dart';

void main() {
  final attachmentA = Attachment(
    disposition: ContentDisposition.attachment,
  );

  final attachmentB = Attachment(
    disposition: ContentDisposition.attachment,
  );

  final attachmentC = Attachment(
    disposition: ContentDisposition.attachment,
    cid: 'attachmentC',
  );

  final attachmentD = Attachment(
    disposition: ContentDisposition.attachment,
    type: MediaType.parse('image/pdf'),
  );

  final attachmentE = Attachment(
    disposition: ContentDisposition.attachment,
    type: MediaType.parse('application/rtf'),
  );

  final attachmentF = Attachment(
    disposition: ContentDisposition.inline,
    type: MediaType.parse('application/rtf'),
  );

  final attachmentG = Attachment(
    disposition: ContentDisposition.inline,
  );

  final attachmentH = Attachment();

  final attachmentI = Attachment(blobId: Id('attachmentI'));

  group('isOutsideAttachment method test', () {
    test(
      'GIVE attachmentA has disposition = `attachment` and cid is null\n'
      'AND htmlBodyAttachments is empty\n'
      'WHEN perform call `attachmentA.isOutsideAttachment()`\n'
      'SHOULD return true',
    () {
      List<Attachment> htmlBodyAttachments = [];
      bool result = attachmentA.isOutsideAttachment(htmlBodyAttachments);

      expect(result, isTrue);
    });

    test(
      'GIVE attachmentB has disposition = `attachment`\n'
      'AND htmlBodyAttachments is empty\n'
      'WHEN perform call `attachmentB.isOutsideAttachment()`\n'
      'SHOULD return true',
    () {
      List<Attachment> htmlBodyAttachments = [];
      bool result = attachmentB.isOutsideAttachment(htmlBodyAttachments);

      expect(result, isTrue);
    });

    test(
      'GIVE attachmentC has disposition = `attachment` and cid = `attachmentC`\n'
      'AND htmlBodyAttachments is empty\n'
      'WHEN perform call `attachmentB.isOutsideAttachment()`\n'
      'SHOULD return true',
    () {
      List<Attachment> htmlBodyAttachments = [];
      bool result = attachmentC.isOutsideAttachment(htmlBodyAttachments);

      expect(result, isTrue);
    });

    test(
      'GIVE attachmentD has disposition = `attachment` and mediaType = `image/pdf`\n'
      'AND htmlBodyAttachments is empty\n'
      'WHEN perform call `attachmentD.isOutsideAttachment()`\n'
      'SHOULD return true',
    () {
      List<Attachment> htmlBodyAttachments = [];
      bool result = attachmentD.isOutsideAttachment(htmlBodyAttachments);

      expect(result, isTrue);
    });

    test(
      'GIVE attachmentE has disposition = `attachment` and mediaType = `application/rtf`\n'
      'AND htmlBodyAttachments is empty\n'
      'WHEN perform call `attachmentE.isOutsideAttachment()`\n'
      'SHOULD return true',
    () {
      List<Attachment> htmlBodyAttachments = [];
      bool result = attachmentE.isOutsideAttachment(htmlBodyAttachments);

      expect(result, isTrue);
    });


    test(
      'GIVE attachmentF has disposition = `inline` and mediaType = `application/rtf`\n'
      'AND htmlBodyAttachments is empty\n'
      'WHEN perform call `attachmentF.isOutsideAttachment()`\n'
      'SHOULD return true',
    () {
      List<Attachment> htmlBodyAttachments = [];
      bool result = attachmentF.isOutsideAttachment(htmlBodyAttachments);

      expect(result, isFalse);
    });

    test(
      'GIVE attachmentG has disposition = `inline`\n'
      'AND htmlBodyAttachments is empty\n'
      'WHEN perform call `attachmentG.isOutsideAttachment()`\n'
      'SHOULD return false',
    () {
      List<Attachment> htmlBodyAttachments = [];
      bool result = attachmentG.isOutsideAttachment(htmlBodyAttachments);

      expect(result, isFalse);
    });

    test(
      'GIVE attachmentH has disposition is null\n'
      'AND htmlBodyAttachments is empty\n'
      'WHEN perform call `attachmentH.isOutsideAttachment()`\n'
      'SHOULD return true',
    () {
      List<Attachment> htmlBodyAttachments = [];
      bool result = attachmentH.isOutsideAttachment(htmlBodyAttachments);

      expect(result, isTrue);
    });

    test(
      'GIVE attachmentI has blobId = `attachmentI`\n'
      'AND htmlBodyAttachments has `attachmentI`\n'
      'WHEN perform call `attachmentI.isOutsideAttachment()`\n'
      'SHOULD return false',
    () {
      List<Attachment> htmlBodyAttachments = [attachmentI];
      bool result = attachmentI.isOutsideAttachment(htmlBodyAttachments);

      expect(result, isFalse);
    });
  });
}