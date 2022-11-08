import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/email_forward_item_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ListEmailForwardsWidget extends GetWidget<ForwardController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  ListEmailForwardsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: SettingsUtils.getPaddingListRecipientForwarding(context, _responsiveUtils),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitleHeader(context),
          Obx(() {
            return ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: controller.listRecipientForward.length,
              itemBuilder: (context, index) {
                return EmailForwardItemWidget(
                  controller.listRecipientForward[index],
                  selectionMode: controller.selectionMode.value,
                  onSelectRecipientCallback: controller.selectRecipientForward,
                  onDeleteRecipientCallback: (recipientForward) {
                    controller.deleteRecipients(context, recipientForward.emailAddress.emailAddress);
                  },
                );
              }
            );
          }),
        ]
      ),
    );
  }

  Widget _buildTitleHeader(BuildContext context) {
    return Obx(() => Container(
      width: double.infinity,
      color: Colors.transparent,
      height: 44,
      padding: const EdgeInsets.only(right: 12),
      child: Row(children: [
        if (controller.selectionMode.value == SelectMode.ACTIVE)
          _buildCancelSectionButton(context),
        if (!controller.isAllSelected)
          _buildSelectAllButton(context),
        const Spacer(),
        const SizedBox(width: 12),
        if (controller.listRecipientForwardSelected.isNotEmpty)
          _buildDeleteAllButton(context)
      ]),
    ));
  }

  Widget _buildSelectAllButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(
            AppLocalizations.of(context).select_all,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: AppColor.colorTextButton
            )
          ),
        ),
        onTap: controller.selectAllRecipientForward,
      )
    );
  }

  Widget _buildCancelSectionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildIconWeb(
            icon: SvgPicture.asset(
              _imagePaths.icCloseComposer,
              color: AppColor.colorTextButton,
              fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).cancel,
            onTap: controller.cancelSelectionMode
          ),
          Text(
            controller.isAllSelected
              ? AppLocalizations.of(context).totalEmailSelected(controller.listRecipientForwardSelected.length)
              : AppLocalizations.of(context).count_email_selected(controller.listRecipientForwardSelected.length),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: AppColor.colorTextButton
            )
          )
        ],
      ),
    );
  }

  Widget _buildDeleteAllButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(
            AppLocalizations.of(context).remove,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: AppColor.colorDeletePermanentlyButton
            )
          ),
        ),
        onTap: () => controller.deleteMultipleRecipients(
          context,
          controller.listRecipientForwardSelected.listEmailAddress)
      )
    );
  }
}