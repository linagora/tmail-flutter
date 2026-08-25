import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/labels/presentation/extensions/handle_label_action_type_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_label_action_type_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_mailbox_action_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/open_app_grid_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/toggle_expand_folders_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_tree_adapter.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_category_tree_source.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_category_tree_source_resolver.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/presentation_label_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_app_bar.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sending_queue_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_label_item.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_mailbox_item.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

abstract class BaseMailboxView extends GetWidget<MailboxController>
    with AppLoaderMixin {

  static const _categoryTreeSourceResolver =
      MailboxSidebarCategoryTreeSourceResolver();
  static const _mailboxListScrollViewKey =
      PageStorageKey<String>('mailbox_list');

  BaseMailboxView({Key? key}) : super(key: key);

  Widget buildMailboxAppBar() {
    return Obx(() {
      final dashboardController = controller.mailboxDashBoardController;
      final accountId = dashboardController.accountId.value;
      final session = dashboardController.sessionCurrent;
      String username = dashboardController.ownEmailAddress.value;
      if (username.trim().isEmpty) {
        username = session?.getOwnEmailAddressOrUsername() ?? '';
      }

      final linagoraApps = dashboardController
          .appGridDashboardController
          .listLinagoraApp;

      final contactSupportCapability = accountId != null && session != null
          ? session.getContactSupportCapability(accountId)
          : null;

      return MailboxAppBar(
        imagePaths: controller.imagePaths,
        username: username,
        openSettingsAction: dashboardController.goToSettings,
        openAppGridAction: linagoraApps.isNotEmpty
          ? () => controller.openAppGrid(linagoraApps)
          : null,
        openContactSupportAction: contactSupportCapability?.isAvailable == true
          ? () => dashboardController.onGetHelpOrReportBug(contactSupportCapability!)
          : null,
      );
    });
  }

  Widget buildSidebarMenu(
    BuildContext context, {
    Widget? primaryAction,
    List<Widget> footerItems = const [],
    Widget? bodyOverlay,
  }) {
    // Resolved below the caller: the ScrollConfiguration a view installs around
    // the sidebar (ScrollbarListView) is not visible from the outer context.
    return Builder(builder: (context) {
      final scrollPhysics = const AlwaysScrollableScrollPhysics().applyTo(
        ScrollConfiguration.of(context).getScrollPhysics(context),
      );

      return LinagoraSidebarMenu(
        controller: controller.mailboxListScrollController,
        scrollViewKey: _mailboxListScrollViewKey,
        physics: scrollPhysics,
        primaryAction: primaryAction,
        sections: [
          LinagoraSidebarMenuSection(
            sliver: SliverMainAxisGroup(
              slivers: [
                _buildDefaultMailboxSliver(),
                _buildSendingQueueSliver(context),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: LinagoraSidebarMenu.sectionSpacing,
                  ),
                ),
                _buildFoldersSliver(context),
                _buildLabelsSliver(context),
              ],
            ),
          ),
        ],
        footerItems: footerItems,
        bodyOverlay: bodyOverlay,
      );
    });
  }

  Widget _buildDefaultMailboxSliver() {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Obx(() =>
              MailboxLoadingBarWidget(viewState: controller.viewState.value)),
        ),
        Obx(() => controller.defaultMailboxIsNotEmpty
            ? _buildMailboxTreeList(controller.defaultRootNode)
            : const SliverToBoxAdapter()),
      ],
    );
  }

  Widget _buildMailboxTreeList(MailboxNode rootNode) {
    final entries = LinagoraSidebarTreeFlattener.flatten(
      roots: rootNode.childrenItems ?? const <MailboxNode>[],
      adapter: mailboxSidebarTreeAdapter,
    );

    return LinagoraSidebarSliverTreeList<MailboxNode>(
      entries: entries,
      itemBuilder: (context, entry) => _buildMailboxItem(context, entry.data),
      maxIndent: double.infinity,
    );
  }

  Widget _buildMailboxItem(
    BuildContext context,
    MailboxNode mailboxNode,
  ) {
    return Consumer(builder: (context, ref, child) {
      final isSearchByStarredOnly = _isSearchByStarredOnly(ref);

      return Obx(() => SidebarMailboxItem(
        mailboxNode: mailboxNode,
        imagePaths: controller.imagePaths,
        isWebDesktop: controller.responsiveUtils.isWebDesktop(context),
        mailboxNodeSelected: controller
            .mailboxDashBoardController
            .selectedMailboxForDisplay,
        isDraggingMailbox: controller
            .mailboxDashBoardController
            .isDraggingMailbox,
        isHighlighted: isFolderHighlighted(mailboxNode, isSearchByStarredOnly),
        onOpenMailboxFolderClick: (mailboxNode) =>
            mailboxNode != null
                ? controller.openMailbox(context, mailboxNode.item)
                : null,
        onExpandFolderActionClick: (mailboxNode) =>
            controller.toggleMailboxFolder(mailboxNode),
        onLongPressMailboxNodeAction: (mailboxNode) =>
            controller.handleLongPressMailboxNodeAction(
              context,
              mailboxNode.item,
            ),
        onDragItemAccepted: controller.handleDragItemAccepted,
        onMenuActionClick: (position, mailboxNode) =>
            controller.openMailboxContextMenuAction(
              context,
              position,
              mailboxNode.item,
            ),
        onEmptyMailboxActionCallback: (mailboxNode) =>
            controller.emptyMailboxAction(context, mailboxNode.item),
      ));
    });
  }

  Widget _buildSendingQueueSliver(BuildContext context) {
    return Obx(() {
      if (!_isSendingQueueDisplayed) return const SliverToBoxAdapter();

      final isSendingQueueSelected = controller
          .mailboxDashBoardController
          .dashboardRoute
          .value == DashboardRoutes.sendingQueue;

      return SliverMainAxisGroup(
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: LinagoraSidebarMenu.sectionSpacing),
          ),
          SliverToBoxAdapter(
            child: SendingQueueMailboxWidget(
              imagePaths: controller.imagePaths,
              responsiveUtils: controller.responsiveUtils,
              listSendingEmails: controller
                .mailboxDashBoardController
                .listSendingEmails,
              onOpenSendingQueueAction: () =>
                  controller.openSendingQueueViewAction(context),
              isSelected: isSendingQueueSelected,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFoldersSliver(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.foldersExpandMode.value.isExpanded;
      final groups = isExpanded
        ? _buildFolderGroups(context)
        : <LinagoraSidebarTreeGroup<MailboxNode>>[];

      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(child: _buildFoldersHeader(context)),
          if (groups.isNotEmpty)
            const SliverToBoxAdapter(
              child: SizedBox(height: LinagoraSpacing.base * 2),
            ),
          if (groups.isNotEmpty)
            LinagoraSidebarSliverGroupedTreeList<MailboxNode>(
              groups: groups,
              adapter: mailboxSidebarTreeAdapter,
              itemBuilder: (context, entry) =>
                  _buildMailboxItem(context, entry.data),
              maxIndent: double.infinity,
            ),
        ],
      );
    });
  }

  Widget _buildFoldersHeader(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final expandMode = controller.foldersExpandMode.value;

    return LinagoraSidebarSectionHeader(
      label: appLocalizations.folders,
      expanded: expandMode.isExpanded,
      onExpandTogglePressed: (_) => controller.toggleExpandFolders(),
      expandToggleLabel: expandMode.getTooltipMessage(appLocalizations),
      actions: [
        _buildSectionHeaderAction(
          context,
          key: const Key(UiKeys.mailboxSearchButton),
          icon: controller.imagePaths.icSearchBar,
          semanticLabel: appLocalizations.searchForFolders,
          onTap: () => controller.openSearchViewAction(context),
        ),
        _buildSectionHeaderAction(
          context,
          key: const Key(UiKeys.addNewFolderButton),
          icon: controller.imagePaths.icAddNewFolder,
          semanticLabel: appLocalizations.newFolder,
          onTap: () => controller.goToCreateNewMailboxView(context),
        ),
      ],
    );
  }

  List<MailboxSidebarCategoryTreeSource>
      get _mailboxSidebarFolderTreeSources =>
          _categoryTreeSourceResolver.resolveFolderSources(controller);

  Widget _buildSectionHeaderAction(
    BuildContext context, {
    Key? key,
    required String icon,
    required String semanticLabel,
    required VoidCallback onTap,
  }) {
    final style = LinagoraSidebarStyle.of(context);

    return LinagoraSidebarSectionHeaderAction(
      key: key,
      semanticLabel: semanticLabel,
      onTap: onTap,
      iconWidget: SvgPicture.asset(
        icon,
        width: style.itemIconSize,
        height: style.itemIconSize,
        colorFilter: style.resolvedSectionHeaderForeground.asFilter(),
        fit: BoxFit.contain,
      ),
    );
  }

  List<LinagoraSidebarTreeGroup<MailboxNode>> _buildFolderGroups(
    BuildContext context,
  ) => _mailboxSidebarFolderTreeSources
      .where((source) => source.isAvailable)
      .map((source) => _buildFolderCategoryGroup(context, source))
      .toList(growable: false);

  LinagoraSidebarTreeGroup<MailboxNode> _buildFolderCategoryGroup(
    BuildContext context,
    MailboxSidebarCategoryTreeSource source,
  ) {
    return LinagoraSidebarTreeGroup(
      id: source.category.keyValue,
      header: _buildMailboxCategoryItem(context, source.category),
      roots: source.roots,
      expanded: source.isExpanded,
      initialDepth: source.initialDepth,
    );
  }

  Widget _buildMailboxCategoryItem(
    BuildContext context,
    MailboxCategories category,
  ) {
    final expandMode = category.getExpandMode(
      controller.mailboxCategoriesExpandMode.value,
    );
    final style = LinagoraSidebarStyle.of(context);

    return LinagoraSidebarItem(
      label: category.getTitle(context),
      leading: SvgPicture.asset(
        controller.imagePaths.icFolderMailbox,
        width: style.itemIconSize,
        height: style.itemIconSize,
        colorFilter: style.foreground.asFilter(),
        fit: BoxFit.contain,
      ),
      expanded: expandMode.isExpanded,
      onExpandTogglePressed: (_) => controller.toggleMailboxCategories(category),
      expandToggleLabel: expandMode.getTooltipMessage(
        AppLocalizations.of(context),
      ),
      scrollIntoViewOnExpand: true,
      onTap: () => controller.toggleMailboxCategories(category),
    );
  }

  Widget _buildLabelsSliver(BuildContext context) {
    return Obx(() {
      final dashboardController = controller.mailboxDashBoardController;
      if (!dashboardController.isLabelAvailable) {
        return const SliverToBoxAdapter();
      }

      final labelController = dashboardController.labelController;
      final labels = labelController.labels;
      final expandMode = labelController.labelListExpandMode.value;
      final appLocalizations = AppLocalizations.of(context);
      final isLabelListDisplayed = labels.isNotEmpty && expandMode.isExpanded;

      return SliverMainAxisGroup(
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: LinagoraSidebarMenu.sectionSpacing),
          ),
          SliverToBoxAdapter(
            child: LinagoraSidebarSectionHeader(
              key: labelController.labelAppBarKey,
              label: appLocalizations.labels,
              expanded: labels.isNotEmpty ? expandMode.isExpanded : null,
              onExpandTogglePressed: labels.isNotEmpty
                ? (_) => labelController.toggleLabelListState()
                : null,
              expandToggleLabel: labels.isNotEmpty
                ? expandMode.getTooltipMessage(appLocalizations)
                : null,
              actions: [
                _buildSectionHeaderAction(
                  context,
                  key: const Key(UiKeys.addNewLabelButton),
                  icon: controller.imagePaths.icAddNewFolder,
                  semanticLabel: appLocalizations.newLabel,
                  onTap: () => labelController.handleLabelActionType(
                    actionType: LabelActionType.create,
                    accountId: controller.accountId,
                  ),
                ),
              ],
            ),
          ),
          if (isLabelListDisplayed)
            const SliverToBoxAdapter(
              child: SizedBox(
                height: LinagoraSidebarMenuSection.defaultHeaderSpacing,
              ),
            ),
          if (isLabelListDisplayed)
            SliverList.list(children: _buildLabelItems(context)),
        ],
      );
    });
  }

  List<Widget> _buildLabelItems(BuildContext context) {
    final dashboardController = controller.mailboxDashBoardController;
    final labelController = dashboardController.labelController;
    final selectedMailbox = dashboardController.selectedMailboxForDisplay;
    final labelIdSelected = selectedMailbox?.isLabelMailbox == true
      ? selectedMailbox?.labelId
      : null;

    return labelController.labels
        .map((label) => SidebarLabelItem(
              key: ValueKey<Id?>(label.id),
              label: label,
              imagePaths: controller.imagePaths,
              isSelected: labelIdSelected != null &&
                  label.id == labelIdSelected,
              shouldAskReadOnly: labelController.shouldAskReadOnly,
              onOpenLabelCallback: (label) => controller.openMailbox(
                context,
                PresentationLabelMailbox.initial(label),
              ),
              onOpenContextMenu: (label, position) =>
                  dashboardController.openLabelPopupMenuAction(
                    context,
                    controller.imagePaths,
                    label,
                    position,
                  ),
              onLongPressLabelItemAction: (label) =>
                  dashboardController.openLabelContextMenuAction(
                    context,
                    controller.imagePaths,
                    label,
                  ),
            ))
        .toList();
  }

  bool get _isSendingQueueDisplayed =>
      controller.mailboxDashBoardController.listSendingEmails.isNotEmpty &&
      PlatformInfo.isMobile;

  bool _isSearchByStarredOnly(WidgetRef ref) {
    final isSearchEmailRunning = ref.watch(
      searchViewStateProvider.select((state) => state.isSearchEmailRunning),
    );
    final isOnlyStarredApplied = ref.watch(
      searchFilterProvider.select((filter) => filter.isOnlyStarredApplied),
    );
    return isSearchEmailRunning && isOnlyStarredApplied;
  }

  bool isFolderHighlighted(
    MailboxNode mailboxNode,
    bool isSearchByStarredOnly,
  ) => mailboxNode.item.isFavorite && isSearchByStarredOnly;
}
