
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/extensions/locale_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/language_menu_overlay.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ChangeLanguageButtonWidget extends StatelessWidget {

  final _controller = Get.find<LanguageAndRegionController>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  ChangeLanguageButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleLanguageWidget(context),
              const SizedBox(height: 8),
              _buildLanguageMenu(context, constraints.maxWidth)
            ]
          )
        ),
        desktop: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleLanguageWidget(context),
            const SizedBox(height: 8),
            SizedBox(
              width: constraints.maxWidth / 2,
              child: _buildLanguageMenu(context, constraints.maxWidth / 2)
            ),
          ]
        )
      );
    });
  }

  Widget _buildTitleLanguageWidget(BuildContext context) {
    return Text(
      AppLocalizations.of(context).language,
      style: ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColor.colorContentEmail
      )
    );
  }

  Widget _buildLanguageMenu(BuildContext context, double maxWidth) {
    return Obx(() => PortalTarget(
      visible: _controller.isLanguageMenuOverlayOpen.isTrue,
      portalFollower: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _controller.toggleLanguageMenuOverlay()
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
          listSupportedLanguages: _controller.listSupportedLanguages,
          localeSelected: _controller.languageSelected.value,
          maxWidth: maxWidth,
          onSelectLanguageAction: _controller.selectLanguage,
        )),
        visible: _controller.isLanguageMenuOverlayOpen.isTrue,
        child: _buildDropDownMenuButton(context, maxWidth)
      )
    ));
  }

  Widget _buildDropDownMenuButton(BuildContext context, double maxWidth) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _controller.toggleLanguageMenuOverlay(),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
          height: 44,
          width: maxWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColor.colorInputBorderCreateMailbox,
              width: 0.5,
            ),
            color: AppColor.colorItemSelected,
          ),
          padding: const EdgeInsetsDirectional.only(start: 12, end: 10),
          child: Row(children: [
            Expanded(child: Text(
              _controller.languageSelected.value.getLanguageNameByCurrentLocale(context),
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black
              ),
              maxLines: 1,
              softWrap: CommonTextStyle.defaultSoftWrap,
              overflow: CommonTextStyle.defaultTextOverFlow,
            )),
            SvgPicture.asset(_imagePaths.icDropDown)
          ]),
        ),
      ),
    );
  }
}