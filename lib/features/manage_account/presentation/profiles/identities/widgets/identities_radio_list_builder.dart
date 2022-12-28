import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/identity_list_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/signature_of_identity_builder.dart';

class IdentitiesRadioListBuilder extends StatelessWidget {

  final IdentitiesController controller;
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;

  const IdentitiesRadioListBuilder({
    Key? key,
    required this.controller,
    required this.responsiveUtils,
    required this.imagePaths,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: responsiveUtils.isWebDesktop(context) ? 256 : null,
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.attachmentFileBorderColor),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        color: Colors.white
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        child: responsiveUtils.isWebDesktop(context)
          ? _buildIdentityViewHorizontal(context)
          : _buildIdentityViewVertical(context))
    );
  }

  Widget _buildIdentityViewVertical(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(controller.isSignatureShow)
          ...[
            _buildListIdentityView(context),
            Container(height: 1, color: AppColor.attachmentFileBorderColor),
            Obx(() => SignatureOfIdentityBuilder(identity: controller.identitySelected.value!))
          ]
        else
          _buildListIdentityView(context)
      ],
    ));
  }

  Widget _buildIdentityViewHorizontal(BuildContext context) {
    return Obx(() => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.isSignatureShow)
          ...[
            _buildListIdentityView(context),
            Container(width: 1, color: AppColor.attachmentFileBorderColor),
            Expanded(
              child: Obx(() => SignatureOfIdentityBuilder(identity: controller.identitySelected.value!)),
            )
          ]
        else
          Expanded(child: _buildListIdentityView(context))
      ],
    ));
  }

  Widget _buildListIdentityView(BuildContext context) {
    return Container(
      key: const Key('identities_list'),
      width: responsiveUtils.isWebDesktop(context) ? 320 : null,
      height: 256,
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
      child: Obx(() => FadingEdgeScrollView.fromScrollView(
        gradientFractionOnStart: 0.3,
        gradientFractionOnEnd: 0.3,
        shouldDisposeScrollController: true,
        child: ListView.builder(
          controller: ScrollController(),
          padding: const EdgeInsets.only(right: 12.0),
          itemCount: controller.listAllIdentities.length,
          itemBuilder: ((context, index) {
            return IdentityListTileBuilder(
              imagePaths: imagePaths,
              identity: controller.listAllIdentities[index],
              identitySelected: controller.identitySelected.value,
              onSelectIdentityAction: controller.selectIdentity,
              onEditIdentityAction: (identitySelected) =>
                controller.goToEditIdentity(context, identitySelected),
              onDeleteIdentityAction: (identitySelected) =>
                controller.openConfirmationDialogDeleteIdentityAction(context, identitySelected),
            );
          }),
        ),
      ))
    );
  }
}