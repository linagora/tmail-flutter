
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:model/user/user_profile.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/app_bar/mobile_app_bar_thread_widget_style.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/app_bar_thread_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MobileAppBarThreadWidget extends StatelessWidget {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final PresentationMailbox? mailboxSelected;
  final UserProfile? userProfile;
  final List<PresentationEmail> listEmailSelected;
  final SelectMode selectMode;
  final FilterMessageOption filterOption;
  final OnOpenMailboxMenuActionClick openMailboxAction;
  final OnEditThreadAction editThreadAction;
  final OnCancelEditThreadAction cancelEditThreadAction;

  MobileAppBarThreadWidget({
    super.key,
    required this.listEmailSelected,
    required this.userProfile,
    required this.mailboxSelected,
    required this.selectMode,
    required this.filterOption,
    required this.openMailboxAction,
    required this.editThreadAction,
    required this.cancelEditThreadAction,
  });

  @override
  Widget build(BuildContext context) {
    Widget? child;
    
    if (selectMode == SelectMode.INACTIVE) {
      child = Row(
        children: [
          TMailButtonWidget.fromIcon(
            key: const Key('mailbox_menu_button'),
            icon: _imagePaths.icMailboxMenu,
            backgroundColor: Colors.transparent,
            tooltipMessage: AppLocalizations.of(context).openFolderMenu,
            onTapActionCallback: openMailboxAction,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      mailboxSelected?.getDisplayName(context) ?? '',
                      maxLines: 1,
                      overflow: CommonTextStyle.defaultTextOverFlow,
                      softWrap: CommonTextStyle.defaultSoftWrap,
                      style: Theme.of(context).textTheme.titleLarge
                    )
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8, bottom: 4),
                    child: Text(
                      filterOption.getTitle(context),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: AppColor.colorContentEmail
                      )
                    ),
                  )
                ],
              ),
            ),
          ),
          AvatarBuilder(
            text: userProfile?.getAvatarText() ?? '',
            size: 40,
            textColor: Colors.black,
            bgColor: Colors.white,
            boxShadows: const [
              BoxShadow(
                color: AppColor.colorShadowBgContentEmail,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 0.5)
              )
            ]
          ),
        ],
      );
    } else {
      child = const SizedBox.shrink();
    }
    
    return Container(
      color: Colors.white,
      padding: MobileAppBarThreadWidgetStyle.getPadding(context, _responsiveUtils),
      constraints: const BoxConstraints(minHeight: MobileAppBarThreadWidgetStyle.minHeight),
      child: child,
    );
  }
}
