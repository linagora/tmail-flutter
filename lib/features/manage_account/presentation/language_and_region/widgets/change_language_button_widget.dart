
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/tmail_drop_down_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/extensions/locale_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/language_menu_overlay.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ChangeLanguageButtonWidget extends StatefulWidget {

  const ChangeLanguageButtonWidget({Key? key}) : super(key: key);

  @override
  State<ChangeLanguageButtonWidget> createState() => _ChangeLanguageButtonWidgetState();
}

class _ChangeLanguageButtonWidgetState extends State<ChangeLanguageButtonWidget> {

  final _languageAndRegionController = Get.find<LanguageAndRegionController>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  final ValueNotifier<bool> _languageMenuIsVisibleNotifier =
    ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    if (_responsiveUtils.isDesktop(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleLanguageWidget(context),
          const SizedBox(height: 15),
          SizedBox(
            width: 385,
            child: _buildLanguageMenu(context, 385),
          ),
        ],
      );
    } else {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleLanguageWidget(context),
            const SizedBox(height: 8),
            _buildLanguageMenu(context, double.infinity),
          ],
        ),
      );
    }
  }

  Widget _buildTitleLanguageWidget(BuildContext context) {
    return Text(
      AppLocalizations.of(context).language,
      style: ThemeUtils.textStyleInter400.copyWith(
        fontSize: 14,
        height: 21.01 / 14,
        letterSpacing: -0.15,
        color: AppColor.gray424244.withOpacity(0.64),
      ),
    );
  }

  Widget _buildLanguageMenu(BuildContext context, double maxWidth) {
    return ValueListenableBuilder<bool>(
      valueListenable: _languageMenuIsVisibleNotifier,
      builder: (context, isVisible, child) {
        return PortalTarget(
          visible: isVisible,
          portalFollower: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleLanguageMenuOverlay(false),
          ),
          child: PortalTarget(
            anchor: const Aligned(
              follower: Alignment.topRight,
              target: Alignment.bottomRight,
              widthFactor: 1,
              backup: Aligned(
                follower: Alignment.topRight,
                target: Alignment.bottomRight,
                widthFactor: 1,
              ),
            ),
            portalFollower: Obx(() => LanguageRegionOverlay(
              imagePaths: _imagePaths,
              responsiveUtils: _responsiveUtils,
              listSupportedLanguages: _languageAndRegionController.listSupportedLanguages,
              localeSelected: _languageAndRegionController.languageSelected.value,
              maxWidth: maxWidth,
              onSelectLanguageAction: (language) {
                _toggleLanguageMenuOverlay(false);
                _languageAndRegionController.selectLanguage(language);
              },
            )),
            visible: isVisible,
            child: TMailDropDownWidget(
              text: _languageAndRegionController
                .languageSelected
                .value
                .getLanguageNameByCurrentLocale(context),
              dropDownIcon: _imagePaths.icDropDown,
              backgroundColor: isVisible
                ? AppColor.lightGrayEBEDF0.withOpacity(0.6)
                : null,
              onTap: () => _toggleLanguageMenuOverlay(true),
            )
          )
        );
      }
    );
  }

  void _toggleLanguageMenuOverlay(bool visible) {
    _languageMenuIsVisibleNotifier.value = visible;
  }

  @override
  void dispose() {
    _languageMenuIsVisibleNotifier.dispose();
    super.dispose();
  }
}