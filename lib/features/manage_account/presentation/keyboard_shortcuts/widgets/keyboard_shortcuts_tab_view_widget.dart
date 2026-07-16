import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/custom_tab_bar.dart';
import 'package:flutter_custom_tab_bar/indicator/custom_indicator.dart';
import 'package:flutter_custom_tab_bar/indicator/linear_indicator.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/keyboard_shortcut_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/keyboard_shortcuts/widgets/shortcut_category_list_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/keyboard_shortcuts/widgets/shortcut_tab_bar_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcut.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcuts_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Category tab bar plus its paged shortcut lists, sharing controllers and RTL handling.
class KeyboardShortcutsTabView extends StatelessWidget {
  static const double _tabViewMaxWidth = 618;
  static const double _rowMaxWidth = 440;

  final CustomTabBarController tabBarController;
  final PageController pageController;

  KeyboardShortcutsTabView({
    super.key,
    required this.tabBarController,
    required this.pageController,
  });

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();
  final _categories = ShortcutCategory.values;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _responsiveUtils.isDesktop(context);
    final ambientTextDirection = Directionality.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabBar(context, isDesktop, ambientTextDirection),
        Expanded(
          child: _buildPageView(context, isDesktop, ambientTextDirection),
        ),
      ],
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    bool isDesktop,
    TextDirection ambientTextDirection,
  ) {
    final appLocalizations = AppLocalizations.of(context);
    final tabBarHeight = isDesktop ? 52.0 : 82.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final countCategories = _categories.length;

        return Stack(
          children: [
            // CustomTabBar has no RTL support; pin to LTR, restore item direction.
            Directionality(
              textDirection: TextDirection.ltr,
              child: CustomTabBar(
                tabBarController: tabBarController,
                height: tabBarHeight,
                width: isDesktop ? _tabViewMaxWidth : maxWidth,
                itemCount: countCategories,
                builder: (_, index) {
                  final category = _categories[index];
                  return Directionality(
                    textDirection: ambientTextDirection,
                    child: ShortcutTabBarWidget(
                      index: index,
                      label: category.getDisplayName(
                        appLocalizations,
                        isDesktop: isDesktop,
                      ),
                      icon: isDesktop ? null : category.getIcon(_imagePaths),
                      width: isDesktop
                          ? category.getTabWidth()
                          : maxWidth / countCategories,
                      height: tabBarHeight,
                    ),
                  );
                },
                indicator: LinearIndicator(
                  color: AppColor.primaryLinShare,
                  height: 1,
                  bottom: 0,
                ),
                pageController: pageController,
              ),
            ),
            PositionedDirectional(
              bottom: 0,
              start: 0,
              end: 0,
              child: Divider(color: Colors.black.withValues(alpha: 0.12)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageView(
    BuildContext context,
    bool isDesktop,
    TextDirection ambientTextDirection,
  ) {
    final allShortcuts = KeyboardShortcutsManager.generateKeyboardShortcuts(
      AppLocalizations.of(context),
    );

    return SizedBox(
      width: isDesktop ? _tabViewMaxWidth : double.infinity,
      // Match the LTR-pinned tab bar; restore page content direction.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PageView.builder(
          controller: pageController,
          itemCount: _categories.length,
          // Align swipe gesture with the responsive layout breakpoint.
          physics: isDesktop
              ? const NeverScrollableScrollPhysics()
              : const PageScrollPhysics(),
          itemBuilder: (_, index) {
            final category = _categories[index];
            final shortcutsByCategory = allShortcuts
                .where((shortcut) => shortcut.category == category)
                .toList();
            return Directionality(
              textDirection: ambientTextDirection,
              child: ShortcutCategoryList(
                shortcutsByCategory: shortcutsByCategory,
                rowMaxWidth: isDesktop ? _rowMaxWidth : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
