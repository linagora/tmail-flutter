import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_prompt.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_state_source.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_upload_validation_service.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_validation_feedback.dart';

class _FakeStateSource implements AttachmentUploadStateSource {
  @override
  final int currentAllAttachmentBytes;
  @override
  final int currentRegularAttachmentBytes;
  @override
  final int warningLimitBytes;
  @override
  final int? hardLimitBytes;

  const _FakeStateSource({
    this.currentAllAttachmentBytes = 0,
    this.currentRegularAttachmentBytes = 0,
    this.warningLimitBytes = 1000,
    this.hardLimitBytes,
  });
}

class _MutableStateSource implements AttachmentUploadStateSource {
  @override
  int currentAllAttachmentBytes = 0;

  @override
  int currentRegularAttachmentBytes = 0;

  @override
  final int warningLimitBytes;

  @override
  final int? hardLimitBytes;

  _MutableStateSource({
    this.warningLimitBytes = 10000,
    this.hardLimitBytes,
  });
}

class _RecordingFeedback implements AttachmentValidationFeedback {
  final bool confirmed;

  AttachmentUploadFailure? failureShown;
  List<AttachmentUploadPrompt> promptsAsked = [];

  _RecordingFeedback({this.confirmed = true});

  @override
  Future<void> showFailure(AttachmentUploadFailure failure) async {
    failureShown = failure;
  }

  @override
  Future<bool> confirmAll(List<AttachmentUploadPrompt> prompts) async {
    promptsAsked = prompts;
    return confirmed;
  }
}

FileInfo _file({required int fileSize, bool isInline = false}) => FileInfo(
      fileName: 'file-$fileSize',
      filePath: '/tmp/file-$fileSize',
      fileSize: fileSize,
      isInline: isInline,
    );

void main() {
  late BuildContext context;

  AttachmentUploadValidationService buildService({
    required AttachmentUploadStateSource stateSource,
    required AttachmentValidationFeedback feedback,
  }) {
    return AttachmentUploadValidationService(
      stateSource: stateSource,
      feedbackBuilder: (_) => feedback,
    );
  }

  group('AttachmentUploadValidationService::validateFiles', () {
    testWidgets('Should run onAllowed when no limit is reached', (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      context = tester.element(find.byType(SizedBox));
      final feedback = _RecordingFeedback();
      var allowedCalled = false;

      await buildService(
        stateSource: const _FakeStateSource(hardLimitBytes: 10000),
        feedback: feedback,
      ).validateFiles(
        context: context,
        files: [_file(fileSize: 100)],
        onAllowed: () => allowedCalled = true,
      );

      expect(allowedCalled, isTrue);
      expect(feedback.failureShown, isNull);
      expect(feedback.promptsAsked, isEmpty);
    });

    testWidgets('Should show failure and skip onAllowed when the hard limit is exceeded',
        (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      context = tester.element(find.byType(SizedBox));
      final feedback = _RecordingFeedback();
      var allowedCalled = false;

      await buildService(
        stateSource: const _FakeStateSource(hardLimitBytes: 500),
        feedback: feedback,
      ).validateFiles(
        context: context,
        files: [_file(fileSize: 600)],
        onAllowed: () => allowedCalled = true,
      );

      expect(allowedCalled, isFalse);
      expect(feedback.failureShown, isA<MaxEmailAttachmentSizeExceeded>());
    });

    testWidgets(
        'Should NOT ask for confirmation when only inline files exceed the warning limit',
        (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      context = tester.element(find.byType(SizedBox));
      final feedback = _RecordingFeedback();
      var allowedCalled = false;

      await buildService(
        stateSource: const _FakeStateSource(warningLimitBytes: 500),
        feedback: feedback,
      ).validateFiles(
        context: context,
        files: [_file(fileSize: 600, isInline: true)],
        onAllowed: () => allowedCalled = true,
      );

      expect(allowedCalled, isTrue);
      expect(feedback.promptsAsked, isEmpty);
    });

    testWidgets(
        'Should ask for confirmation when already picked attachments push the total\n'
        'over the warning limit', (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      context = tester.element(find.byType(SizedBox));
      final feedback = _RecordingFeedback();
      var allowedCalled = false;

      await buildService(
        stateSource: const _FakeStateSource(
          currentAllAttachmentBytes: 400,
          currentRegularAttachmentBytes: 400,
          warningLimitBytes: 500,
        ),
        feedback: feedback,
      ).validateFiles(
        context: context,
        files: [_file(fileSize: 200)],
        onAllowed: () => allowedCalled = true,
      );

      expect(allowedCalled, isTrue);
      expect(feedback.promptsAsked, [isA<LargeRegularAttachmentWarning>()]);
    });

    testWidgets('Should skip onAllowed when the user declines the warning confirmation',
        (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      context = tester.element(find.byType(SizedBox));
      final feedback = _RecordingFeedback(confirmed: false);
      var allowedCalled = false;

      await buildService(
        stateSource: const _FakeStateSource(warningLimitBytes: 500),
        feedback: feedback,
      ).validateFiles(
        context: context,
        files: [_file(fileSize: 600)],
        onAllowed: () => allowedCalled = true,
      );

      expect(allowedCalled, isFalse);
      expect(feedback.promptsAsked, [isA<LargeRegularAttachmentWarning>()]);
    });
  });

  group('AttachmentUploadValidationService::validateAttachment', () {
    testWidgets('Should count an inline attachment toward the hard limit only', (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      context = tester.element(find.byType(SizedBox));
      final feedback = _RecordingFeedback();
      var allowedCalled = false;

      final inlineAttachment = Attachment(
        blobId: Id('inline-attachment'),
        size: UnsignedInt(600),
        disposition: ContentDisposition.inline,
      );

      await buildService(
        stateSource: const _FakeStateSource(warningLimitBytes: 500, hardLimitBytes: 10000),
        feedback: feedback,
      ).validateAttachment(
        context: context,
        attachment: inlineAttachment,
        onAllowed: () => allowedCalled = true,
      );

      expect(allowedCalled, isTrue);
      expect(feedback.promptsAsked, isEmpty);
    });

    testWidgets('Should show failure when a regular attachment exceeds the hard limit',
        (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      context = tester.element(find.byType(SizedBox));
      final feedback = _RecordingFeedback();
      var allowedCalled = false;

      final attachment = Attachment(
        blobId: Id('regular-attachment'),
        size: UnsignedInt(600),
        disposition: ContentDisposition.attachment,
      );

      await buildService(
        stateSource: const _FakeStateSource(hardLimitBytes: 500),
        feedback: feedback,
      ).validateAttachment(
        context: context,
        attachment: attachment,
        onAllowed: () => allowedCalled = true,
      );

      expect(allowedCalled, isFalse);
      expect(feedback.failureShown, isA<MaxEmailAttachmentSizeExceeded>());
    });
  });

  group('AttachmentUploadValidationService without a BuildContext', () {
    test(
        'Should still call onAllowed and never build feedback\n'
        'When both context and currentContext are null and validation passes',
        () async {
      var feedbackBuilderCalled = false;
      var allowedCalled = false;

      final service = AttachmentUploadValidationService(
        stateSource: const _FakeStateSource(hardLimitBytes: 10000),
        feedbackBuilder: (_) {
          feedbackBuilderCalled = true;
          return _RecordingFeedback();
        },
      );

      await service.validateFiles(
        files: [_file(fileSize: 100)],
        onAllowed: () => allowedCalled = true,
      );

      expect(allowedCalled, isTrue);
      expect(feedbackBuilderCalled, isFalse);
    });
  });

  group('AttachmentUploadValidationService::isExceededMaxSizeAttachmentsPerEmail', () {
    test('Should return true when the current total exceeds the hard limit', () {
      final service = buildService(
        stateSource: const _FakeStateSource(currentAllAttachmentBytes: 600, hardLimitBytes: 500),
        feedback: _RecordingFeedback(),
      );

      expect(service.isExceededMaxSizeAttachmentsPerEmail(), isTrue);
    });

    test('Should return false when the current total is within the hard limit', () {
      final service = buildService(
        stateSource: const _FakeStateSource(currentAllAttachmentBytes: 400, hardLimitBytes: 500),
        feedback: _RecordingFeedback(),
      );

      expect(service.isExceededMaxSizeAttachmentsPerEmail(), isFalse);
    });

    test('Should return false when the server advertises no hard limit', () {
      final service = buildService(
        stateSource: const _FakeStateSource(currentAllAttachmentBytes: 999999),
        feedback: _RecordingFeedback(),
      );

      expect(service.isExceededMaxSizeAttachmentsPerEmail(), isFalse);
    });
  });

  group('AttachmentUploadValidationService state reads', () {
    test(
        'Should reject a second upload that pushes the committed total over the hard limit',
        () async {
      final stateSource = _MutableStateSource(
        warningLimitBytes: 10000,
        hardLimitBytes: 1000,
      );
      final service = buildService(
        stateSource: stateSource,
        feedback: _RecordingFeedback(),
      );
      var allowedUploads = 0;

      void registerUpload() {
        allowedUploads++;
        stateSource.currentAllAttachmentBytes += 600;
        stateSource.currentRegularAttachmentBytes += 600;
      }

      await service.validateFiles(
        files: [_file(fileSize: 600)],
        onAllowed: registerUpload,
      );
      await service.validateFiles(
        files: [_file(fileSize: 600)],
        onAllowed: registerUpload,
      );

      expect(allowedUploads, 1);
      expect(stateSource.currentAllAttachmentBytes, 600);
    });

    test(
        'Should evaluate overlapping validations against uncommitted state, '
        'letting both proceed past the hard limit', () async {
      // Documents an accepted limitation rather than a guarantee. Validation is
      // a UX guard evaluated against what is committed at call time. Two
      // attachment actions can only overlap while a confirmation dialog awaits
      // the user; neither then sees the other's bytes. The composer's send
      // guard and the server both reject the combined total afterwards.
      final stateSource = _MutableStateSource(
        warningLimitBytes: 10000,
        hardLimitBytes: 1000,
      );
      final service = buildService(
        stateSource: stateSource,
        feedback: _RecordingFeedback(),
      );
      var allowedUploads = 0;

      void registerUpload() {
        allowedUploads++;
        stateSource.currentAllAttachmentBytes += 600;
        stateSource.currentRegularAttachmentBytes += 600;
      }

      await Future.wait([
        service.validateFiles(
          files: [_file(fileSize: 600)],
          onAllowed: registerUpload,
        ),
        service.validateFiles(
          files: [_file(fileSize: 600)],
          onAllowed: registerUpload,
        ),
      ]);

      expect(allowedUploads, 2);
      expect(stateSource.currentAllAttachmentBytes, 1200);
      expect(service.isExceededMaxSizeAttachmentsPerEmail(), isTrue);
    });
  });
}
