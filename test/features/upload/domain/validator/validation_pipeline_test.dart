import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_limits.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_prompt.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_size_snapshot.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/validation_decision.dart';

const _request = AttachmentUploadRequest(
  sizes: AttachmentUploadSizeSnapshot(
    currentAllAttachmentBytes: 0,
    proposedAllAttachmentBytes: 0,
    currentRegularAttachmentBytes: 0,
    proposedRegularAttachmentBytes: 0,
  ),
  limits: AttachmentUploadLimits(warningLimitBytes: 1000000000),
);

class _StubAttachmentUploadRule implements AttachmentUploadRule {
  final AttachmentUploadDecision result;
  int callCount = 0;

  _StubAttachmentUploadRule(this.result);

  @override
  AttachmentUploadDecision validate(AttachmentUploadRequest request) {
    callCount++;
    return result;
  }
}

void main() {
  group('ValidationPipeline (AttachmentUploadValidator)', () {
    test('should return ValidationAllowed when rules list is empty', () {
      final validator = AttachmentUploadValidator([]);

      final result = validator.validate(_request);

      expect(result, isA<ValidationAllowed>());
    });

    final pipelineCases = <({
      String description,
      AttachmentUploadDecision firstResult,
      Matcher expectedResult,
      int expectedSecondCallCount,
    })>[
      (
        description: 'should return ValidationAllowed when all rules pass',
        firstResult: const ValidationAllowed(),
        expectedResult: isA<ValidationAllowed>(),
        expectedSecondCallCount: 1,
      ),
      (
        description: 'should short-circuit and return ValidationRejected on the first hard reject',
        firstResult: const ValidationRejected(MaxEmailAttachmentSizeExceeded(100)),
        expectedResult: isA<ValidationRejected>(),
        expectedSecondCallCount: 0,
      ),
    ];
    for (final pipelineCase in pipelineCases) {
      test(pipelineCase.description, () {
        final first = _StubAttachmentUploadRule(pipelineCase.firstResult);
        final second = _StubAttachmentUploadRule(const ValidationAllowed());
        final validator = AttachmentUploadValidator([first, second]);

        final result = validator.validate(_request);

        expect(result, pipelineCase.expectedResult);
        expect(first.callCount, 1);
        expect(second.callCount, pipelineCase.expectedSecondCallCount);
      });
    }

    test('should return ValidationConfirmationRequired when no rule rejects but one asks to confirm', () {
      final first = _StubAttachmentUploadRule(const ValidationAllowed());
      final second = _StubAttachmentUploadRule(
        ValidationConfirmationRequired(const [LargeRegularAttachmentWarning()]));
      final third = _StubAttachmentUploadRule(const ValidationAllowed());
      final validator = AttachmentUploadValidator([first, second, third]);

      final result = validator.validate(_request) as ValidationConfirmationRequired;

      expect(result.prompts, hasLength(1));
      expect(first.callCount, 1);
      expect(second.callCount, 1);
      expect(third.callCount, 1);
    });

    test('collects prompts from every confirmation-required rule when nothing rejects', () {
      final first = _StubAttachmentUploadRule(
        ValidationConfirmationRequired(const [LargeRegularAttachmentWarning()]));
      final second = _StubAttachmentUploadRule(
        ValidationConfirmationRequired(const [LargeRegularAttachmentWarning()]));
      final validator = AttachmentUploadValidator([first, second]);

      final result = validator.validate(_request) as ValidationConfirmationRequired;

      expect(result.prompts, hasLength(2));
    });

    test('a later hard reject wins over an earlier pending confirmation', () {
      final first = _StubAttachmentUploadRule(
        ValidationConfirmationRequired(const [LargeRegularAttachmentWarning()]));
      final second = _StubAttachmentUploadRule(
        const ValidationRejected(MaxEmailAttachmentSizeExceeded(100)));
      final validator = AttachmentUploadValidator([first, second]);

      final result = validator.validate(_request);

      expect(result, isA<ValidationRejected>());
    });
  });
}
