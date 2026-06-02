import 'package:core/utils/app_logger.dart';
import 'package:drive_attachment/drive_attachment/domain/entity/drive_attachment.dart';
import 'package:drive_attachment/drive_attachment/domain/entity/drive_document.dart';
import 'package:drive_attachment/drive_attachment/domain/state/drive_intent_state.dart';
import 'package:drive_attachment/drive_attachment/domain/usecase/create_drive_intent_interactor.dart';
import 'package:drive_attachment/drive_attachment/presentation/notifier/drive_attachment_state.dart';
import 'package:drive_attachment/drive_attachment/presentation/provider/drive_attachment_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DriveAttachmentNotifier extends Notifier<DriveAttachmentState> {
  final String composerId;
  late CreateDriveIntentInteractor _createIntentInteractor;

  DriveAttachmentNotifier(this.composerId);

  @override
  DriveAttachmentState build() {
    _createIntentInteractor = ref.read(createDriveIntentInteractorProvider);
    return const DriveAttachmentIdle();
  }

  Future<void> openDrivePicker({
    required Uri platformUrl,
    required String accessToken,
  }) async {
    final current = state.attachments;
    state = DriveAttachmentFetchingIntent(attachments: current);

    await for (final either
        in _createIntentInteractor.execute(platformUrl, accessToken)) {
      either.fold(
        (failure) {
          if (failure is CreateDriveIntentFailure) {
            log('DriveAttachmentNotifier: create intent failed: ${failure.exception}');
          }
          state = DriveAttachmentError(error: failure, attachments: current);
        },
        (success) {
          if (success is CreateDriveIntentSuccess) {
            state = DriveIntentPending(
              intent: success.intent,
              attachments: current,
            );
          }
        },
      );
    }
  }

  void onPickResult(List<DriveDocument>? result) {
    final current = state.attachments;
    if (result == null || result.isEmpty) {
      state = DriveAttachmentIdle(attachments: current);
      return;
    }
    final valid = result
        .where((doc) => doc.attachmentUrl != null)
        .map((doc) => DriveAttachment(document: doc))
        .toList();

    if (valid.length < result.length) {
      log('DriveAttachmentNotifier: ${result.length - valid.length} doc(s) skipped — no valid URL');
    }
    state = DriveAttachmentIdle(attachments: [...current, ...valid]);
  }

  void remove(DriveAttachment attachment) {
    final updated = state.attachments.where((a) => a != attachment).toList();
    state = DriveAttachmentIdle(attachments: updated);
  }

  void clear() {
    state = const DriveAttachmentIdle();
  }
}

final driveAttachmentNotifierProvider = NotifierProvider.family<
    DriveAttachmentNotifier, DriveAttachmentState, String>(
  (composerId) => DriveAttachmentNotifier(composerId),
);
