
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/compose_floating_button.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/extensions/list_sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/sending_queue_controller.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/widgets/app_bar_sending_queue_widget.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/widgets/banner_message_sending_queue_widget.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/widgets/bottom_bar_sending_queue_widget.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/widgets/sending_email_tile_widget.dart';

class SendingQueueView extends GetWidget<SendingQueueController> with AppLoaderMixin {

  const SendingQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Obx(() {
              return AppBarSendingQueueWidget(
                listSendingEmailSelected: controller.dashboardController.listSendingEmails.listSelected(),
                onOpenMailboxMenu: controller.openMailboxMenu,
                onBackAction: controller.disableSelectionMode,
                selectMode: controller.selectionState.value,
              );
            }),
            const Divider(color: AppColor.colorDividerComposer, height: 1),
            const BannerMessageSendingQueueWidget(),
            Expanded(child: _buildListSendingEmails(context)),
            Obx(() {
              if (controller.isAllUnSelected) {
                return const SizedBox.shrink();
              } else {
               return BottomBarSendingQueueWidget(
                  listSendingEmailSelected: controller.dashboardController.listSendingEmails.listSelected(),
                  onHandleSendingEmailActionType: (actionType, listSendingEmails) => controller.handleSendingEmailActionType(context, actionType, listSendingEmails),
                );
              }
            }),
          ]
        ),
      ),
      floatingActionButton: _buildFloatingButtonCompose(),
    );
  }

  Widget _buildListSendingEmails(BuildContext context) {
    return Obx(() {
      if (controller.selectionState.value == SelectMode.INACTIVE) {
        return RefreshIndicator(
          color: AppColor.primaryColor,
          onRefresh: () async => controller.refreshSendingQueue(),
          child: _buildListViewItemSendingEmails());
      } else {
        return _buildListViewItemSendingEmails();
      }
    });
  }

  Widget _buildListViewItemSendingEmails() {
    return Obx(() {
      final listSendingEmails = controller.dashboardController.listSendingEmails;
      if (listSendingEmails.isNotEmpty) {
        return ListView.builder(
          controller: controller.listSendingEmailController,
          physics: const AlwaysScrollableScrollPhysics(), // Trigger Refresh To pull
          itemCount: listSendingEmails.length,
          itemBuilder: (context, index) {
            return SendingEmailTileWidget(
              sendingEmail: listSendingEmails[index],
              selectMode: controller.selectionState.value,
              onLongPressAction: controller.handleOnLongPressAction,
              onSelectLeadingAction: controller.toggleSelectionSendingEmail,
              onTapAction: (actionType, sendingEmail) {
                if (PlatformInfo.isMobile && sendingEmail.isEditableSupported) {
                  controller.handleSendingEmailActionType(context, actionType, [sendingEmail]);
                }
              });
          }
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildFloatingButtonCompose() {
    return Obx(() {
      if (controller.isAllUnSelected) {
        return ComposeFloatingButton(
          scrollController: controller.listSendingEmailController,
          onTap: () => controller.dashboardController.openComposer(ComposerArguments())
        );
      } else {
        return Container(
          padding: const EdgeInsets.only(bottom: 70),
          child: ComposeFloatingButton(
            scrollController: controller.listSendingEmailController,
            onTap: () => controller.dashboardController.openComposer(ComposerArguments())
          ),
        );
      }
    });
  }
}