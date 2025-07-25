import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_edit_recipients_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/desktop_edit_recipients_view.dart';

class EditRecipientsView extends StatelessWidget {
  final EmailAddress emailAddress;
  final ImagePaths imagePaths;
  final bool isMobile;
  final double width;
  final VoidCallback onCopyAction;
  final VoidCallback onEditAction;
  final VoidCallback onCreateRuleAction;
  final VoidCallback onCloseAction;

  const EditRecipientsView({
    super.key,
    required this.emailAddress,
    required this.imagePaths,
    required this.isMobile,
    required this.width,
    required this.onCopyAction,
    required this.onEditAction,
    required this.onCreateRuleAction,
    required this.onCloseAction,
  });

  @override
  Widget build(BuildContext context) {
   if (isMobile) {
     return MobileEditRecipientsView(
       emailAddress: emailAddress,
       imagePaths: imagePaths,
       width: width,
       onCopyAction: onCopyAction,
       onEditAction: onEditAction,
       onCreateRuleAction: onCreateRuleAction,
     );
   } else {
     return DesktopEditRecipientsView(
       emailAddress: emailAddress,
       imagePaths: imagePaths,
       width: width,
       onCopyAction: onCopyAction,
       onEditAction: onEditAction,
       onCreateRuleAction: onCreateRuleAction,
       onCloseAction: onCloseAction,
     );
   }
  }
}
