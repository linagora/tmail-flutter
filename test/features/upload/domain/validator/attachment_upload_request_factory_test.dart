import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request_factory.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_state_source.dart';

class _FakeStateSource implements AttachmentUploadStateSource {
  @override
  final int currentAllAttachmentBytes;
  @override
  final int currentRegularAttachmentBytes;

  const _FakeStateSource({
    this.currentAllAttachmentBytes = 0,
    this.currentRegularAttachmentBytes = 0,
  });
  
  @override
  int? get hardLimitBytes => 0;
  
  @override
  int get warningLimitBytes => 0;
}

FileInfo _file({required int fileSize, bool? isInline}) => FileInfo(
      fileName: 'file-$fileSize',
      filePath: '/tmp/file-$fileSize',
      fileSize: fileSize,
      isInline: isInline,
    );

void main() {
  const factory = AttachmentUploadRequestFactory();

  group('AttachmentUploadRequestFactory.fromProposedFiles', () {
    test('Should yield all-zero proposed bytes when files is empty', () {
      final request = factory.fromProposedFiles(
        files: const [],
        state: const _FakeStateSource(),
      );

      expect(request.sizes.proposedAllAttachmentBytes, 0);
      expect(request.sizes.proposedRegularAttachmentBytes, 0);
    });

    test('Should count a file with isInline null toward both totals', () {
      final request = factory.fromProposedFiles(
        files: [_file(fileSize: 100)],
        state: const _FakeStateSource(),
      );

      expect(request.sizes.proposedAllAttachmentBytes, 100);
      expect(request.sizes.proposedRegularAttachmentBytes, 100);
    });

    test('Should count a file with isInline false toward both totals', () {
      final request = factory.fromProposedFiles(
        files: [_file(fileSize: 100, isInline: false)],
        state: const _FakeStateSource(),
      );

      expect(request.sizes.proposedAllAttachmentBytes, 100);
      expect(request.sizes.proposedRegularAttachmentBytes, 100);
    });

    test('Should count a file with isInline true toward all but exclude it from regular', () {
      final request = factory.fromProposedFiles(
        files: [_file(fileSize: 100, isInline: true)],
        state: const _FakeStateSource(),
      );

      expect(request.sizes.proposedAllAttachmentBytes, 100);
      expect(request.sizes.proposedRegularAttachmentBytes, 0);
    });

    test('Should sum mixed inline and regular files separately', () {
      final request = factory.fromProposedFiles(
        files: [
          _file(fileSize: 100, isInline: true),
          _file(fileSize: 50, isInline: false),
        ],
        state: const _FakeStateSource(),
      );

      expect(request.sizes.proposedAllAttachmentBytes, 150);
      expect(request.sizes.proposedRegularAttachmentBytes, 50);
    });

    test('Should forward the current bytes from the state source unchanged', () {
      final request = factory.fromProposedFiles(
        files: const [],
        state: const _FakeStateSource(
          currentAllAttachmentBytes: 10,
          currentRegularAttachmentBytes: 5,
        ),
      );

      expect(request.sizes.currentAllAttachmentBytes, 10);
      expect(request.sizes.currentRegularAttachmentBytes, 5);
    });

    test('Should throw ArgumentError when currentAllAttachmentBytes is negative', () {
      expect(
        () => factory.fromProposedFiles(
          files: const [],
          state: const _FakeStateSource(currentAllAttachmentBytes: -1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('AttachmentUploadRequestFactory.fromProposedBytes', () {
    test('Should place proposed and current bytes into the matching snapshot fields', () {
      final request = factory.fromProposedBytes(
        proposedAllAttachmentBytes: 100,
        proposedRegularAttachmentBytes: 60,
        state: const _FakeStateSource(
          currentAllAttachmentBytes: 10,
          currentRegularAttachmentBytes: 5,
        ),
      );

      expect(request.sizes.proposedAllAttachmentBytes, 100);
      expect(request.sizes.proposedRegularAttachmentBytes, 60);
      expect(request.sizes.currentAllAttachmentBytes, 10);
      expect(request.sizes.currentRegularAttachmentBytes, 5);
    });

    test('Should throw ArgumentError when a proposed byte count is negative', () {
      expect(
        () => factory.fromProposedBytes(
          proposedAllAttachmentBytes: -1,
          proposedRegularAttachmentBytes: 0,
          state: const _FakeStateSource(),
        ),
        throwsArgumentError,
      );
    });
  });

  group('AttachmentUploadRequestFactory.normalizeServerLimitBytes', () {
    test('Should return null when value is null', () {
      expect(AttachmentUploadRequestFactory.normalizeServerLimitBytes(null), isNull);
    });

    test('Should truncate a whole-number double to int', () {
      expect(AttachmentUploadRequestFactory.normalizeServerLimitBytes(20.0), 20);
    });

    test('Should throw ArgumentError for a negative value', () {
      expect(
        () => AttachmentUploadRequestFactory.normalizeServerLimitBytes(-1),
        throwsArgumentError,
      );
    });

    test('Should throw ArgumentError for a fractional value', () {
      expect(
        () => AttachmentUploadRequestFactory.normalizeServerLimitBytes(1.5),
        throwsArgumentError,
      );
    });

    test('Should throw ArgumentError for a non-finite value', () {
      expect(
        () => AttachmentUploadRequestFactory.normalizeServerLimitBytes(double.infinity),
        throwsArgumentError,
      );
    });
  });
}
