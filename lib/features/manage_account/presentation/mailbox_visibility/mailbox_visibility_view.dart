import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/list/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/mailbox_visibility_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/utils/mailbox_visibility_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/widgets/mailbox_visibility_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/widgets/mailbox_visibility_header_widget.dart';

class MailboxVisibilityView extends GetWidget<MailboxVisibilityController>
  with AppLoaderMixin,
    MailboxWidgetMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  MailboxVisibilityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingDetailViewBuilder(
      responsiveUtils: _responsiveUtils,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_responsiveUtils.isWebDesktop(context))
            ...[
              const SizedBox(height: 24),
              const MailboxVisibilityHeaderWidget(),
              const SizedBox(height: 16),
              const Divider(
                color: AppColor.colorDividerMailbox,
                height: 0.5,
                thickness: 0.2
              )
            ],
          _buildLoadingView(),
          Expanded(child: Padding(
            padding: MailboxVisibilityUtils.getPaddingListView(context, _responsiveUtils),
            child: _buildListMailbox(context)
          ))
        ]
      ),
    );
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is LoadingState
        ? Padding(padding: const EdgeInsets.only(top: 16), child: loadingWidget)
        : const SizedBox.shrink()));
  }

  Widget _buildListMailbox(BuildContext context) {
    return SingleChildScrollView(
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
              MailboxCategories.personalMailboxes,
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
      buildHeaderMailboxCategory(
        context,
        _responsiveUtils,
        _imagePaths,
        categories,
        controller,
        padding: const EdgeInsets.all(8),
        toggleMailboxCategories: controller.toggleMailboxCategories
      ),
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
            paddingChild: const EdgeInsets.only(left: 10),
            parent: MailBoxVisibilityFolderTileBuilder(
              _imagePaths,
              mailboxNode,
              onClickExpandMailboxNodeAction: controller.toggleMailboxFolder,
              onClickSubscribeMailboxAction: controller.subscribeMailbox
            ),
            children: _buildListChildTileWidget(context, mailboxNode)).build()
        : MailBoxVisibilityFolderTileBuilder(
            _imagePaths,
            mailboxNode,
            onClickExpandMailboxNodeAction: controller.toggleMailboxFolder,
            onClickSubscribeMailboxAction: controller.subscribeMailbox
          ))
      .toList() ?? <Widget>[];
  }
}