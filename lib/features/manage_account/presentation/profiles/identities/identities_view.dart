import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_menu_widget_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/identities_header_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/identities_radio_list_builder.dart';

class IdentitiesView extends GetWidget<IdentitiesController> with PopupMenuWidgetMixin, AppLoaderMixin {

  IdentitiesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SettingsUtils.getSettingContentPadding(
        context,
        controller.responsiveUtils,
      ),
      child: controller.responsiveUtils.isWebDesktop(context)
        ? _buildIdentitiesViewWebDesktop(context)
        : _buildIdentitiesViewMobile(context),
    );
  }

  Widget _buildIdentitiesViewMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IdentitiesHeaderWidget(
          onAddNewIdentityAction: () => controller.goToCreateNewIdentity(context),
        ),
        const SizedBox(height: 12),
        IdentitiesRadioListBuilder(
          controller: controller,
          responsiveUtils: controller.responsiveUtils,
          imagePaths: controller.imagePaths
        )
      ],
    );
  }

  Widget _buildIdentitiesViewWebDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 224,
          child: IdentitiesHeaderWidget(
            onAddNewIdentityAction: () => controller.goToCreateNewIdentity(context),
          )
        ),
        const SizedBox(width: 12),
        Expanded(child: IdentitiesRadioListBuilder(
          controller: controller,
          responsiveUtils: controller.responsiveUtils,
          imagePaths: controller.imagePaths
        )),
      ],
    );
  }
}