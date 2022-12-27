import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_menu_widget_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/identities_radio_list_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/identities_radio_list_builder_web.dart' as identities_listview_web;

class IdentitiesView extends GetWidget<IdentitiesController> with PopupMenuWidgetMixin, AppLoaderMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  IdentitiesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: _responsiveUtils, 
      mobile: _buildIdentitiesViewMobile(context),
      tablet: _buildIdentitiesViewMobile(context),
      desktop: _buildIdentitiesViewWeb(context),
      tabletLarge: _buildIdentitiesViewMobile(context),
    );
  }

  Widget _buildIdentitiesViewMobile(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
          for(Widget item in _buildIdentitiesTitles(context))
            item,
          _buildCreateIdentityButton(context),
          IdentitiesRadioListBuilder(controller: controller),
        ],
      ),
    );
  }

  Widget _buildIdentitiesViewWeb(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 236,
            padding: const EdgeInsets.only(right: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for(Widget widget in _buildIdentitiesTitles(context))
                  widget,
                _buildCreateIdentityButton(context),
              ],
            ),
          ),
          Expanded(
            child: identities_listview_web.IdentitiesRadioListBuilder(controller: controller),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIdentitiesTitles(BuildContext context) {
    return [
      Text(
        AppLocalizations.of(context).identities.inCaps, 
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 17,
          color: Colors.black)),
      const SizedBox(height: 4.0),
      Text(
        AppLocalizations.of(context).identities_description,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColor.colorSettingExplanation),
        ),
      const SizedBox(height: 12.0),
    ];
  }

  Widget _buildCreateIdentityButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: (ButtonBuilder(_imagePaths.icAddIdentity)
              ..key(const Key('button_add_identity'))
              ..decoration(BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColor.colorBorderIdentityInfo))
              ..paddingIcon(const EdgeInsets.only(right: 12))
              ..iconColor(AppColor.primaryColor)
              ..size(28)
              ..padding(const EdgeInsets.symmetric(vertical: 12))
              ..textStyle(const TextStyle(
                fontSize: 16,
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w500,
              ))
              ..onPressActionClick(() => controller.goToCreateNewIdentity(context))
              ..text(
                AppLocalizations.of(context).create_new_identity,
                isVertical: false,
              ))
            .build(),
          ),
        ),
      ],
    );
  }

}