import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/email_forward_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ListEmailForwardsWidget extends GetWidget<ForwardController> {
  const ListEmailForwardsWidget({Key? key}) : super(key: key);

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
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColor.colorBackgroundHeaderListForwards,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 24,
                ),
                child: Text(AppLocalizations.of(context).headerEmailsForward,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColor.colorTextButtonHeaderThread)),
              ),
              const Divider(
                color: AppColor.lineItemListColor,
                height: 1,
                thickness: 0.2,
              ),
              Expanded(
                child: Obx(() {
                  log('ListEmailForwardsWidget::build(): ${controller.listForwards}');
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.listForwards.length,
                    itemBuilder: (context, index) {
                      final emailForward = controller.listForwards[index];
                      log('ListEmailForwardsWidget::build(): $emailForward');
                      return EmailForwardItemWidget(emailForward: emailForward);
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
}
