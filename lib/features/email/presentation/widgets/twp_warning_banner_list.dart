import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/providers/twp_warning_dismiss_notifier.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/twp_warning_banner.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

/// Renders the backend-positioned `X-TWP-Message` warnings of the currently
/// displayed email as stacked banners between the header section and the body.
///
/// GetX reactivity (the loaded email + connectivity) is provided by the outer
/// [Obx]; the per-email dismissed set is provided by the inner [Consumer] via
/// [twpWarningDismissProvider]. A warning is hidden when it was dismissed this
/// session (notifier) or persisted as dismissed (keyword on the email).
class TwpWarningBannerList extends StatelessWidget {
  final SingleEmailController controller;

  const TwpWarningBannerList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final email = controller.currentEmail;
      final emailId = email?.id;
      final warnings =
          controller
              .currentEmailLoaded
              .value
              ?.emailCurrent
              ?.headers
              .twpWarnings ??
          const <TwpWarning>[];
      // Read inside Obx so the banner reacts to connectivity changes.
      final isOnline = controller.isNetworkConnectionAvailable;

      if (email == null || emailId == null || warnings.isEmpty) {
        return const SizedBox.shrink();
      }

      return Consumer(
        builder: (context, ref, _) {
          final dismissedLocally = ref.watch(
            twpWarningDismissProvider(emailId.asString),
          );

          final visibleWarnings = warnings
              .where(
                (warning) =>
                    !dismissedLocally.contains(warning.index) &&
                    !email.isTwpWarningDismissed(warning.index),
              )
              .toList();

          if (visibleWarnings.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: visibleWarnings
                .map(
                  (warning) => TwpWarningBanner(
                    warning: warning,
                    isDismissable: isOnline,
                    imagePaths: controller.imagePaths,
                    onDismissAction: (index) =>
                        _onDismiss(context, ref, emailId, index),
                  ),
                )
                .toList(),
          );
        },
      );
    });
  }

  Future<void> _onDismiss(
    BuildContext context,
    WidgetRef ref,
    EmailId emailId,
    int index,
  ) async {
    final session = controller.session;
    final accountId = controller.accountId;
    if (session == null || accountId == null) return;

    // Dismissal persists a keyword to the backend, so it is disabled offline.
    if (!controller.isNetworkConnectionAvailable) return;

    // Optimistically mirror the dismissal onto the in-memory email so the banner
    // hides immediately and stays hidden across reopen, before the backend
    // confirms. Reverted below if persistence fails.
    controller.markTwpWarningDismissedLocally(index);

    final result = await ref
        .read(twpWarningDismissProvider(emailId.asString).notifier)
        .dismiss(session, accountId, emailId, index);

    switch (result) {
      case TwpWarningDismissResult.dismissed:
        break;
      case TwpWarningDismissResult.failed:
        controller.clearTwpWarningDismissedLocally(index);
        if (context.mounted) {
          ref
              .read(appToastProvider)
              .showToastErrorMessage(
                context,
                AppLocalizations.of(context).an_error_occurred,
              );
        }
      case TwpWarningDismissResult.urgentHandled:
        // Central handler already owns the UX (re-login, etc.); no extra toast.
        controller.clearTwpWarningDismissedLocally(index);
    }
  }
}
