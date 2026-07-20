import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/filter_message_button_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/filter_message_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/quick_search_filter_button.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ThreadListActionBar extends ConsumerWidget {
  final _controller = Get.find<MailboxDashBoardController>();
  final _imagePaths = Get.find<ImagePaths>();

  static final Color _actionButtonBackgroundColor =
      AppColor.colorFilterMessageButton.withValues(alpha: 0.6);

  final OnSelectFilterMessageOptionAction onSelectFilterMessageOptionAction;
  final OnDeleteFilterMessageOptionAction onDeleteFilterMessageOptionAction;
  final OnSelectQuickSearchFilterAction onSelectSearchFilterAction;
  final OnDeleteQuickSearchFilterAction onDeleteSearchFilterAction;

  ThreadListActionBar({
    super.key,
    required this.onSelectFilterMessageOptionAction,
    required this.onDeleteFilterMessageOptionAction,
    required this.onSelectSearchFilterAction,
    required this.onDeleteSearchFilterAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchViewState = ref.watch(searchViewStateProvider);
    return Row(children: [
      _buildRefreshButton(),
      _buildSelectAllButton(context),
      _buildFilterMessageButton(context, searchViewState),
      _buildRecoverDeletedButton(),
      _buildSortByButton(context, searchViewState),
    ]);
  }

  Widget _buildRefreshButton() {
    return Obx(() {
      if (_controller.isRefreshingAllMailboxAndEmail) {
        return TMailContainerWidget(
          borderRadius: 10,
          backgroundColor: _actionButtonBackgroundColor,
          padding: const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 8.5),
          child: const CupertinoLoadingWidget(size: 16));
      } else {
        return _buildIconActionButton(
          key: const Key('refresh_all_mailbox_and_email_button'),
          icon: _imagePaths.icRefresh,
          onTap: _controller.refreshMailboxAction,
        );
      }
    });
  }

  Widget _buildSelectAllButton(BuildContext context) {
    return Obx(() {
      if (_controller.emailsInCurrentMailbox.isEmpty) {
        return const SizedBox.shrink();
      } else {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: Tooltip(
            message: AppLocalizations.of(context).selectAllMessagesOfThisPage,
            child: ElevatedButton.icon(
              onPressed: _controller.selectAllEmailAction,
              icon: SvgPicture.asset(
                _imagePaths.icSelectAll,
                width: 16,
                height: 16,
                fit: BoxFit.fill,
                colorFilter: AppColor.colorFilterMessageIcon.asFilter(),
              ),
              label: Text(
                AppLocalizations.of(context).selectAllMessagesOfThisPage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: AppColor.colorFilterMessageTitle,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _actionButtonBackgroundColor,
                shadowColor: Colors.transparent,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                elevation: 0.0,
                foregroundColor: AppColor.colorTextButtonHeaderThread,
                maximumSize: const Size.fromWidth(250),
                fixedSize: const Size.fromHeight(34),
                textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: AppColor.colorFilterMessageTitle
                ),
              ),
            ),
          ),
        );
      }
    });
  }

  Widget _buildFilterMessageButton(
    BuildContext context,
    SearchViewState searchViewState,
  ) {
    return Obx(() {
      final filterMessageCurrent = _controller.filterMessageOption.value;

      if (_controller.validateNoEmailsInTrashAndSpamFolder() ||
          searchViewState.isSearchEmailRunning) {
        return const SizedBox.shrink();
      } else {
        return Padding(
          padding: FilterMessageButtonStyle.buttonMargin,
          child: FilterMessageButton(
            filterMessageOption: filterMessageCurrent,
            imagePaths: _imagePaths,
            isSelected: filterMessageCurrent != FilterMessageOption.all,
            onSelectFilterMessageOptionAction: onSelectFilterMessageOptionAction,
            onDeleteFilterMessageOptionAction: onDeleteFilterMessageOptionAction,
          ),
        );
      }
    });
  }

  Widget _buildRecoverDeletedButton() {
    return Obx(() {
      if (_controller.selectedMailbox.value?.isTrashPersonal == true) {
        return _buildIconActionButton(
          key: const Key('recover_deleted_messages_button'),
          icon: _imagePaths.icRecoverDeletedMessages,
          margin: const EdgeInsetsDirectional.only(start: 16),
          onTap: _controller.gotoEmailRecovery,
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildSortByButton(
    BuildContext context,
    SearchViewState searchViewState,
  ) {
    return Obx(() {
      if (_controller.dashboardRoute.value == DashboardRoutes.thread &&
          searchViewState.isSearchEmailRunning) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: QuickSearchFilterButton(
            searchFilter: QuickSearchFilter.sortBy,
            onSelectSearchFilterAction: onSelectSearchFilterAction,
            onDeleteSearchFilterAction: onDeleteSearchFilterAction,
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  /// The trailing icon-only actions (refresh, recover-deleted) share one look:
  /// a rounded 16px icon on the shared action-button background.
  Widget _buildIconActionButton({
    required Key key,
    required String icon,
    required VoidCallback onTap,
    EdgeInsetsGeometry? margin,
  }) {
    return TMailButtonWidget.fromIcon(
      key: key,
      icon: icon,
      borderRadius: 10,
      iconSize: 16,
      backgroundColor: _actionButtonBackgroundColor,
      margin: margin,
      onTapActionCallback: onTap,
    );
  }
}
