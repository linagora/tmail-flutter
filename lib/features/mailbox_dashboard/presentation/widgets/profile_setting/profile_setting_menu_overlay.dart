import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/copy_subaddress_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/popup_menu_item_profile_setting_type_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_label_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnProfileSettingActionTypeClick = void Function(
    ProfileSettingActionType);
typedef OnCloseProfileSettingMenuAction = void Function();

class ProfileSettingMenuOverlay extends StatelessWidget {
  final String ownEmailAddress;
  final List<ProfileSettingActionType> settingActionTypes;
  final ImagePaths imagePaths;
  final OnCopyButtonAction onCopyButtonAction;
  final OnProfileSettingActionTypeClick onProfileSettingActionTypeClick;
  final OnCloseProfileSettingMenuAction onCloseProfileSettingMenuAction;

  const ProfileSettingMenuOverlay({
    Key? key,
    required this.ownEmailAddress,
    required this.settingActionTypes,
    required this.imagePaths,
    required this.onCopyButtonAction,
    required this.onProfileSettingActionTypeClick,
    required this.onCloseProfileSettingMenuAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                ProfileLabelWidget(
                  label: ownEmailAddress,
                  copyLabelIcon: imagePaths.icCopy,
                  onCopyButtonAction: onCopyButtonAction,
                ),
                const SizedBox(height: 4),
                Divider(
                  color: AppColor.profileMenuDivider.withValues(alpha: 0.12),
                  height: 1,
                ),
                ...settingActionTypes
                    .map((actionType) => PopupMenuItemActionWidget(
                          menuAction: PopupMenuItemProfileSettingTypeAction(
                            actionType,
                            AppLocalizations.of(context),
                            imagePaths,
                          ),
                          menuActionClick: (menuAction) {
                            onProfileSettingActionTypeClick(menuAction.action);
                          },
                        ))
                    .toList(),
                const SizedBox(height: 8),
              ],
            ),
            PositionedDirectional(
              top: 6,
              end: 6,
              child: TMailButtonWidget.fromIcon(
                icon: imagePaths.icComposerClose,
                iconSize: 22,
                iconColor: AppColor.m3Tertiary,
                padding: const EdgeInsets.all(4),
                borderRadius: 24,
                backgroundColor: Colors.transparent,
                onTapActionCallback: onCloseProfileSettingMenuAction,
              ),
            )
          ],
        ),
      ),
    );
  }
}
