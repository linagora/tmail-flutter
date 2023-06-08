
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/compose_floating_button.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/extensions/list_sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/sending_queue_controller.dart';
import 'package:get/get.dart';
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
                listSendingEmails: controller.listSendingEmailSelected,
                onOpenMailboxMenu: controller.openMailboxMenu,
                onBackAction: controller.disableSelectionMode,
                selectMode: controller.selectionState.value,
              );
            }),
            const Divider(color: AppColor.colorDividerComposer, height: 1),
            Obx(() {
              if (!controller.dashboardController!.listSendingEmails.isAllNotReadySendingState()) {
                return const BannerMessageSendingQueueWidget();
              } else {
                return const SizedBox.shrink();
              }
            }),
            Expanded(child: _buildListSendingEmails(context)),
            Obx(() {
              if (controller.isAllUnSelected) {
                return const SizedBox.shrink();
              } else {
               return BottomBarSendingQueueWidget(
                  listSendingEmails: controller.listSendingEmailSelected,
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
      if (controller.dashboardController!.listSendingEmails.isNotEmpty) {
        return LayoutBuilder(builder: (context, constraints) {
          log('SendingQueueView::_buildListSendingEmails(): MAX_WIDTH: ${constraints.maxWidth}');
          return ListView.builder(
            controller: controller.listSendingEmailController,
            itemCount: controller.dashboardController!.listSendingEmails.length,
            itemBuilder: (context, index) {
              return Obx(() => SendingEmailTileWidget(
                sendingEmail: controller.dashboardController!.listSendingEmails[index],
                selectMode: controller.selectionState.value,
                onLongPressAction: controller.handleOnLongPressAction,
                onSelectLeadingAction: controller.toggleSelectionSendingEmail,
                onTapAction:  (actionType, listSendingEmails) => controller.handleSendingEmailActionType(context, actionType, [listSendingEmails])));
            }
          );
        });
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
          onTap: () => controller.dashboardController!.goToComposer(ComposerArguments())
        );
      } else {
        return Container(
          padding: const EdgeInsets.only(bottom: 70),
          child: ComposeFloatingButton(
            scrollController: controller.listSendingEmailController,
            onTap: () => controller.dashboardController!.goToComposer(ComposerArguments())
          ),
        );
      }
    });
  }
}