import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/indicator/custom_indicator.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/keyboard_shortcuts/widgets/keyboard_shortcuts_tab_view_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';

class KeyboardShortcutsView extends StatefulWidget {
  const KeyboardShortcutsView({Key? key}) : super(key: key);

  @override
  State<KeyboardShortcutsView> createState() => _KeyboardShortcutsViewState();
}

class _KeyboardShortcutsViewState extends State<KeyboardShortcutsView> {
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  late final CustomTabBarController _tabBarController;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabBarController = CustomTabBarController();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _responsiveUtils.isDesktop(context);

    return SettingDetailViewBuilder(
      responsiveUtils: _responsiveUtils,
      child: Container(
        color: SettingsUtils.getContentBackgroundColor(
          context,
          _responsiveUtils,
        ),
        decoration: SettingsUtils.getBoxDecorationForContent(
          context,
          _responsiveUtils,
        ),
        width: double.infinity,
        padding: isDesktop
            ? const EdgeInsets.symmetric(vertical: 30, horizontal: 22)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_responsiveUtils.isWebDesktop(context))
              SettingHeaderWidget(
                menuItem: AccountMenuItem.keyboardShortcuts,
                textStyle: ThemeUtils.textStyleInter600().copyWith(
                  color: Colors.black.withValues(alpha: 0.9),
                ),
                padding: EdgeInsets.zero,
              )
            else
              const SettingExplanationWidget(
                menuItem: AccountMenuItem.keyboardShortcuts,
                padding: EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  bottom: 16,
                ),
                isCenter: true,
                textAlign: TextAlign.center,
              ),
            Expanded(
              child: Padding(
                padding: SettingsUtils.getBodyPadding(
                  context,
                  _responsiveUtils,
                ),
                child: KeyboardShortcutsTabView(
                  tabBarController: _tabBarController,
                  pageController: _pageController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
