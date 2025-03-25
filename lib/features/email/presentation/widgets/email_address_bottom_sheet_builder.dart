import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_detail_widget.dart';

class EmailAddressBottomSheetBuilder extends StatelessWidget {
  final ImagePaths imagePaths;
  final EmailAddress emailAddress;
  final OnCloseDialogAction? onCloseDialogAction;
  final OnCopyEmailAddressDialogAction? onCopyEmailAddressAction;
  final OnComposeEmailDialogAction? onComposeEmailAction;
  final OnQuickCreatingRuleEmailDialogAction?
      onQuickCreatingRuleEmailDialogAction;

  const EmailAddressBottomSheetBuilder({
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(16.0),
          topEnd: Radius.circular(16.0),
        ),
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
      child: SafeArea(
        top: false,
        left: false,
        right: false,
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
