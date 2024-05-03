
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/container/tmail_container_widget.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/filter_email_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DesktopTopBarThreadView extends StatelessWidget with FilterEmailPopupMenuMixin {
  
  final _dashboardController = Get.find<MailboxDashBoardController>();
  
  DesktopTopBarThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(children: [
        Obx(() {
          return _dashboardController.refreshingMailboxState.value.fold(
            (failure) {
              return TMailButtonWidget.fromIcon(
                key: const Key('refresh_mailbox_button'),
                icon: _dashboardController.imagePaths.icRefresh,
                borderRadius: 10,
                iconSize: 16,
                onTapActionCallback: _dashboardController.refreshMailboxAction,
              );
            },
            (success) {
              if (success is RefreshAllEmailLoading) {
                return const TMailContainerWidget(
                  borderRadius: 10,
                  padding: EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 8.5),
                  child: CupertinoLoadingWidget(size: 16));
              } else {
                return TMailButtonWidget.fromIcon(
                  key: const Key('refresh_mailbox_button'),
                  icon: _dashboardController.imagePaths.icRefresh,
                  borderRadius: 10,
                  iconSize: 16,
                  onTapActionCallback: _dashboardController.refreshMailboxAction,
                );
              }
            }
          );
        }),
        Obx(() {
          if (_dashboardController.emailsInCurrentMailbox.isNotEmpty) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Tooltip(
                message: AppLocalizations.of(context).selectAllMessagesOfThisPage,
                child: ElevatedButton.icon(
                  onPressed: _dashboardController.selectAllEmailAction,
                  icon: SvgPicture.asset(
                    _dashboardController.imagePaths.icSelectAll,
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill,
                  ),
                  label: Text(
                    AppLocalizations.of(context).selectAllMessagesOfThisPage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.colorButtonHeaderThread,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    elevation: 0.0,
                    foregroundColor: AppColor.colorTextButtonHeaderThread,
                    maximumSize: const Size.fromWidth(250),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (_isAbleMarkAllAsRead) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: TMailButtonWidget(
                key: const Key('mark_all_as_read_emails_button'),
                text: AppLocalizations.of(context).mark_all_as_read,
                icon: _dashboardController.imagePaths.icMarkAllAsRead,
                borderRadius: 10,
                iconSize: 16,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
                onTapActionCallback: () => _dashboardController.markAsReadMailboxAction(context),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          final messageOption = _dashboardController.filterMessageOption.value;
          if (_dashboardController.emailsInCurrentMailbox.isNotEmpty) {
            return TMailButtonWidget(
              key: const Key('filter_emails_button'),
              text: messageOption == FilterMessageOption.all
                ? AppLocalizations.of(context).filter_messages
                : messageOption.getTitle(context),
              icon: messageOption.getIconSelected(_dashboardController.imagePaths),
              borderRadius: 10,
              iconSize: 16,
              margin: const EdgeInsetsDirectional.only(start: 16),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: messageOption.getBackgroundColor(),
              textStyle: messageOption.getTextStyle(),
              trailingIcon: _dashboardController.imagePaths.icArrowDown,
              onTapActionAtPositionCallback: (position) {
                return _dashboardController.openPopupMenuAction(
                  context,
                  position,
                  popupMenuFilterEmailActionTile(
                    context,
                    messageOption,
                    (option) => _dashboardController.dispatchAction(FilterMessageAction(context, option)),
                    isSearchEmailRunning: _dashboardController.searchController.isSearchEmailRunning
                  )
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          final mailboxSelected = _dashboardController.selectedMailbox.value;
          if (mailboxSelected != null && mailboxSelected.isTrash) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: TMailButtonWidget.fromIcon(
                key: const Key('recover_deleted_messages_button'),
                icon: _dashboardController.imagePaths.icRecoverDeletedMessages,
                borderRadius: 10,
                iconSize: 16,
                onTapActionCallback: _dashboardController.gotoEmailRecovery,
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        })
      ]),
    );
  }

  bool get _isAbleMarkAllAsRead {
    return !_dashboardController.searchController.isSearchEmailRunning
      && _dashboardController.emailsInCurrentMailbox.isNotEmpty
      && _dashboardController.selectedMailbox.value != null
      && (!_dashboardController.selectedMailbox.value!.isDrafts && !_dashboardController.selectedMailbox.value!.isSpam);
  }
}
