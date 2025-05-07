import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/icon_utils.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/email_avatar_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_sender_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_subject_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_app_bar_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/received_time_builder.dart';

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
  });

  final PresentationEmail presentationEmail;
  final bool showSubject;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final OnOpenEmailAddressDetailAction? openEmailAddressDetailAction;
  final PresentationMailbox? mailboxContain;
  final EmailLoaded? emailLoaded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColor.colorDividerEmailView,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSubject)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: EmailSubjectWidget(presentationEmail: presentationEmail),
            ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                EmailAvatarBuilder(emailSelected: presentationEmail),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          EmailSenderBuilder(
                            emailAddress: presentationEmail.from!.first,
                            openEmailAddressDetailAction: openEmailAddressDetailAction,
                            showSenderEmail: false,
                          ),
                          if (presentationEmail.hasAttachment == true
                              && !responsiveUtils.isMobile(context))
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 16),
                              child: SvgPicture.asset(
                                imagePaths.icAttachment,
                                width: 16,
                                height: 16,
                                colorFilter: AppColor.steelGray200.asFilter(),
                                fit: BoxFit.fill,
                              ),
                            ),
                          if (!responsiveUtils.isMobile(context))
                            ReceivedTimeBuilder(emailSelected: presentationEmail),
                          Expanded(
                            child: EmailViewAppBarWidget(
                              key: const Key('email_view_app_bar_widget'),
                              presentationEmail: presentationEmail,
                              mailboxContain: mailboxContain,
                              isSearchActivated: false,
                              onBackAction: () {},
                              onEmailActionClick: (email, action) {
                                // TODO: Next PR
                              },
                              onMoreActionClick: (presentationEmail, position) {
                                // TODO: Next PR
                              },
                              optionsWidget: null,
                              supportBackAction: false,
                              appBarDecoration: const BoxDecoration(),
                              emailLoaded: emailLoaded,
                              replacePrintActionWithReplyAction: true,
                              height: IconUtils.defaultIconSize,
                              iconPadding: EdgeInsets.zero,
                              iconMargin: const EdgeInsetsDirectional.only(start: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ],
                      ),
                      if (responsiveUtils.isMobile(context))
                        ReceivedTimeBuilder(
                          emailSelected: presentationEmail,
                          padding: const EdgeInsetsDirectional.only(start: 2),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextOverflowBuilder(
              presentationEmail.getPartialContent(),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
