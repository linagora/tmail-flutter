
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:focused_menu_custom/modals.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/search_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/context_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_controller.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/widgets/mailbox_searched_item_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SearchMailboxView extends GetWidget<SearchMailboxController>
  with AppLoaderMixin,
    MailboxWidgetMixin {

  final Color? backgroundColor;

  const SearchMailboxView({
    Key? key,
    this.backgroundColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: PlatformInfo.isWeb
          ? PointerInterceptor(child: _buildSearchBody(context))
          : SafeArea(child: _buildSearchBody(context)),
      ),
    );
  }

  Widget _buildSearchBody(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? Colors.white,
      child: Column(children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 12,
          ),
          child: _buildSearchInputForm(context),
        ),
        _buildLoadingView(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildMailboxListView(context),
          )
        )
      ]),
    );
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is LoadingSearchMailbox) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: loadingWidget);
        } else {
          return const SizedBox.shrink();
        }
      }
    ));
  }

  Widget _buildSearchInputForm(BuildContext context) {
    return Row(children: [
      TMailButtonWidget.fromIcon(
        icon: controller.imagePaths.icBack,
        iconColor: AppColor.steelGray400,
        backgroundColor: Colors.transparent,
        width: 36,
        height: 36,
        margin: const EdgeInsetsDirectional.only(end: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        tooltipMessage: AppLocalizations.of(context).back,
        onTapActionCallback: () => controller.closeSearchView(context),
      ),
      Expanded(child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: AppColor.searchInputBackground
        ),
        alignment: Alignment.center,
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TMailButtonWidget.fromIcon(
              icon: controller.imagePaths.icSearchBar,
              iconColor: AppColor.steelGray400,
              iconSize: 22,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tooltipMessage: AppLocalizations.of(context).search,
              onTapActionCallback: () =>
                  controller.handleSearchButtonPressed(context)
            ),
          ),
          Expanded(child: _buildTextFieldSearchInput(context)),
          Obx(() {
            if (controller.currentSearchQuery.isNotEmpty) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: TMailButtonWidget.fromIcon(
                  icon: controller.imagePaths.icClearSearchInput,
                  iconColor: AppColor.steelGray400,
                  iconSize: 22,
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.all(4),
                  tooltipMessage: AppLocalizations.of(context).clearAll,
                  onTapActionCallback: controller.clearAllTextInputSearchForm,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          })
        ])
      ))
    ]);
  }

  Widget _buildTextFieldSearchInput(BuildContext context) {
    return TextFieldBuilder(
      onTextChange: controller.onTextSearchChange,
      textInputAction: TextInputAction.search,
      autoFocus: true,
      maxLines: 1,
      controller: controller.textInputSearchController,
      textDirection: DirectionUtils.getDirectionByLanguage(context),
      textStyle: ThemeUtils.textStyleBodyBody2(
        color: Colors.black,
      ),
      keyboardType: TextInputType.text,
      onTextSubmitted: (text) => controller.onTextSearchSubmitted(context, text),
      decoration: InputDecoration(
        contentPadding: const EdgeInsetsDirectional.only(
          end: 12,
          bottom: 14,
          top: 14,
        ),
        hintText: AppLocalizations.of(context).searchForFolders,
        hintStyle: ThemeUtils.textStyleBodyBody2(
          color: AppColor.steelGray400,
        ),
        border: InputBorder.none
      ),
    );
  }

  Widget _buildMailboxListView(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        key: const Key('list_mailbox_searched'),
        itemCount: controller.listMailboxSearched.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          return LayoutBuilder(builder: (context, constraints) {
            final mailboxCurrent = controller.listMailboxSearched[index];
            return MailboxSearchedItemBuilder(
              controller.imagePaths,
              controller.responsiveUtils,
              mailboxCurrent,
              maxWidth: constraints.maxWidth,
              onDragEmailToMailboxAccepted: controller.dashboardController.dragSelectedMultipleEmailToMailboxAction,
              onClickOpenMailboxAction: (mailbox) => controller.openMailboxAction(context, mailbox),
              onClickOpenMenuMailboxAction: (position, mailbox) => _openMailboxMenuAction(context, mailbox, position: position),
              onLongPressMailboxAction: (mailbox) => _openMailboxMenuAction(context, mailbox),
              listPopupMenuItemAction: _listPopupMenuItemAction(context, mailboxCurrent)
            );
          });
        }
      );
    });
  }

  List<FocusedMenuItem> _listPopupMenuItemAction(BuildContext context, PresentationMailbox mailbox) {
    final session = controller.dashboardController.sessionCurrent;
    final accountId = controller.dashboardController.accountId.value;

    final deletedMessageVaultSupported =
      MailboxUtils.isDeletedMessageVaultSupported(session, accountId);

    final isSubAddressingSupported =
      session?.isSubAddressingSupported(accountId) ?? false;

    final contextMenuActions = listContextMenuItemAction(
      mailbox,
      controller.dashboardController.enableSpamReport,
      deletedMessageVaultSupported,
      isSubAddressingSupported,
    );
    return contextMenuActions
      .map((action) => _mailboxFocusedMenuItem(context, action, mailbox))
      .toList();
  }

  FocusedMenuItem _mailboxFocusedMenuItem(
    BuildContext context,
    ContextMenuItemMailboxAction contextMenuItem,
    PresentationMailbox mailbox
  ) {
    return FocusedMenuItem(
      backgroundColor: Colors.white,
      onPressed: () => controller.handleMailboxAction(
        context,
        contextMenuItem.action,
        mailbox,
      ),
      title: Expanded(
        child: AbsorbPointer(
          absorbing: !contextMenuItem.isActivated,
          child: Opacity(
            opacity: contextMenuItem.isActivated ? 1.0 : 0.3,
            child: Row(children: [
              SvgPicture.asset(
                contextMenuItem.action.getContextMenuIcon(controller.imagePaths),
                width: 24,
                height: 24,
                fit: BoxFit.fill,
                colorFilter: contextMenuItem.action.getContextMenuIconColor().asFilter()
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(
                contextMenuItem.action.getContextMenuTitle(AppLocalizations.of(context)),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: contextMenuItem.action.getContextMenuTitleColor()
                )
              )),
            ]),
          ),
        ),
      )
    );
  }

  void _openMailboxMenuAction(
    BuildContext context,
    PresentationMailbox mailbox,
    {RelativeRect? position}
  ) {
    final session = controller.dashboardController.sessionCurrent;
    final accountId = controller.dashboardController.accountId.value;

    final deletedMessageVaultSupported =
      MailboxUtils.isDeletedMessageVaultSupported(session, accountId);

    final isSubAddressingSupported =
      session?.isSubAddressingSupported(accountId) ?? false;

    if (controller.responsiveUtils.isScreenWithShortestSide(context) || position == null) {
      final contextMenuActions = listContextMenuItemAction(
        mailbox,
        controller.dashboardController.enableSpamReport,
        deletedMessageVaultSupported,
        isSubAddressingSupported,
      );

      if (contextMenuActions.isEmpty) return;

      controller.openContextMenuAction(
        context,
        contextMenuMailboxActionTiles(
          context,
          controller.imagePaths,
          mailbox,
          contextMenuActions,
          handleMailboxAction: controller.handleMailboxAction
        )
      );
    } else {
      final popupMenuActions = getListPopupMenuItemAction(
        AppLocalizations.of(context),
        controller.imagePaths,
        mailbox,
        controller.dashboardController.enableSpamReport,
        deletedMessageVaultSupported,
        isSubAddressingSupported,
      );

      if (popupMenuActions.isEmpty) return;

      final popupMenuItems = popupMenuActions.map((menuAction) {
        return PopupMenuItem(
          padding: EdgeInsets.zero,
          child: PopupMenuItemActionWidget(
            menuAction: menuAction,
            menuActionClick: (menuAction) {
              popBack();
              controller.handleMailboxAction(
                context,
                menuAction.action,
                mailbox,
              );
            },
          ),
        );
      }).toList();

      controller.openPopupMenuAction(context, position, popupMenuItems);
    }
  }
}