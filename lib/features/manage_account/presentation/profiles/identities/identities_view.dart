
import 'package:core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/identity_info_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IdentitiesView extends GetWidget<IdentitiesController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  IdentitiesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonSelectIdentity = Row(children: [
      Expanded(child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton2<Identity>(
          isExpanded: true,
          hint: Row(
            children: [
              Expanded(child: Text(
                controller.identitySelected.value?.name ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
          items: controller.listIdentities.map((item) => DropdownMenuItem<Identity>(
            value: item,
            child: Text(
              item.name ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
          value: controller.identitySelected.value,
          onChanged: (newIdentity) => controller.selectIdentity(newIdentity),
          icon: SvgPicture.asset(_imagePaths.icDropDown),
          buttonPadding: const EdgeInsets.symmetric(horizontal: 12),
          buttonDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.colorInputBorderCreateMailbox, width: 0.5),
              color: AppColor.colorInputBackgroundCreateMailbox),
          itemHeight: 44,
          buttonHeight: 44,
          itemPadding: const EdgeInsets.symmetric(horizontal: 12),
          dropdownMaxHeight: 200,
          dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white),
          dropdownElevation: 4,
          scrollbarRadius: const Radius.circular(40),
          scrollbarThickness: 6,
        ),
      ))),
      if (!_responsiveUtils.isMobile(context)) const SizedBox(width: 12),
      if (!_responsiveUtils.isMobile(context))
        (ButtonBuilder(_imagePaths.icAddIdentity)
            ..key(const Key('button_new_identity'))
            ..decoration(BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.colorTextButton))
            ..paddingIcon(const EdgeInsets.only(right: 8))
            ..iconColor(Colors.white)
            ..maxWidth(170)
            ..size(20)
            ..radiusSplash(10)
            ..padding(const EdgeInsets.symmetric(vertical: 12))
            ..textStyle(const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w500))
            ..onPressActionClick(() => {})
            ..text(AppLocalizations.of(context).new_identity, isVertical: false))
          .build()
    ]);

    return LayoutBuilder(builder: (context, constraints) => ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: Scaffold(
          body: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buttonSelectIdentity,
                    Obx(() => IdentityInfoTileBuilder(context,
                        _imagePaths,
                        controller.identitySelected.value)),
                  ]
              )),
          floatingActionButton: _responsiveUtils.isMobile(context)
            ? FloatingActionButton(
                  key: const Key('add_new_identity'),
                  onPressed: () => {},
                  backgroundColor: AppColor.primaryColor,
                  child: SvgPicture.asset(_imagePaths.icAddIdentity, width: 24, height: 24))
            : null),
        desktop: Container(
            margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: constraints.maxWidth / 2,
                      child: buttonSelectIdentity),
                  Obx(() => IdentityInfoTileBuilder(context,
                      _imagePaths,
                      controller.identitySelected.value,
                      maxWidth: constraints.maxWidth / 2)),
                ]
            )
        )
    ));
  }
}