
import 'package:core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_menu_widget_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/identity_bottom_sheet_action_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/identity_info_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IdentitiesView extends GetWidget<IdentitiesController> with PopupMenuWidgetMixin, AppLoaderMixin {

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
                overflow: BuildUtils.isWeb ? null : TextOverflow.ellipsis,
              )),
            ],
          ),
          items: controller.listAllIdentities.map((item) => DropdownMenuItem<Identity>(
            value: item,
            child: Text(
              item.name ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
              maxLines: 1,
              overflow: BuildUtils.isWeb ? null : TextOverflow.ellipsis,
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
          selectedItemHighlightColor: Colors.black12,
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
            ..decoration(BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColor.colorTextButton))
            ..paddingIcon(const EdgeInsets.only(right: 8))
            ..iconColor(Colors.white)
            ..maxWidth(170)
            ..size(20)
            ..radiusSplash(10)
            ..padding(const EdgeInsets.symmetric(vertical: 12))
            ..textStyle(const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w500))
            ..onPressActionClick(() => controller.goToCreateNewIdentity())
            ..text(AppLocalizations.of(context).new_identity, isVertical: false))
          .build()
    ]);

    return LayoutBuilder(builder: (context, constraints) => ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: Scaffold(
          body: Container(
              margin: const EdgeInsets.only(top: 16, bottom: 16, right: 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buttonSelectIdentity,
                    const SizedBox(height: 24),
                    _buildLoadingView(),
                    Expanded(child: Obx(() => MasonryGridView.count(
                        key: const Key('list_identities'),
                        crossAxisSpacing: 24.0,
                        mainAxisSpacing: 24.0,
                        crossAxisCount: _responsiveUtils.isDesktop(context) || _responsiveUtils.isTabletLarge(context)
                            ? 2 : 1,
                        itemCount: controller.listSelectedIdentities.length,
                        itemBuilder: (context, index) =>
                            IdentityInfoTileBuilder(_imagePaths, _responsiveUtils,
                                controller.listSelectedIdentities[index],
                                onMenuItemIdentityAction: (identity, position) =>
                                    _openIdentityMenuAction(context, identity, position))
                    )))
                  ]
              )
          ),
          floatingActionButton: _responsiveUtils.isMobile(context)
            ? FloatingActionButton(
                  key: const Key('add_new_identity'),
                  onPressed: () => controller.goToCreateNewIdentity(),
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
                  const SizedBox(height: 24),
                  _buildLoadingView(),
                  Expanded(child: Obx(() => MasonryGridView.count(
                      key: const Key('list_identities'),
                      crossAxisSpacing: 24.0,
                      mainAxisSpacing: 24.0,
                      crossAxisCount: _responsiveUtils.isDesktop(context) || _responsiveUtils.isTabletLarge(context)
                          ? 2 : 1,
                      itemCount: controller.listSelectedIdentities.length,
                      itemBuilder: (context, index) =>
                          IdentityInfoTileBuilder(_imagePaths, _responsiveUtils,
                              controller.listSelectedIdentities[index],
                              onMenuItemIdentityAction: (identity, position) =>
                                  _openIdentityMenuAction(context, identity, position))
                  )))
                ]
            )
        )
    ));
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
        (failure) => const SizedBox.shrink(),
        (success) => success is LoadingState
            ? Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: loadingWidget)
            : const SizedBox.shrink()
    ));
  }

  void _openIdentityMenuAction(BuildContext context, Identity identity,
      RelativeRect? position) {
    if (_responsiveUtils.isScreenWithShortestSide(context)) {
      controller.openContextMenuAction(context, _bottomSheetIdentityActionTiles(context, identity));
    } else {
      controller.openPopupMenuAction(context, position, _popupMenuIdentityActionTiles(context, identity));
    }
  }

  List<PopupMenuEntry> _popupMenuIdentityActionTiles(BuildContext context, Identity identity) {
    return [
      PopupMenuItem(
          padding: EdgeInsets.zero,
          child: popupItem(_imagePaths.icEdit,
              AppLocalizations.of(context).edit_identity,
              styleName: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 17,
                  color: Colors.black),
              onCallbackAction: () => controller.goToEditIdentity(identity))),
      if (identity.mayDelete == true)
        PopupMenuItem(
            padding: EdgeInsets.zero,
            child: popupItem(_imagePaths.icDeleteComposer,
                AppLocalizations.of(context).delete_identity,
                colorIcon: AppColor.colorActionDeleteConfirmDialog,
                styleName: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 17,
                    color: AppColor.colorActionDeleteConfirmDialog),
                onCallbackAction: () => controller.openConfirmationDialogDeleteIdentityAction(context, identity))),
    ];
  }

  List<Widget> _bottomSheetIdentityActionTiles(BuildContext context, Identity identity) {
    return <Widget>[
      _editIdentityActionTile(context, identity),
      if (identity.mayDelete == true)
        _deleteIdentityActionTile(context, identity),
    ];
  }

  Widget _deleteIdentityActionTile(BuildContext context, Identity identity) {
    return (IdentityBottomSheetActionTileBuilder(
            const Key('delete_identity_action'),
            SvgPicture.asset(_imagePaths.icDeleteComposer,
                color: AppColor.colorActionDeleteConfirmDialog),
            AppLocalizations.of(context).delete_identity,
            identity,
            iconLeftPadding: _responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(left: 12, right: 16)
                : const EdgeInsets.only(right: 12),
            iconRightPadding: _responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(right: 12)
                : EdgeInsets.zero)
        ..onActionClick((identity) => controller.openConfirmationDialogDeleteIdentityAction(context, identity)))
      .build();
  }

  Widget _editIdentityActionTile(BuildContext context, Identity identity) {
    return (IdentityBottomSheetActionTileBuilder(
            const Key('edit_identity_action'),
            SvgPicture.asset(_imagePaths.icEdit),
            AppLocalizations.of(context).edit_identity,
            identity,
            iconLeftPadding: _responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(left: 12, right: 16)
                : const EdgeInsets.only(right: 12),
            iconRightPadding: _responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(right: 12)
                : EdgeInsets.zero)
        ..onActionClick((identity) => controller.goToEditIdentity(identity)))
      .build();
  }
}