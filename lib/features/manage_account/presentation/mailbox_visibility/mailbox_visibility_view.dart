import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/list/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_category_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/mailbox_visibility_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/state/mailbox_visibility_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/utils/mailbox_visibility_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/widgets/mailbox_visibility_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';

class MailboxVisibilityView extends GetWidget<MailboxVisibilityController>
  with AppLoaderMixin,
    MailboxWidgetMixin {

  MailboxVisibilityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingDetailViewBuilder(
      responsiveUtils: controller.responsiveUtils,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.responsiveUtils.isWebDesktop(context))
            ...[
              const SettingHeaderWidget(menuItem: AccountMenuItem.mailboxVisibility),
              const Divider(height: 1, color: AppColor.colorDividerHeaderSetting),
            ],
          _buildLoadingView(),
          Expanded(child: Padding(
            padding: MailboxVisibilityUtils.getPaddingListView(context, controller.responsiveUtils),
            child: _buildListMailbox(context)
          ))
        ]
      ),
    );
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is LoadingState || success is LoadingBuildTreeMailboxVisibility
        ? Padding(padding: const EdgeInsets.only(top: 16), child: loadingWidget)
        : const SizedBox.shrink()));
  }

  Widget _buildListMailbox(BuildContext context) {
    return SingleChildScrollView(
      controller: controller.mailboxListScrollController,
      key: const PageStorageKey('mailbox_list'),
      physics: const ClampingScrollPhysics(),
      child: Column(children: [
        Obx(() => controller.defaultMailboxIsNotEmpty
          ? _buildMailboxCategory(
              context,
              MailboxCategories.exchange,
              controller.defaultRootNode)
          : const SizedBox.shrink()
        ),
        Obx(() => controller.teamMailboxesIsNotEmpty
          ? _buildMailboxCategory(
              context,
              MailboxCategories.teamMailboxes,
              controller.teamMailboxesRootNode)
          : const SizedBox.shrink()
        ),
        Obx(() => controller.personalMailboxIsNotEmpty
          ? _buildMailboxCategory(
              context,
              MailboxCategories.personalFolders,
              controller.personalRootNode)
          : const SizedBox.shrink()
        )
      ])
    );
  }

  Widget _buildMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode) {
    if (categories == MailboxCategories.exchange) {
      return _buildBodyMailboxCategory(context, categories, mailboxNode);
    }
    return Column(children: [
      Obx(() => MailboxCategoryWidget(
        categories: categories,
        expandMode: categories.getExpandMode(
          controller.mailboxCategoriesExpandMode.value,
        ),
        onToggleMailboxCategories: (categories, itemKey) =>
          controller.toggleMailboxCategories(
            categories,
            controller.mailboxListScrollController,
            itemKey,
          ),
        padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
      )),
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
          ? _buildBodyMailboxCategory(context, categories, mailboxNode)
          : const Offstage()
      )
    ]);
  }

  Widget _buildBodyMailboxCategory(
    BuildContext context,
    MailboxCategories categories,
    MailboxNode mailboxNode,
  ) {
    return TreeView(
      key: Key('${categories.keyValue}_mailbox_list'),
      children: _buildListChildTileWidget(context, mailboxNode)
    );
  }

  List<Widget> _buildListChildTileWidget(
    BuildContext context,
    MailboxNode parentNode,
  ) {
    return parentNode.childrenItems
      ?.map((mailboxNode) => mailboxNode.hasChildren()
        ? TreeViewChild(
            context,
            key: const Key('children_tree_mailbox_child'),
            isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
            paddingChild: const EdgeInsetsDirectional.only(start: 10),
            parent: MailBoxVisibilityFolderTileBuilder(
              mailboxNode,
              onClickExpandMailboxNodeAction: (mailboxNode, itemKey) {
                controller.toggleMailboxFolder(
                  mailboxNode,
                  controller.mailboxListScrollController,
                  itemKey,
                );
              },
              onClickSubscribeMailboxAction: controller.subscribeMailbox
            ),
            children: _buildListChildTileWidget(context, mailboxNode)).build()
        : MailBoxVisibilityFolderTileBuilder(
            mailboxNode,
            onClickExpandMailboxNodeAction: (mailboxNode, itemKey) {
              controller.toggleMailboxFolder(
                mailboxNode,
                controller.mailboxListScrollController,
                itemKey,
              );
            },
            onClickSubscribeMailboxAction: controller.subscribeMailbox
          ))
      .toList() ?? <Widget>[];
  }
}