import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_detail_widget.dart';

typedef OnCloseDialogAction = void Function();
typedef OnCopyEmailAddressDialogAction = void Function(EmailAddress);
typedef OnComposeEmailDialogAction = void Function(EmailAddress);
typedef OnQuickCreatingRuleEmailDialogAction = void Function(EmailAddress);

class EmailAddressDialogBuilder extends StatelessWidget {
  final ImagePaths imagePaths;
  final EmailAddress emailAddress;
  final OnCloseDialogAction? onCloseDialogAction;
  final OnCopyEmailAddressDialogAction? onCopyEmailAddressAction;
  final OnComposeEmailDialogAction? onComposeEmailAction;
  final OnQuickCreatingRuleEmailDialogAction?
      onQuickCreatingRuleEmailDialogAction;

  const EmailAddressDialogBuilder({
    Key? key,
    required this.imagePaths,
    required this.emailAddress,
    this.onCloseDialogAction,
    this.onCopyEmailAddressAction,
    this.onComposeEmailAction,
    this.onQuickCreatingRuleEmailDialogAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Container(
        width: 383,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              spreadRadius: 3,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 3,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: EmailAddressDetailWidget(
          imagePaths: imagePaths,
          emailAddress: emailAddress,
          onCloseDialogAction: onCloseDialogAction,
          onCopyEmailAddressAction: onCopyEmailAddressAction,
          onComposeEmailAction: onComposeEmailAction,
          onQuickCreatingRuleEmailDialogAction:
              onQuickCreatingRuleEmailDialogAction,
        ),
      ),
    );
  }
}
