
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_size_limit_policy.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_size_limit_rule.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request_factory.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_upload_gate.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_state_source.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_validation_feedback.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_validation_feedback_impl.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef AttachmentValidationFeedbackBuilder = AttachmentValidationFeedback Function(BuildContext context);

/// Single entry point for every attachment upload call site: hand it what the
/// user wants to attach plus the action to run once allowed, and it builds the
/// validation request, runs the rules and shows the resulting dialogs.
class AttachmentUploadValidationService {
  static const AttachmentUploadRequestFactory _requestFactory = AttachmentUploadRequestFactory();

  final AttachmentUploadStateSource _stateSource;
  final AttachmentUploadGate _gate;
  final AttachmentValidationFeedbackBuilder _feedbackBuilder;

  /// Reads [_stateSource] with [_reservedAllAttachmentBytes] /
  /// [_reservedRegularAttachmentBytes] added on top, so a validation request
  /// built while a previously allowed upload is still in flight (bytes not
  /// yet reflected by [_stateSource], e.g. real network upload not finished)
  /// still sees those bytes as already committed.
  late final AttachmentUploadStateSource _effectiveStateSource =
      _ReservingStateSource(source: _stateSource, service: this);

  /// Serializes [_validate] calls so a second concurrent upload request is
  /// only built/validated once the previous one's gate check has resolved,
  /// preventing two overlapping validations from both passing and jointly
  /// exceeding the hard cap.
  Future<void> _lock = Future.value();

  int _reservedAllAttachmentBytes = 0;
  int _reservedRegularAttachmentBytes = 0;

  AttachmentUploadValidationService({
    required AttachmentUploadStateSource stateSource,
    AttachmentUploadValidator? validator,
    AttachmentValidationFeedbackBuilder? feedbackBuilder,
  })  : _stateSource = stateSource,
        _gate = AttachmentUploadGate(
            validator ?? AttachmentUploadValidator([const AttachmentSizeLimitRule()])),
        _feedbackBuilder = feedbackBuilder ?? AttachmentValidationFeedbackImpl.new;

  /// Validates the picked [files] then runs [onAllowed] when the upload may proceed.
  Future<void> validateFiles({
    BuildContext? context,
    required List<FileInfo> files,
    required VoidCallback onAllowed,
  }) {
    return _validate(
      context: context,
      requestBuilder: () => _requestFactory.fromProposedFiles(
        files: files,
        state: _effectiveStateSource,
      ),
      onAllowed: onAllowed,
    );
  }

  /// Validates an already uploaded [attachment] being re-attached, then runs
  /// [onAllowed] when the upload may proceed.
  Future<void> validateAttachment({
    BuildContext? context,
    required Attachment attachment,
    required VoidCallback onAllowed,
  }) {
    final attachmentBytes = (attachment.size?.value ?? 0).toInt();
    final isRegularAttachment = !attachment.isDispositionInlined();

    return _validate(
      context: context,
      requestBuilder: () => _requestFactory.fromProposedBytes(
        proposedAllAttachmentBytes: attachmentBytes,
        proposedRegularAttachmentBytes: isRegularAttachment ? attachmentBytes : 0,
        state: _effectiveStateSource,
      ),
      onAllowed: onAllowed,
    );
  }

  /// Whether what is already attached exceeds the server hard cap, without
  /// showing any dialog.
  bool isExceededMaxSizeAttachmentsPerEmail() {
    return AttachmentSizeLimitPolicy.isExceededMaxSizeAttachmentsPerEmail(
      allAttachmentBytes: _effectiveStateSource.currentAllAttachmentBytes,
      hardLimitBytes: _effectiveStateSource.hardLimitBytes,
    );
  }

  /// Releases bytes reserved by a previously allowed request once its upload
  /// has actually settled (succeeded or failed) and [_stateSource] reflects
  /// it. Callers must release exactly the bytes reserved for that request.
  void releaseReservedBytes({
    required int allAttachmentBytes,
    required int regularAttachmentBytes,
  }) {
    _reservedAllAttachmentBytes =
        math.max(0, _reservedAllAttachmentBytes - allAttachmentBytes);
    _reservedRegularAttachmentBytes =
        math.max(0, _reservedRegularAttachmentBytes - regularAttachmentBytes);
  }

  Future<void> _validate({
    BuildContext? context,
    required AttachmentUploadRequest Function() requestBuilder,
    required VoidCallback onAllowed,
  }) {
    final previous = _lock;
    final completer = Completer<void>();
    _lock = completer.future;
    return previous.then((_) async {
      try {
        final request = requestBuilder();
        final allowed = await _gate.permits(
          request: request,
          feedbackFactory: () {
            final resolvedContext = context ?? currentContext;
            return resolvedContext == null ? null : _feedbackBuilder(resolvedContext);
          },
        );
        if (allowed) {
          _reservedAllAttachmentBytes += request.sizes.proposedAllAttachmentBytes;
          _reservedRegularAttachmentBytes += request.sizes.proposedRegularAttachmentBytes;
          try {
            onAllowed();
          } catch (_) {
            releaseReservedBytes(
              allAttachmentBytes: request.sizes.proposedAllAttachmentBytes,
              regularAttachmentBytes: request.sizes.proposedRegularAttachmentBytes,
            );
            rethrow;
          }
        }
      } finally {
        completer.complete();
      }
    });
  }
}

/// Adds a [AttachmentUploadValidationService]'s in-flight reservation on top
/// of the real [AttachmentUploadStateSource] byte totals.
final class _ReservingStateSource implements AttachmentUploadStateSource {
  const _ReservingStateSource({required AttachmentUploadStateSource source, required AttachmentUploadValidationService service})
      : _source = source,
        _service = service;

  final AttachmentUploadStateSource _source;
  final AttachmentUploadValidationService _service;

  @override
  int get currentAllAttachmentBytes =>
      _source.currentAllAttachmentBytes + _service._reservedAllAttachmentBytes;

  @override
  int get currentRegularAttachmentBytes =>
      _source.currentRegularAttachmentBytes + _service._reservedRegularAttachmentBytes;

  @override
  int get warningLimitBytes => _source.warningLimitBytes;

  @override
  int? get hardLimitBytes => _source.hardLimitBytes;
}
