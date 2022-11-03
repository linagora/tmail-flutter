import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/email_forward_item_widget.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/email_forward_item_widget_for_web.dart';
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
      decoration: SettingsUtils.getBoxDecorationForListRecipient(context, _responsiveUtils),
      margin: SettingsUtils.getPaddingListRecipientForwarding(context, _responsiveUtils),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleHeader(context),
              const Divider(
                color: AppColor.lineItemListColor,
                height: 1,
                thickness: 0.2,
              ),
              Obx(() {
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: controller.listRecipientForward.length,
                  itemBuilder: (context, index) {
                    final recipientForward = controller.listRecipientForward[index];
                    return EmailForwardItemWidget(
                        recipientForward: recipientForward,
                        isLast: index == controller.listRecipientForward.length - 1,
                        selectionMode: controller.selectionMode.value);
                  },
                  separatorBuilder: (context, index) {
                    if (index != controller.listRecipientForward.length - 1) {
                       return const Divider(
                         color: AppColor.lineItemListColor,
                         height: 1,
                         thickness: 0.2,
                       );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              }),
            ]),
      ),
    );
  }

  Widget _buildTitleHeader(BuildContext context) {
    return Obx(() => Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColor.colorBackgroundHeaderListForwards,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16)
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(children: [
        _buildSelectAllButton(),
        const SizedBox(width: 12),
        Expanded(child: Text(
          AppLocalizations.of(context).headerRecipients,
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColor.colorTextButtonHeaderThread
          )
        )),
        const SizedBox(width: 12),
        if (controller.listRecipientForwardSelected.isNotEmpty)
          _buildDeleteAllButton(context)
      ]),
    ));
  }

  Widget _buildSelectAllButton() {
    return Material(
      child: InkWell(
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SvgPicture.asset(
              controller.selectionMode.value == SelectMode.ACTIVE
                  ? _imagePaths.icCancelSelection
                  : _imagePaths.icUnSelected,
              width: 24,
              height: 24
          ),
        ),
        onTap: () {
          if (controller.selectionMode.value == SelectMode.ACTIVE) {
            controller.cancelSelectionMode();
          } else {
            controller.selectAllRecipientForward();
          }
        },
      ),
      color: Colors.transparent,
    );
  }

  Widget _buildDeleteAllButton(BuildContext context) {
    return buildIconWeb(
      icon: SvgPicture.asset(
        _imagePaths.icDeleteEmailForward,
        fit: BoxFit.fill,
        width: 18,
        height: 18,
      ),
      tooltip: AppLocalizations.of(context).delete_all,
      onTap: () => controller.deleteMultipleRecipients(
        context,
        controller.listRecipientForwardSelected.listEmailAddress
      )
    );
  }
}