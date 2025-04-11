
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ThreadDetailCollapsedEmail extends StatefulWidget {

  final PresentationEmail presentationEmail;
  final PresentationMailbox? mailboxContain;
  final EdgeInsetsGeometry? padding;
  final OnPressEmailActionClick? emailActionClick;

  const ThreadDetailCollapsedEmail({
    super.key,
    required this.presentationEmail,
    this.mailboxContain,
    this.padding,
    this.emailActionClick,
  });

  @override
  State<ThreadDetailCollapsedEmail> createState() => _ThreadDetailCollapsedEmailState();
}

class _ThreadDetailCollapsedEmailState extends State<ThreadDetailCollapsedEmail>  with BaseEmailItemTile {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.emailActionClick?.call(
        EmailActionType.preview,
        widget.presentationEmail
      ),
      hoverColor: Theme.of(context).colorScheme.outline.withOpacity(0.08),
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      child: Container(
        padding: widget.padding ?? _getPaddingItem(context),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        child: Row(children: [
          buildIconAvatarText(
            widget.presentationEmail,
            iconSize: 32,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 160,
            child: buildInformationSender(
              context,
              widget.presentationEmail,
              widget.mailboxContain,
              false,
              SearchQuery.initial(),
            )
          ),
          const SizedBox(width: 24),
          Expanded(
            child: buildEmailPartialContent(
              context,
              widget.presentationEmail,
              false,
              SearchQuery.initial(),
            ),
          ),
          const SizedBox(width: 16),
          _buildDateTimeForDesktopScreen(context),
          const SizedBox(width: 16),
          buildIconWeb(
            icon: SvgPicture.asset(
              widget.presentationEmail.hasStarred
                ? imagePaths.icStar
                : imagePaths.icUnStar,
              width: 20,
              height: 20,
              fit: BoxFit.fill
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
            iconPadding: EdgeInsets.zero,
            minSize: 28,
            tooltip: widget.presentationEmail.hasStarred
              ? AppLocalizations.of(context).starred
              : AppLocalizations.of(context).not_starred,
            onTap: () => widget.emailActionClick?.call(
              widget.presentationEmail.hasStarred
                ? EmailActionType.unMarkAsStarred
                : EmailActionType.markAsStarred,
              widget.presentationEmail
            )
          ),
        ]),
      ),
    );
  }

  EdgeInsetsGeometry _getPaddingItem(BuildContext context) {
    if (responsiveUtils.isDesktop(context)) {
      return const EdgeInsets.symmetric(vertical: 4);
    } else if (responsiveUtils.isTablet(context)) {
      return const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 24);
    } else {
      return const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 12);
    }
  }

  Widget _buildDateTimeForDesktopScreen(BuildContext context) {
    return Row(children: [
      buildMailboxContain(context, false, widget.presentationEmail),
      if (widget.presentationEmail.hasAttachment == true)
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: buildIconAttachment()),
      Padding(
        padding: const EdgeInsetsDirectional.only(end: 20, start: 8),
        child: buildDateTime(context, widget.presentationEmail))
    ]);
  }
}