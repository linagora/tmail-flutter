import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/list/tree_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/mailbox_visibility_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/state/mailbox_visibility_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/widgets/mailbox_visibility_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/widgets/mailbox_visibility_header_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxVisibilityView extends GetWidget<MailboxVisibilityController> with AppLoaderMixin {
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  MailboxVisibilityView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _responsiveUtils.isWebDesktop(context)
          ? AppColor.colorBgDesktop
          : Colors.white,
      body: Container(
        width: double.infinity,
        margin: _responsiveUtils.isWebDesktop(context)
            ? const EdgeInsets.all(24)
            : EdgeInsets.symmetric(horizontal: SettingsUtils.getHorizontalPadding(context, _responsiveUtils)),
        color: _responsiveUtils.isWebDesktop(context) ? null : Colors.white,
        decoration: _responsiveUtils.isWebDesktop(context)
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
                color: Colors.white)
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
              _responsiveUtils.isWebDesktop(context) ? 20 : 0),
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_responsiveUtils.isWebDesktop(context))...[
                    const MailboxVisibilityHeaderWidget(),
                    const Padding(
                      padding:  EdgeInsets.symmetric(vertical: 16),
                      child:  Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
                    ),
                  ],
                  _buildLoadingView(),
                  Expanded(child: _buildListMailbox(context)),
                ]
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is LoadingState) {
          return const Center(
            child: Padding(
                padding: EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CupertinoActivityIndicator(
                    color: AppColor.colorTextButton,
                  ),
                )),
          );
        } else if (success is LoadingBuildTreeMailboxVisibility) {
          return const Center(
            child: Padding(
                padding: EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CupertinoActivityIndicator(
                    color: AppColor.colorTextButton,
                  ),
                )),
          );
        }
        return const SizedBox.shrink();
      }));
  }

  Widget _buildListMailbox(BuildContext context) {
    return SingleChildScrollView(
        controller: controller.mailboxListScrollController,
        key: const PageStorageKey('mailbox_list'),
        physics: const ClampingScrollPhysics(),
        child: Column(children: [
          Obx(() => controller.defaultMailboxIsNotEmpty
              ? _buildMailboxCategory(context, MailboxCategories.exchange, controller.defaultRootNode)
              : const SizedBox.shrink()),
          const SizedBox(height: 13),
          Obx(() => controller.teamMailboxesIsNotEmpty
              ? _buildMailboxCategory(context, MailboxCategories.teamMailboxes, controller.teamMailboxesRootNode)
              : const SizedBox.shrink()),
          const SizedBox(height: 8),
          Obx(() => controller.personalMailboxIsNotEmpty
              ? _buildMailboxCategory(context, MailboxCategories.personalMailboxes, controller.personalRootNode)
              : const SizedBox.shrink()),

        ])
    );
  }

  Widget _buildHeaderMailboxCategory(BuildContext context, MailboxCategories categories) {
    return Padding(
        padding: const  EdgeInsets.only(top: 10),
        child: Row(children: [
          buildIconWeb(
              splashRadius: 5,
              iconPadding: EdgeInsets.zero,
              minSize: 12,
              icon: SvgPicture.asset(
                  categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
                      ? _imagePaths.icExpandFolder
                      : _imagePaths.icCollapseFolder,
                  color: AppColor.primaryColor,
                  fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).collapse,
              onTap: () => controller.toggleMailboxCategories(categories)),
          Expanded(child: Text(categories.getTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold))),
        ]));
  }

  Widget _buildMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode) {
    if (categories == MailboxCategories.exchange) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: _responsiveUtils.isDesktop(context) ? 24 : 0),
        child: _buildBodyMailboxCategory(context, categories, mailboxNode),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _responsiveUtils.isDesktop(context) ? 24 : 0),
      child: Column(children: [
        _buildHeaderMailboxCategory(context, categories),
        AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            child: categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
                ? _buildBodyMailboxCategory(context, categories, mailboxNode)
                : const Offstage())
      ]),
    );
  }

  Widget _buildBodyMailboxCategory(
    BuildContext context,
    MailboxCategories categories,
    MailboxNode mailboxNode,
  ) {
    final lastNode = mailboxNode.childrenItems?.last;

    return Container(
        padding: EdgeInsets.only(
            right: _responsiveUtils.isDesktop(context) ? 0 : 12,
            left: _responsiveUtils.isDesktop(context) ? 0 : 12),
        child: TreeView(
            key: Key('${categories.keyValue}_mailbox_list'),
            children: _buildListChildTileWidget(
                context,
                mailboxNode,
                lastNode: lastNode)));
  }

  List<Widget> _buildListChildTileWidget(
    BuildContext context,
    MailboxNode parentNode,
    {MailboxNode? lastNode}
  ) {
    return parentNode.childrenItems
        ?.map((mailboxNode) => mailboxNode.hasChildren()
          ? TreeViewChild(
              context,
              key: const Key('children_tree_mailbox_child'),
              isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
              parent: (MailBoxVisibilityFolderTileBuilder(context, _imagePaths, mailboxNode, lastNode: lastNode)
                ..addOnExpandFolderActionClick((mailboxNode) => controller.toggleMailboxFolder(mailboxNode))
                ..addOnSubscribeMailboxActionClick((mailboxNode) => controller.subscribeMailbox(mailboxNode)))
                .build(context),
              children: _buildListChildTileWidget(context, mailboxNode)
          ).build()
          : (MailBoxVisibilityFolderTileBuilder(context, _imagePaths, mailboxNode, lastNode: lastNode)
            ..addOnExpandFolderActionClick((mailboxNode) => controller.toggleMailboxFolder(mailboxNode))
            ..addOnSubscribeMailboxActionClick((mailboxNode) => controller.subscribeMailbox(mailboxNode)))
            .build(context)).toList() ?? <Widget>[];
  }
}