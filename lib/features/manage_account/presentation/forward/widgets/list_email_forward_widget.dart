import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/email_forward_item_widget.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/email_forward_item_widget_for_web.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ListEmailForwardsWidget extends GetWidget<ForwardController> {

  final _imagePaths = Get.find<ImagePaths>();

  ListEmailForwardsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.colorBackgroundWrapIconStyleCode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            width: 1,
            color: AppColor.colorBorderListForwardsFilter)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColor.colorBackgroundHeaderListForwards,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
                padding: controller.selectionMode.value == SelectMode.INACTIVE
                    ? const EdgeInsets.all(24)
                    : const EdgeInsets.symmetric(vertical: 13, horizontal: 24),
                child: Row(children: [
                  Expanded(child: Text(
                      AppLocalizations.of(context).headerEmailsForward,
                      overflow: CommonTextStyle.defaultTextOverFlow,
                      softWrap: CommonTextStyle.defaultSoftWrap,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColor.colorTextButtonHeaderThread))),
                  Obx(() {
                    if (controller.selectionMode.value == SelectMode.ACTIVE) {
                      return _buildListButtonSelection(context);
                    } else {
                      return const SizedBox.shrink();
                    }
                  })
                ]),
              )),
              const Divider(
                color: AppColor.lineItemListColor,
                height: 1,
                thickness: 0.2,
              ),
              Expanded(
                child: Obx(() {
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.listRecipientForward.length,
                    itemBuilder: (context, index) {
                      final recipientForward = controller.listRecipientForward[index];
                      return EmailForwardItemWidget(
                          recipientForward: recipientForward,
                          selectionMode: controller.selectionMode.value);
                    },
                    separatorBuilder: (context, index) => const Divider(
                        color: AppColor.lineItemListColor,
                        height: 1,
                        thickness: 0.2,
                      ),
                  );
                }),
              ),
            ]),
      ),
    );
  }

  Widget _buildListButtonSelection(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      buildIconWeb(
          icon: SvgPicture.asset(
              _imagePaths.icCloseComposer,
              color: AppColor.colorTextButton,
              fit: BoxFit.fill),
          tooltip: AppLocalizations.of(context).cancel,
          onTap: () => controller.cancelSelectionMode()),
      const SizedBox(width: 5),
      buildIconWeb(
          icon: SvgPicture.asset(
              _imagePaths.icDelete,
              color: AppColor.colorActionDeleteConfirmDialog,
              fit: BoxFit.fill),
          tooltip: AppLocalizations.of(context).delete_all,
          onTap: () =>
              controller.deleteMultipleRecipients(
                  context,
                  controller.listRecipientForwardSelected.listEmailAddress))
    ]);
  }
}