import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
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
            return LayoutBuilder(
              builder: (context, constraints) {
                return ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: controller.listRecipientForward.length,
                  padding: const EdgeInsets.only(bottom: 30),
                  itemBuilder: (context, index) {
                    return EmailForwardItemWidget(
                      imagePaths: controller.imagePaths,
                      responsiveUtils: controller.responsiveUtils,
                      recipientForward: controller.listRecipientForward[index],
                      internalDomain: controller.accountDashBoardController.sessionCurrent?.internalDomain ?? '',
                      selectionMode: controller.selectionMode.value,
                      maxWidth: constraints.maxWidth,
                      onSelectRecipientCallback: controller.selectRecipientForward,
                      onDeleteRecipientCallback: (recipientForward) {
                        controller.deleteRecipients(context, recipientForward.emailAddress.emailAddress);
                      },
                    );
                  }
                );
              },
            );
          }
        }),
      ]
    );
  }

  Widget _buildTitleHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.only(end: 12, top: 32, bottom: 16),
      child: Obx(
        () => Row(
          children: [
            if (controller.selectionMode.value == SelectMode.ACTIVE)
              _buildCancelSectionButton(context),
            if (!controller.isAllSelected)
              _buildSelectAllButton(context),
            const Spacer(),
            if (controller.listRecipientForwardSelected.isNotEmpty)
              _buildDeleteAllButton(context)
          ],
        ),
      ),
    );
  }

  Widget _buildSelectAllButton(BuildContext context) {
    return TMailButtonWidget.fromText(
      text: AppLocalizations.of(context).select_all,
      textStyle: ThemeUtils.textStyleInter600().copyWith(
        letterSpacing: 0.25,
        fontSize: 14,
        height: 20 / 14,
        color: AppColor.gray424244,
      ),
      backgroundColor: Colors.transparent,
      onTapActionCallback: controller.selectAllRecipientForward,
    );
  }

  Widget _buildCancelSectionButton(BuildContext context) {
    return TMailButtonWidget(
      text: controller.isAllSelected
        ? AppLocalizations.of(context).totalEmailSelected(controller.listRecipientForwardSelected.length)
        : AppLocalizations.of(context).count_email_selected(controller.listRecipientForwardSelected.length),
      textStyle: ThemeUtils.textStyleInter600().copyWith(
        letterSpacing: 0.25,
        fontSize: 14,
        height: 20 / 14,
        color: AppColor.gray424244,
      ),
      icon: controller.imagePaths.icClose,
      iconSize: 20,
      iconColor: AppColor.gray424244,
      backgroundColor: Colors.transparent,
      onTapActionCallback: controller.cancelSelectionMode,
    );
  }

  Widget _buildDeleteAllButton(BuildContext context) {
    return TMailButtonWidget.fromText(
      text: AppLocalizations.of(context).remove,
      textStyle: ThemeUtils.textStyleInter600().copyWith(
        letterSpacing: 0.25,
        fontSize: 14,
        height: 20 / 14,
        color: AppColor.redFF3347,
      ),
      backgroundColor: Colors.transparent,
      onTapActionCallback: () => controller.deleteMultipleRecipients(
        context,
        controller.listRecipientForwardSelected.listEmailAddress,
      ),
    );
  }
}