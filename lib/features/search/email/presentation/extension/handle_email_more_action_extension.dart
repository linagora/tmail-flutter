import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/context_item_email_action.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension HandleEmailMoreActionExtension on SearchEmailController {
  void handleEmailMoreAction(
    BuildContext context,
    PresentationEmail presentationEmail,
    RelativeRect? position,
  ) {
    final mailboxContain = presentationEmail.mailboxContain;

    final listEmailActions = [
      mailboxContain?.isSpam == true
          ? EmailActionType.unSpam
          : EmailActionType.moveToSpam,
      if (mailboxContain?.isDrafts == false) EmailActionType.editAsNewEmail,
    ];

    if (listEmailActions.isEmpty) return;

    if (responsiveUtils.isScreenWithShortestSide(context)) {
      final contextMenuActions = listEmailActions
          .map((action) => ContextItemEmailAction(
                action,
                AppLocalizations.of(context),
                imagePaths,
              ))
          .toList();

      openBottomSheetContextMenuAction(
        context: context,
        itemActions: contextMenuActions,
        onContextMenuActionClick: (menuAction) {
          pressEmailAction(
            context,
            menuAction.action,
            presentationEmail,
          );
        },
      );
    } else {
      final popupMenuEntries = listEmailActions
          .map((actionType) => PopupMenuItem(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildPopupMenuAction(
                  context,
                  presentationEmail,
                  actionType,
                ),
              ))
          .toList();
      openPopupMenuAction(
        context,
        position,
        popupMenuEntries,
      );
    }
  }

  Widget _buildPopupMenuAction(
    BuildContext context,
    PresentationEmail presentationEmail,
    EmailActionType emailActionType,
  ) {
    return (EmailActionCupertinoActionSheetActionBuilder(
      Key(emailActionType.name),
      SvgPicture.asset(emailActionType.getIcon(imagePaths),
          width: 28,
          height: 28,
          fit: BoxFit.fill,
          colorFilter: AppColor.colorTextButton.asFilter()),
      emailActionType.getTitle(AppLocalizations.of(context)),
      presentationEmail,
      iconLeftPadding: responsiveUtils.isMobile(context)
          ? const EdgeInsetsDirectional.only(start: 12, end: 16)
          : const EdgeInsetsDirectional.only(end: 12),
      iconRightPadding: responsiveUtils.isMobile(context)
          ? const EdgeInsetsDirectional.only(end: 12)
          : EdgeInsets.zero,
    )..onActionClick((email) => pressEmailAction(
              context,
              emailActionType,
              email,
            )))
        .build();
  }
}
