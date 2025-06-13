import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_setting_menu_overlay.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class ProfileSettingIcon extends StatefulWidget {
  final String ownEmailAddress;
  final List<ProfileSettingActionType> settingActionTypes;
  final OnProfileSettingActionTypeClick onProfileSettingActionTypeClick;

  const ProfileSettingIcon({
    super.key,
    required this.ownEmailAddress,
    required this.settingActionTypes,
    required this.onProfileSettingActionTypeClick,
  });

  @override
  State<ProfileSettingIcon> createState() => _ProfileSettingIconState();
}

class _ProfileSettingIconState extends State<ProfileSettingIcon> {
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier<bool>(false);
  final _imagePaths = ImagePaths();
  final _appToast = AppToast();

  @override
  void dispose() {
    _isExpandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isExpandedNotifier,
      builder: (context, isExpanded, child) {
        return PortalTarget(
          visible: isExpanded,
          portalFollower: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleOpenMenu,
          ),
          child: PortalTarget(
            anchor: Aligned(
              follower: AppUtils.isDirectionRTL(context)
                  ? Alignment.topLeft
                  : Alignment.topRight,
              target: AppUtils.isDirectionRTL(context)
                  ? Alignment.bottomLeft
                  : Alignment.bottomRight,
              offset: const Offset(0, 8),
            ),
            portalFollower: ProfileSettingMenuOverlay(
              ownEmailAddress: widget.ownEmailAddress,
              settingActionTypes: widget.settingActionTypes,
              imagePaths: _imagePaths,
              onCopyButtonAction: () => _onCopyProfileNameAction(
                context,
                widget.ownEmailAddress,
              ),
              onProfileSettingActionTypeClick: (actionType) {
                _toggleOpenMenu();
                widget.onProfileSettingActionTypeClick(actionType);
              },
              onCloseProfileSettingMenuAction: _toggleOpenMenu,
            ),
            visible: isExpanded,
            child: (AvatarBuilder()
                  ..text(widget.ownEmailAddress.firstCharacterToUpperCase)
                  ..backgroundColor(Colors.white)
                  ..textColor(Colors.black)
                  ..context(context)
                  ..size(48)
                  ..addOnTapActionClick(_toggleOpenMenu)
                  ..addBoxShadows([
                    const BoxShadow(
                      color: AppColor.colorShadowBgContentEmail,
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(0, 0.5),
                    )
                  ]))
                .build(),
          ),
        );
      },
    );
  }

  void _toggleOpenMenu() {
    _isExpandedNotifier.value = !_isExpandedNotifier.value;
  }

  void _onCopyProfileNameAction(BuildContext context, String profileName) {
    Clipboard.setData(ClipboardData(text: profileName));
    _appToast.showToastSuccessMessage(
      context,
      AppLocalizations.of(context).email_address_copied_to_clipboard,
    );
  }
}
