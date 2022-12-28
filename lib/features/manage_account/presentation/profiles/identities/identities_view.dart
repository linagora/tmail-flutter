import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_menu_widget_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/identities_header_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/identities_radio_list_builder.dart';

class IdentitiesView extends GetWidget<IdentitiesController> with PopupMenuWidgetMixin, AppLoaderMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  IdentitiesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.all(24),
      child: _responsiveUtils.isWebDesktop(context)
        ? _buildIdentitiesViewWebDesktop(context)
        : _buildIdentitiesViewMobile(context),
    );
  }

  Widget _buildIdentitiesViewMobile(BuildContext context) {
    return Column(
      children: [
        IdentitiesHeaderWidget(
          imagePaths: _imagePaths,
          responsiveUtils: _responsiveUtils,
          onAddNewIdentityAction: () => controller.goToCreateNewIdentity(context),
        ),
        const SizedBox(height: 12),
        IdentitiesRadioListBuilder(
          controller: controller,
          responsiveUtils: _responsiveUtils,
          imagePaths: _imagePaths
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
            imagePaths: _imagePaths,
            responsiveUtils: _responsiveUtils,
            onAddNewIdentityAction: () => controller.goToCreateNewIdentity(context),
          )
        ),
        const SizedBox(width: 12),
        Expanded(child: IdentitiesRadioListBuilder(
          controller: controller,
          responsiveUtils: _responsiveUtils,
          imagePaths: _imagePaths
        )),
      ],
    );
  }
}