import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

/// Explains that sending is refused until the email domain is activated.
class DomainActivationPendingDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const DomainActivationPendingDialog({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    // Keeps taps on the dialog away from the composer's HTML editor on web.
    return PointerInterceptor(
      child: LinagoraDialog(
        title: appLocalizations.domainActivationPendingTitle,
        message: appLocalizations.domainActivationPendingMessage,
        onClose: onDismiss,
        closeTooltip: appLocalizations.close,
        primaryAction: LinagoraDialogAction(
          label: appLocalizations.got_it,
          onPressed: onDismiss,
        ),
      ),
    );
  }
}

Future<void> showDomainActivationPendingDialog() => Get.dialog(
      const DomainActivationPendingDialog(onDismiss: popBack),
      barrierColor: LinagoraDialogStyle.barrierColor,
    );
