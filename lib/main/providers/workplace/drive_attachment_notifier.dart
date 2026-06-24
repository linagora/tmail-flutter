import 'package:core/utils/app_logger.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/state/workplace_intent_state.dart';
import 'package:workplace/domain/usecase/create_drive_intent_interactor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:workplace/presentation/notifier/drive_attachment_state.dart';
import 'drive_attachment_providers.dart';

part 'drive_attachment_notifier.g.dart';

@Riverpod(keepAlive: true)
class DriveAttachmentNotifier extends _$DriveAttachmentNotifier {
  late CreateDriveIntentInteractor _createIntentInteractor;

  @override
  DriveAttachmentState build(String composerId) {
    _createIntentInteractor = ref.read(createDriveIntentInteractorProvider);
    return const DriveAttachmentIdle();
  }

  Future<void> openDrivePicker({
    required Uri platformUrl,
    required String accessToken,
    required String addAsLink,
    required String addAsAttachment,
  }) async {
    final current = state.attachments;
    state = DriveAttachmentFetchingIntent(attachments: current);

    await for (final either in _createIntentInteractor.execute(
      platformUrl,
      accessToken,
      addAsLink: addAsLink,
      addAsAttachment: addAsAttachment,
    )) {
      either.fold(
        (failure) {
          if (failure is CreateWorkplaceIntentFailure) {
            log(
              'DriveAttachmentNotifier: create intent failed: ${failure.exception}',
            );
          }
          state = DriveAttachmentError(error: failure, attachments: current);
        },
        (success) {
          if (success is CreateWorkplaceIntentSuccess) {
            state = DriveIntentPending(
              intent: success.intent,
              attachments: current,
            );
          }
        },
      );
    }
  }

  void addSharingLinkDoc(DriveDocument doc) {
    final updated = [...state.attachments, doc];
    state = DriveAttachmentIdle(attachments: updated);
  }

  void clear() {
    state = const DriveAttachmentIdle();
  }
}
