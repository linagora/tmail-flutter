import 'dart:ui';

import 'package:core/utils/app_logger.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_label_action_type_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/presentation_label_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleNavigationExtension on MailboxController {
  void handleLabelNavigation(NavigationRouter router, Id labelId) {
    if (!_isLabelCapabilityValid()) {
      _navigateToUnknown();
      return;
    }

    if (!_isLabelsReady()) {
      _waitForLabelsLoaded(() {
        _handleLabelNavigationInternal(router, labelId);
      });
      return;
    }

    _handleLabelNavigationInternal(router, labelId);
  }

  bool _isLabelCapabilityValid() {
    return mailboxDashBoardController.isLabelCapabilitySupported;
  }

  bool _isLabelsReady() {
    return mailboxDashBoardController.labelController.isLabelsLoaded.value;
  }

  void _waitForLabelsLoaded(VoidCallback onLoaded) {
    isLabelsLoadedWorker?.dispose();
    isLabelsLoadedWorker = null;

    final observable = mailboxDashBoardController.labelController.isLabelsLoaded;

    if (observable.value) {
      onLoaded();
      return;
    }

    isLabelsLoadedWorker = ever(
      observable,
      (isLoaded) {
        try {
          if (!isLoaded) return;
          _completeLabelsLoaded(onLoaded);
        } catch (e) {
          logWarning('HandleNavigationExtension::_waitForLabelsLoaded: Exception: $e');
        }
      },
    );
  }

  void _completeLabelsLoaded(VoidCallback onLoaded) {
    final worker = isLabelsLoadedWorker;
    if (worker == null) return;

    isLabelsLoadedWorker = null;
    worker.dispose();

    if (!isClosed) {
      onLoaded();
    }
  }

  void _handleLabelNavigationInternal(
    NavigationRouter router,
    Id labelId,
  ) {
    final matchedLabel = mailboxDashBoardController.getLabelById(labelId);

    if (matchedLabel == null) {
      _navigateToUnknown();
      return;
    }

    final labelMailbox = PresentationLabelMailbox.initial(matchedLabel);

    if (router.emailId != null) {
      openEmailInsideMailboxFromLocationBar(
        labelMailbox,
        router.emailId!,
      );
    } else {
      openMailboxFromLocationBar(labelMailbox);
    }

    mailboxDashBoardController.scrollToLabelListView();
  }

  void _navigateToUnknown() {
    clearNavigationRouter();
    popAndPush(AppRoutes.unknownRoutePage);
  }
}
