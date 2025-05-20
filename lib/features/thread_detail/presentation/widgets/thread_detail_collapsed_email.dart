import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_sender_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_subject_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_app_bar_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/information_sender_and_receiver_builder.dart';

class ThreadDetailCollapsedEmail extends StatelessWidget {
  const ThreadDetailCollapsedEmail({
    super.key,
    required this.presentationEmail,
    required this.showSubject,
    required this.imagePaths,
    required this.responsiveUtils,
    this.openEmailAddressDetailAction,
    this.mailboxContain,
    this.emailLoaded,
    this.onEmailActionClick,
    this.onMoreActionClick,
    this.onToggleThreadDetailCollapseExpand,
  });

  final PresentationEmail presentationEmail;
  final bool showSubject;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final OnOpenEmailAddressDetailAction? openEmailAddressDetailAction;
  final PresentationMailbox? mailboxContain;
  final EmailLoaded? emailLoaded;
  final OnEmailActionClick? onEmailActionClick;
  final OnMoreActionClick? onMoreActionClick;
  final VoidCallback? onToggleThreadDetailCollapseExpand;

  String get preview => presentationEmail.getPartialContent();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColor.colorDividerEmailView,
            width: 0.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: onToggleThreadDetailCollapseExpand,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSubject)
              EmailSubjectWidget(presentationEmail: presentationEmail),
            const SizedBox(height: 16),
            InformationSenderAndReceiverBuilder(
              emailSelected: presentationEmail,
              responsiveUtils: responsiveUtils,
              imagePaths: imagePaths,
              emailLoaded: emailLoaded,
              isInsideThreadDetailView: true,
              onEmailActionClick: onEmailActionClick,
              onMoreActionClick: onMoreActionClick,
              openEmailAddressDetailAction: openEmailAddressDetailAction,
              showRecipients: false,
              onTapAvatarActionClick: onToggleThreadDetailCollapseExpand,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SelectionArea(
                child: TextOverflowBuilder(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
