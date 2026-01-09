import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
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
    this.labels,
    this.onEmailActionClick,
    this.onToggleThreadDetailCollapseExpand,
    this.onDeleteLabelAction,
  });

  final PresentationEmail presentationEmail;
  final bool showSubject;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final OnOpenEmailAddressDetailAction? openEmailAddressDetailAction;
  final PresentationMailbox? mailboxContain;
  final EmailLoaded? emailLoaded;
  final OnEmailActionClick? onEmailActionClick;
  final List<Label>? labels;
  final VoidCallback? onToggleThreadDetailCollapseExpand;
  final OnDeleteLabelAction? onDeleteLabelAction;

  String get preview => presentationEmail.getPartialContent();

  @override
  Widget build(BuildContext context) {
    final isMobileResponsive = responsiveUtils.isMobile(context);

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
              EmailSubjectWidget(
                presentationEmail: presentationEmail,
                imagePaths: imagePaths,
                isMobileResponsive: isMobileResponsive,
                labels: labels,
                onDeleteLabelAction: onDeleteLabelAction,
              ),
            InformationSenderAndReceiverBuilder(
              emailSelected: presentationEmail,
              responsiveUtils: responsiveUtils,
              imagePaths: imagePaths,
              emailLoaded: emailLoaded,
              isInsideThreadDetailView: true,
              onEmailActionClick: onEmailActionClick,
              openEmailAddressDetailAction: openEmailAddressDetailAction,
              showRecipients: false,
              mailboxContain: mailboxContain,
              showUnreadVisualization: true,
              isInsideThreadCollapsed: true,
            ),
            Padding(
              padding: isMobileResponsive
                  ? const EdgeInsetsDirectional.only(
                      top: 12,
                      bottom: 21,
                      start: 12,
                      end: 12,
                    )
                  : const EdgeInsetsDirectional.only(
                      top: 8,
                      bottom: 24,
                      start: 16,
                      end: 16,
                    ),
              child: Text(
                preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _getPreviewTextStyle(isMobileResponsive),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getPreviewTextStyle(bool isMobileResponsive) {
    if (isMobileResponsive) {
      return presentationEmail.hasRead
          ? ThemeUtils.textStyleInter400.copyWith(
              color: Colors.black,
              fontSize: 16,
              height: 24 / 16,
              letterSpacing: -0.16,
            )
          : ThemeUtils.textStyleInter600().copyWith(
              color: Colors.black,
              fontSize: 16,
              height: 24 / 16,
              letterSpacing: -0.16,
            );
    } else {
      return presentationEmail.hasRead
          ? ThemeUtils.textStyleBodyBody3().copyWith(color: Colors.black)
          : ThemeUtils.textStyleBodyBody3().copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            );
    }
  }
}
