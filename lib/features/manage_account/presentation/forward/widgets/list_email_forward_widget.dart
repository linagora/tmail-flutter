import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/email_forward_item_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ListEmailForwardsWidget extends GetWidget<ForwardController> {

  const ListEmailForwardsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTitleHeader(context),
        Obx(() {
          if (controller.listRecipientForward.isEmpty) {
            return const SizedBox.shrink();
          } else {
            return ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: controller.listRecipientForward.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return EmailForwardItemWidget(
                  recipientForward: controller.listRecipientForward[index],
                  internalDomain: controller.accountDashBoardController.sessionCurrent?.internalDomain ?? '',
                  selectionMode: controller.selectionMode.value,
                  onSelectRecipientCallback: controller.selectRecipientForward,
                  onDeleteRecipientCallback: (recipientForward) {
                    controller.deleteRecipients(context, recipientForward.emailAddress.emailAddress);
                  },
                );
              }
            );
          }
        }),
      ]
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
        onTap: controller.selectAllRecipientForward,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(
            AppLocalizations.of(context).select_all,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: AppColor.colorTextButton
            )
          ),
        ),
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
              controller.imagePaths.icClose,
              colorFilter: AppColor.colorTextButton.asFilter(),
              fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).cancel,
            onTap: controller.cancelSelectionMode
          ),
          Text(
            controller.isAllSelected
              ? AppLocalizations.of(context).totalEmailSelected(controller.listRecipientForwardSelected.length)
              : AppLocalizations.of(context).count_email_selected(controller.listRecipientForwardSelected.length),
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Text(
            AppLocalizations.of(context).remove,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
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