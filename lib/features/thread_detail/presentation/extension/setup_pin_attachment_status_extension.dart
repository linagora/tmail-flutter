import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/loader_status.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension SetupPinAttachmentStatusExtension on ThreadDetailController {
  void getPinAttachmentsStatus() {
    consumeState(getPinAttachmentStatusInteractor.execute());
  }

  void updatePinAttachmentsStatus(bool isEnabled) {
    isAttachmentsPinEnabled.value = isEnabled;
  }

  void triggerAppState() {
    appLifecycleListener ??= AppLifecycleListener(
      onResume: () {
        if (pinAttachmentsLoaderStatus == LoaderStatus.loading) {
          return;
        }
        getPinAttachmentsStatus();
      },
    );
  }

  void updatePinAttachmentsLoaderStatus(LoaderStatus loaderStatus) {
    pinAttachmentsLoaderStatus = loaderStatus;
  }
}
