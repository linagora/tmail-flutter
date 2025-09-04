import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/list/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_category_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/extensions/toggle_expand_folders_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/mailbox_visibility_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/state/mailbox_visibility_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/widgets/mailbox_visibility_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/widgets/mailbox_visibility_folders_bar_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';

class MailboxVisibilityView extends GetWidget<MailboxVisibilityController>
  with AppLoaderMixin,
    MailboxWidgetMixin {

  MailboxVisibilityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingDetailViewBuilder(
      responsiveUtils: controller.responsiveUtils,
      child: Container(
        color: SettingsUtils.getContentBackgroundColor(
          context,
          controller.responsiveUtils,
        ),
        decoration: SettingsUtils.getBoxDecorationForContent(
          context,
          controller.responsiveUtils,
        ),
        width: double.infinity,
        padding: controller.responsiveUtils.isDesktop(context)
            ? const EdgeInsets.symmetric(vertical: 30, horizontal: 22)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.responsiveUtils.isWebDesktop(context))
              SettingHeaderWidget(
                menuItem: AccountMenuItem.mailboxVisibility,
                textStyle: ThemeUtils.textStyleInter600().copyWith(
                  color: Colors.black.withValues(alpha: 0.9),
                ),
                padding: EdgeInsets.zero,
              )
            else
              const SettingExplanationWidget(
                menuItem: AccountMenuItem.mailboxVisibility,
                padding: EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  bottom: 8,
                ),
                isCenter: true,
                textAlign: TextAlign.center,
              ),
            _buildLoadingView(context),
            Expanded(
              child: _buildListMailbox(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    final isScreenWithShortestSide = controller
        .responsiveUtils
        .isScreenWithShortestSide(context);

    return Obx(
      () => controller.viewState.value.fold(
        (failure) => isScreenWithShortestSide
            ? const SizedBox.shrink()
            : const SizedBox(height: 24),
        (success) => success is LoadingState ||
                success is LoadingBuildTreeMailboxVisibility
            ? loadingWidget
            : isScreenWithShortestSide
                ? const SizedBox.shrink()
                : const SizedBox(height: 24),
      ),
    );
  }

  Widget _buildListMailbox(BuildContext context) {
    Widget bodyListMailbox = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => controller.defaultMailboxIsNotEmpty
              ? _buildMailboxCategory(
                  context,
                  MailboxCategories.exchange,
                  controller.defaultRootNode,
                )
              : const SizedBox.shrink(),
        ),
        Obx(() {
          return MailboxVisibilityFoldersBarWidget(
            imagePaths: controller.imagePaths,
            expandMode: controller.foldersExpandMode.value,
            onToggleExpandFolder: controller.toggleExpandFolders,
          );
        }),
        Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            child: controller.foldersExpandMode.value == ExpandMode.EXPAND
                ? buildFolders(context)
                : const Offstage(),
          ),
        ),
      ],
    );

    if (controller.responsiveUtils.isScreenWithShortestSide(context)) {
      bodyListMailbox = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: bodyListMailbox,
      );
    } else {
      bodyListMailbox = Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        width: 315,
        child: bodyListMailbox,
      );
    }

    return SingleChildScrollView(
      controller: controller.mailboxListScrollController,
      key: const PageStorageKey('mailbox_list'),
      physics: const ClampingScrollPhysics(),
      child: controller.responsiveUtils.isScreenWithShortestSide(context)
        ? bodyListMailbox
        : Row(
          children: [
            Flexible(child: bodyListMailbox),
            const Spacer(),
          ],
        ),
    );
  }

  Widget buildFolders(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          if (controller.personalMailboxIsNotEmpty) {
            return _buildMailboxCategory(
              context,
              MailboxCategories.personalFolders,
              controller.personalRootNode,
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.teamMailboxesIsNotEmpty) {
            return _buildMailboxCategory(
              context,
              MailboxCategories.teamMailboxes,
              controller.teamMailboxesRootNode,
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  Widget _buildMailboxCategory(
    BuildContext context,
    MailboxCategories categories,
    MailboxNode mailboxNode,
  ) {
    switch (categories) {
      case MailboxCategories.exchange:
        return _buildBodyMailboxCategory(
          context: context,
          categories: categories,
          mailboxNode: mailboxNode,
        );
      default:
        return Column(
          children: [
            Obx(
              () => MailboxCategoryWidget(
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
                isArrangeLTR: false,
                showIcon: true,
                iconSpace: 8,
                iconColor: AppColor.steelGrayA540,
                padding: const EdgeInsets.symmetric(
                  horizontal: MailboxItemWidgetStyles.itemPadding,
                ),
                height: 40,
              ),
            ),
            Obx(() {
              final categoriesExpandMode =
                  controller.mailboxCategoriesExpandMode.value;

              bool isExpand = categories.getExpandMode(categoriesExpandMode) ==
                  ExpandMode.EXPAND;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                child: isExpand
                    ? _buildBodyMailboxCategory(
                        context: context,
                        categories: categories,
                        mailboxNode: mailboxNode,
                        padding: const EdgeInsetsDirectional.only(start: 10),
                      )
                    : const Offstage(),
              );
            }),
          ],
        );
    }
  }

  Widget _buildBodyMailboxCategory({
    required BuildContext context,
    required MailboxCategories categories,
    required MailboxNode mailboxNode,
    EdgeInsetsGeometry? padding,
  }) {
    final treeView = TreeView(
      key: Key('${categories.keyValue}_mailbox_list'),
      children: _buildListChildTileWidget(context, mailboxNode),
    );

    if (padding != null) {
      return Padding(padding: padding, child: treeView);
    } else {
      return treeView;
    }
  }

  List<Widget> _buildListChildTileWidget(
    BuildContext context,
    MailboxNode parentNode,
  ) {
    return parentNode.childrenItems
      ?.map((mailboxNode) => mailboxNode.hasChildren()
        ? TreeViewChild(
            key: const Key('children_tree_mailbox_child'),
            isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
            paddingChild: const EdgeInsetsDirectional.only(start: 10),
            parent: MailBoxVisibilityFolderTileBuilder(
              mailboxNode: mailboxNode,
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
            mailboxNode: mailboxNode,
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