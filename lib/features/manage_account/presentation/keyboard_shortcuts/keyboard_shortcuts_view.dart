import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/custom_tab_bar.dart';
import 'package:flutter_custom_tab_bar/indicator/custom_indicator.dart';
import 'package:flutter_custom_tab_bar/indicator/linear_indicator.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/keyboard_shortcut_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/keyboard_shortcuts/widgets/shortcut_category_list_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/keyboard_shortcuts/widgets/shortcut_tab_bar_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcut.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcuts_manager.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class KeyboardShortcutsView extends StatefulWidget {
  const KeyboardShortcutsView({Key? key}) : super(key: key);

  @override
  State<KeyboardShortcutsView> createState() => _KeyboardShortcutsViewState();
}

class _KeyboardShortcutsViewState extends State<KeyboardShortcutsView> {
  static const double _desktopTabViewMaxWidth = 618;

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();
  final _categories = ShortcutCategory.values;

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
    final appLocalizations = AppLocalizations.of(context);
    final allShortcuts = KeyboardShortcutsManager.generateKeyboardShortcuts(
      appLocalizations,
    );
    final isDesktop = _responsiveUtils.isDesktop(context);
    double tabBarMaxHeight = isDesktop ? 52 : 82;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        final countCategories = _categories.length;

                        return Stack(
                          children: [
                            CustomTabBar(
                              tabBarController: _tabBarController,
                              height: tabBarMaxHeight,
                              width: isDesktop
                                  ? _desktopTabViewMaxWidth
                                  : maxWidth,
                              itemCount: countCategories,
                              builder: (_, index) {
                                final category = _categories[index];
                                return ShortcutTabBarWidget(
                                  index: index,
                                  label: category.getDisplayName(
                                    appLocalizations,
                                    isDesktop: isDesktop,
                                  ),
                                  icon: isDesktop
                                      ? null
                                      : category.getIcon(_imagePaths),
                                  width: isDesktop
                                      ? category.getTabWidth()
                                      : maxWidth / countCategories,
                                  height: tabBarMaxHeight,
                                );
                              },
                              indicator: LinearIndicator(
                                color: AppColor.primaryLinShare,
                                height: 1,
                                bottom: 0,
                              ),
                              pageController: _pageController,
                            ),
                            PositionedDirectional(
                              bottom: 0,
                              start: 0,
                              end: 0,
                              child: Divider(
                                color: Colors.black.withValues(alpha: 0.12),
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                    Expanded(
                      child: SizedBox(
                        width: isDesktop
                            ? _desktopTabViewMaxWidth
                            : double.infinity,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _categories.length,
                          physics: PlatformInfo.isMobile
                              ? const PageScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          itemBuilder: (_, index) {
                            final category = _categories[index];
                            final shortcutsByCategory = allShortcuts
                              .where((shortcut) => shortcut.category == category)
                              .toList();
                            return ShortcutCategoryList(
                              shortcutsByCategory: shortcutsByCategory,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
