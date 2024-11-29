
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
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
import 'package:tmail_ui_user/features/mailbox/domain/state/search_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/context_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_controller.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/utils/search_mailbox_utils.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/widgets/mailbox_searched_item_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

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
    return Container(
      color: backgroundColor ?? Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(children: [
        Container(
          color: Colors.transparent,
          padding: SearchMailboxUtils.getPaddingAppBar(context, controller.responsiveUtils),
          child: _buildSearchInputForm(context)
        ),
        if (!controller.responsiveUtils.isWebDesktop(context))
          const Divider(color: AppColor.colorDividerComposer, height: 1),
        _buildLoadingView(),
        Expanded(
          child: _buildMailboxListView(context)
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: loadingWidget);
        } else {
          return const SizedBox.shrink();
        }
      }
    ));
  }

  Widget _buildSearchInputForm(BuildContext context) {
    return Row(children: [
      buildIconWeb(
        minSize: SearchMailboxUtils.getIconSize(context, controller.responsiveUtils),
        iconPadding: EdgeInsets.zero,
        splashRadius: SearchMailboxUtils.getIconSplashRadius(context, controller.responsiveUtils),
        icon: SvgPicture.asset(
          controller.imagePaths.icBack,
          colorFilter: AppColor.colorTextButton.asFilter(),
          fit: BoxFit.fill
        ),
        tooltip: AppLocalizations.of(context).back,
        onTap: () => controller.closeSearchView(context)
      ),
      Expanded(child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(controller.responsiveUtils.isWebDesktop(context) ? 12 : 0)),
          color: controller.responsiveUtils.isWebDesktop(context)
            ? AppColor.colorBackgroundSearchMailboxInput
            : Colors.transparent
        ),
        alignment: Alignment.center,
        child: Row(children: [
          Padding(
            padding: SearchMailboxUtils.getPaddingInputSearchIcon(context, controller.responsiveUtils),
            child: buildIconWeb(
              minSize: 40,
              iconPadding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                controller.imagePaths.icSearchBar,
                colorFilter: AppColor.colorTextButton.asFilter(),
                fit: BoxFit.fill
              ),
              tooltip: AppLocalizations.of(context).search,
              onTap: () => controller.handleSearchButtonPressed(context)
            ),
          ),
          Expanded(child: _buildTextFieldSearchInput(context)),
          Obx(() {
            if (controller.currentSearchQuery.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: buildIconWeb(
                  minSize: 40,
                  iconPadding: EdgeInsets.zero,
                  icon: SvgPicture.asset(
                    controller.imagePaths.icClearSearchInput,
                    width: 24,
                    height: 24,
                    fit: BoxFit.fill
                  ),
                  tooltip: AppLocalizations.of(context).clearAll,
                  onTap: controller.clearAllTextInputSearchForm),
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
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.normal),
      keyboardType: TextInputType.text,
      onTextSubmitted: (text) => controller.onTextSearchSubmitted(context, text),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        hintText: AppLocalizations.of(context).searchForFolders,
        hintStyle: const TextStyle(
          color: AppColor.loginTextFieldHintColor,
          fontSize: 15,
          fontWeight: FontWeight.normal),
        border: InputBorder.none
      ),
    );
  }

  Widget _buildMailboxListView(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        padding: SearchMailboxUtils.getPaddingListViewMailboxSearched(context, controller.responsiveUtils),
        key: const Key('list_mailbox_searched'),
        itemCount: controller.listMailboxSearched.length,
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
    final bool subaddressingSupported = MailboxWidgetMixin.isSubaddressingSupported(
        controller.dashboardController.sessionCurrent,
        controller.dashboardController.accountId.value);

    final contextMenuActions = listContextMenuItemAction(
      mailbox,
      controller.dashboardController.enableSpamReport,
      subaddressingSupported
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
        isFocusedMenu: true
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
                colorFilter: contextMenuItem.action.getColorContextMenuIcon().asFilter()
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(
                contextMenuItem.action.getTitleContextMenu(context),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: contextMenuItem.action.getColorContextMenuTitle()
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
    final bool subaddressingSupported = MailboxWidgetMixin.isSubaddressingSupported(
        controller.dashboardController.sessionCurrent,
        controller.dashboardController.accountId.value);

    final contextMenuActions = listContextMenuItemAction(
      mailbox,
      controller.dashboardController.enableSpamReport,
      subaddressingSupported
    );

    if (contextMenuActions.isEmpty) {
      return;
    }

    if (controller.responsiveUtils.isScreenWithShortestSide(context) || position == null) {
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
      controller.openPopupMenuAction(
        context,
        position,
        popupMenuMailboxActionTiles(
          context,
          controller.imagePaths,
          mailbox,
          contextMenuActions,
          handleMailboxAction: controller.handleMailboxAction
        )
      );
    }
  }
}