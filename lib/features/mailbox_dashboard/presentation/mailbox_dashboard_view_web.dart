import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/network_connection_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view_web.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/filter_email_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/user_setting_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/recent_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/app_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/reading_pane.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/filter_message_option_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxDashBoardView extends GetWidget<MailboxDashBoardController> with NetworkConnectionMixin,
    UserSettingPopupMenuMixin, FilterEmailPopupMenuMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  MailboxDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.isDrawerOpen && (_responsiveUtils.isDesktop(context) || _responsiveUtils.isTabletLarge(context))) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        controller.closeMailboxMenuDrawer();
      });
    }

    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: Colors.white,
      drawer: ResponsiveWidget(
          responsiveUtils: _responsiveUtils,
          mobile: SizedBox(child: MailboxView(), width: _responsiveUtils.defaultSizeDrawer),
          tablet: SizedBox(child: MailboxView(), width: _responsiveUtils.defaultSizeDrawer),
          tabletLarge: const SizedBox.shrink(),
          desktop: const SizedBox.shrink(),
      ),
      drawerEnableOpenDragGesture: _responsiveUtils.isMobile(context) || _responsiveUtils.isTablet(context),
      body: Stack(children: [
        ResponsiveWidget(
            responsiveUtils: _responsiveUtils,
            desktop: Column(children: [
              Row(children: [
                Container(width: 256, color: Colors.white,
                  padding: const EdgeInsets.only(top: 25, bottom: 25, left: 32),
                  child: Row(children: [
                    (SloganBuilder(arrangedByHorizontal: true)
                        ..setSloganText(AppLocalizations.of(context).app_name)
                        ..setSloganTextAlign(TextAlign.center)
                        ..setSloganTextStyle(const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))
                        ..setSizeLogo(24)
                        ..setLogo(_imagePaths.icLogoTMail))
                      .build(),
                    Obx(() {
                      if (controller.appInformation.value != null) {
                        return Padding(padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'v.${controller.appInformation.value!.version}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.w500),
                          ));
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ])
                ),
                Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 10, top: 16, bottom: 10, left: 48),
                  child: _buildRightHeader(context)))
              ]),
              Expanded(child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(child: MailboxView(), width: _responsiveUtils.defaultSizeMenu),
                  Expanded(child: _wrapContainerForThreadAndEmail(context))
                ],
              ))
            ]),
            tabletLarge: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(child: MailboxView(), width: _responsiveUtils.defaultSizeDrawer),
                Expanded(child: _wrapContainerForThreadAndEmail(context))
              ],
            ),
            tablet: ThreadView(),
            mobile: ThreadView(),
        ),
        Obx(() => controller.dashBoardAction.value is ComposeEmailAction
            ? ComposerView()
            : const SizedBox.shrink()),
        Obx(() => controller.isNetworkConnectionAvailable()
            ? const SizedBox.shrink()
            : Align(alignment: Alignment.bottomCenter, child: buildNetworkConnectionWidget(context))),
      ]),
    );
  }

  Widget _wrapContainerForThreadAndEmail(BuildContext context) {
    switch(AppSetting.readingPane) {
      case ReadingPane.noSplit:
        return Obx(() {
          switch(controller.routePath.value) {
            case AppRoutes.THREAD:
              return ThreadView();
            case AppRoutes.EMAIL:
              return EmailView();
            default:
              return const SizedBox.shrink();
          }
        });
      case ReadingPane.rightOfInbox:
        if (_responsiveUtils.isDesktop(context)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: ThreadView()),
              Expanded(flex: 2, child: EmailView()),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: ThreadView()),
              Expanded(flex: 1, child: EmailView()),
            ],
          );
        }
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRightHeader(BuildContext context) {
    return Row(children: [
      Obx(() {
        if (controller.isSelectionEnabled()) {
          return _buildListButtonTopBarSelection(context);
        } else {
          return controller.isSearchActive()
            ? _buildListButtonTopBarSearchActive(context)
            : _buildListButtonTopBar(context);
        }
      }),
      const SizedBox(width: 16),
      Obx(() => !controller.isSearchActive() ? const Spacer() : const SizedBox.shrink()),
      Obx(() => controller.isSearchActive()
          ? Expanded(child: _buildSearchForm(context))
          : const SizedBox.shrink()),
      Obx(() => !controller.isSearchActive()
          ? (SearchBarView(_imagePaths)
                ..hintTextSearch(AppLocalizations.of(context).search_emails)
                ..maxSizeWidth(240)
                ..addOnOpenSearchViewAction(() => controller.enableSearch()))
              .build()
          : const SizedBox.shrink()),
      Obx(() => !controller.isSearchActive() ? const SizedBox(width: 16) : const SizedBox.shrink()),
      Obx(() => (AvatarBuilder()
          ..text(controller.userProfile.value?.getAvatarText() ?? '')
          ..backgroundColor(Colors.white)
          ..textColor(Colors.black)
          ..context(context)
          ..addOnTapAvatarActionWithPositionClick((position) =>
              controller.openPopupMenuAction(context, position, popupMenuUserSettingActionTile(context,
                  controller.userProfile.value,
                  onLogoutAction: () {
                    popBack();
                    controller.logoutAction();
                  },
                  onSettingAction: () {
                    popBack();
                    controller.goToSettings();
                  })))
          ..addBoxShadows([const BoxShadow(
              color: AppColor.colorShadowBgContentEmail,
              spreadRadius: 1, blurRadius: 1, offset: Offset(0, 0.5))])
          ..size(48))
        .build()),
      const SizedBox(width: 16)
    ]);
  }

  Widget _buildListButtonTopBar(BuildContext context) {
    return Row(children: [
      (ButtonBuilder(_imagePaths.icRefresh)
          ..key(const Key('button_reload_thread'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(EdgeInsets.zero)
          ..size(16)
          ..radiusSplash(10)
          ..padding(const EdgeInsets.symmetric(horizontal: 8, vertical: 8))
          ..onPressActionClick(() => controller.dispatchAction(RefreshAllEmailAction())))
        .build(),
      const SizedBox(width: 16),
      (ButtonBuilder(_imagePaths.icSelectAll)
          ..key(const Key('button_select_all'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..radiusSplash(10)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButtonHeaderThread))
          ..onPressActionClick(() => controller.dispatchAction(SelectionAllEmailAction()))
          ..text(AppLocalizations.of(context).select_all, isVertical: false))
        .build(),
      const SizedBox(width: 16),
      (ButtonBuilder(_imagePaths.icMarkAllAsRead)
          ..key(const Key('button_mark_all_as_read'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..radiusSplash(10)
          ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButtonHeaderThread))
          ..onPressActionClick(() => controller.dispatchAction(MarkAsReadAllEmailAction()))
          ..text(AppLocalizations.of(context).mark_all_as_read, isVertical: false))
        .build(),
      const SizedBox(width: 16),
      Obx(() => (ButtonBuilder(_imagePaths.icFilterWeb)
          ..key(const Key('button_filter_messages'))
          ..context(context)
          ..decoration(BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..radiusSplash(10)
          ..textStyle(TextStyle(
              fontSize: 12,
              color: controller.filterMessageOption.value == FilterMessageOption.all
                  ? AppColor.colorTextButtonHeaderThread
                  : AppColor.colorNameEmail,
              fontWeight: controller.filterMessageOption.value == FilterMessageOption.all
                  ? FontWeight.normal
                  : FontWeight.w500))
          ..addIconAction(Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SvgPicture.asset(_imagePaths.icArrowDown, fit: BoxFit.fill)))
          ..addOnPressActionWithPositionClick((position) => controller.openPopupMenuAction(context, position,
              popupMenuFilterEmailActionTile(context,
                  controller.filterMessageOption.value,
                  (option) => controller.dispatchAction(FilterMessageAction(context, option)))))
          ..text(controller.filterMessageOption.value == FilterMessageOption.all
              ? AppLocalizations.of(context).filter_messages
              : controller.filterMessageOption.value.getTitle(context), isVertical: false))
        .build()),
    ]);
  }

  Widget _buildListButtonTopBarSearchActive(BuildContext context) {
    return Row(children: [
      (ButtonBuilder(_imagePaths.icSelectAll)
          ..key(const Key('button_select_all'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..radiusSplash(10)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButtonHeaderThread))
          ..onPressActionClick(() => controller.dispatchAction(SelectionAllEmailAction()))
          ..text(AppLocalizations.of(context).select_all, isVertical: false))
        .build(),
      const SizedBox(width: 16),
      (ButtonBuilder(_imagePaths.icMarkAllAsRead)
          ..key(const Key('button_mark_all_as_read'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..radiusSplash(10)
          ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButtonHeaderThread))
          ..onPressActionClick(() => controller.dispatchAction(MarkAsReadAllEmailAction()))
          ..text(AppLocalizations.of(context).mark_all_as_read, isVertical: false))
        .build(),
    ]);
  }

  Widget _buildListButtonTopBarSelection(BuildContext context) {
    return Row(children: [
      buildIconWeb(
          icon: SvgPicture.asset(_imagePaths.icCloseComposer, color: AppColor.colorTextButton, fit: BoxFit.fill),
          tooltip: AppLocalizations.of(context).cancel,
          onTap: () => controller.dispatchAction(CancelSelectionAllEmailAction())),
      Obx(() => Text(
          AppLocalizations.of(context).count_email_selected(controller.listEmailSelected.length),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton))),
      const SizedBox(width: 30),
      Obx(() => buildIconWeb(
          icon: SvgPicture.asset(
              controller.listEmailSelected.isAllEmailRead
                  ? _imagePaths.icRead
                  : _imagePaths.icUnread,
              fit: BoxFit.fill),
          tooltip: controller.listEmailSelected.isAllEmailRead
              ? AppLocalizations.of(context).mark_as_unread
              : AppLocalizations.of(context).mark_as_read,
          onTap: () => controller.dispatchAction(
              HandleEmailActionTypeAction(context,
                  controller.listEmailSelected,
                  controller.listEmailSelected.isAllEmailRead
                      ? EmailActionType.markAsUnread
                      : EmailActionType.markAsRead)))),
      Obx(() => buildIconWeb(
          icon: SvgPicture.asset(
              controller.listEmailSelected.isAllEmailStarred
                  ? _imagePaths.icUnStar
                  : _imagePaths.icStar,
              fit: BoxFit.fill),
          tooltip: controller.listEmailSelected.isAllEmailStarred
              ? AppLocalizations.of(context).un_star
              : AppLocalizations.of(context).star,
          onTap: () => controller.dispatchAction(
              HandleEmailActionTypeAction(context,
                  controller.listEmailSelected,
                  controller.listEmailSelected.isAllEmailStarred
                      ? EmailActionType.markAsStarred
                      : EmailActionType.unMarkAsStarred)))),
      Obx(() {
        if (controller.selectedMailbox.value?.isDrafts == false) {
          return buildIconWeb(
              icon: SvgPicture.asset(_imagePaths.icMove, fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).move,
              onTap: () => controller.dispatchAction(
                  HandleEmailActionTypeAction(context,
                      controller.listEmailSelected,
                      EmailActionType.moveToMailbox)));
        } else {
          return const SizedBox.shrink();
        }
      }),
      Obx(() {
        if (controller.selectedMailbox.value?.isDrafts == false) {
          return buildIconWeb(
              icon: SvgPicture.asset(
                  controller.selectedMailbox.value?.isSpam == true
                      ? _imagePaths.icNotSpam
                      : _imagePaths.icSpam,
                  fit: BoxFit.fill),
              tooltip: controller.selectedMailbox.value?.isSpam == true
                  ? AppLocalizations.of(context).un_spam
                  : AppLocalizations.of(context).mark_as_spam,
              onTap: () {
                if (controller.selectedMailbox.value?.isSpam == true) {
                  return controller.dispatchAction(
                      HandleEmailActionTypeAction(context,
                          controller.listEmailSelected,
                          EmailActionType.unSpam));
                } else {
                  return controller.dispatchAction(
                      HandleEmailActionTypeAction(context,
                          controller.listEmailSelected,
                          EmailActionType.moveToSpam));
                }
              });
        } else {
          return const SizedBox.shrink();
        }
      }),
      Obx(() => buildIconWeb(
          icon: SvgPicture.asset(_imagePaths.icDelete, fit: BoxFit.fill),
          tooltip: controller.selectedMailbox.value?.isTrash == true
              ? AppLocalizations.of(context).delete_permanently
              : AppLocalizations.of(context).move_to_trash,
          onTap: () {
            if (controller.selectedMailbox.value?.isTrash == true) {
              return controller.dispatchAction(HandleEmailActionTypeAction(context,
                  controller.listEmailSelected,
                  EmailActionType.deletePermanently));
            } else {
              return controller.dispatchAction(HandleEmailActionTypeAction(context,
                  controller.listEmailSelected,
                  EmailActionType.moveToTrash));
            }
          })),
    ]);
  }

  Widget _buildSearchForm(BuildContext context) {
    return Row(
        children: [
          buildIconWeb(
              icon: SvgPicture.asset(_imagePaths.icBack, color: AppColor.colorTextButton, fit: BoxFit.fill),
              onTap: () {
                controller.disableSearch();
                controller.dispatchAction(CancelSelectionAllEmailAction());
              }),
          Expanded(child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: AppColor.colorBgSearchBar),
            height: 45,
            child: TypeAheadFormFieldQuickSearch<PresentationEmail, RecentSearch>(
                textFieldConfiguration: QuickSearchTextFieldConfiguration(
                    controller: controller.searchInputController,
                    autofocus: true,
                    focusNode: controller.searchFocus,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: AppLocalizations.of(context).search_mail,
                        hintStyle: const TextStyle(color: AppColor.colorHintSearchBar, fontSize: 17.0),
                        labelStyle: const TextStyle(color: AppColor.colorHintSearchBar, fontSize: 17.0)
                    ),
                    leftButton: buildIconWeb(
                        icon: SvgPicture.asset(_imagePaths.icSearchBar, width: 16, height: 16, fit: BoxFit.fill),
                        onTap: () => {}),
                    rightButton: buildIconWeb(
                        icon: SvgPicture.asset(_imagePaths.icComposerClose, width: 18, height: 18, fit: BoxFit.fill),
                        onTap: () {
                          controller.searchInputController.clear();
                          controller.clearSearchText();
                        })
                ),
                suggestionsBoxDecoration: QuickSearchSuggestionsBoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  constraints: BoxConstraints(
                      maxWidth: _responsiveUtils.isDesktop(context) ? 556 : double.infinity,
                      maxHeight: 322),
                ),
                actionButton: Padding(
                  padding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 20),
                  child: Row(
                    children: [
                      (ButtonBuilder(_imagePaths.icAttachmentSB)
                          ..decoration(BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.colorButtonHeaderThread))
                          ..paddingIcon(const EdgeInsets.only(right: 5))
                          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
                          ..radiusSplash(10)
                          ..size(16)
                          ..textStyle(const TextStyle(fontSize: 13, color: AppColor.colorTextButtonHeaderThread))
                          ..onPressActionClick(() => {})
                          ..text(AppLocalizations.of(context).hasAttachment, isVertical: false))
                        .build(),
                      const SizedBox(width: 8),
                      (ButtonBuilder(_imagePaths.icCalendarSB)
                          ..decoration(BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.colorButtonHeaderThread))
                          ..paddingIcon(const EdgeInsets.only(right: 5))
                          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
                          ..radiusSplash(10)
                          ..size(16)
                          ..textStyle(const TextStyle(fontSize: 13, color: AppColor.colorTextButtonHeaderThread))
                          ..onPressActionClick(() => {})
                          ..text(AppLocalizations.of(context).last7Days, isVertical: false))
                        .build(),
                      const SizedBox(width: 8),
                      (ButtonBuilder(_imagePaths.icUserSB)
                          ..decoration(BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.colorButtonHeaderThread))
                          ..paddingIcon(const EdgeInsets.only(right: 5))
                          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
                          ..radiusSplash(10)
                          ..size(16)
                          ..textStyle(const TextStyle(fontSize: 13, color: AppColor.colorTextButtonHeaderThread))
                          ..onPressActionClick(() => {})
                          ..text(AppLocalizations.of(context).fromMe, isVertical: false))
                        .build(),
                    ],
                  ),
                ),
                titleHeaderRecent: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                  child: Text(AppLocalizations.of(context).recent,
                      style: const TextStyle(fontSize: 13.0,
                          color: AppColor.colorTextButtonHeaderThread,
                          fontWeight: FontWeight.w500))),
                getRecentCallback: (pattern) async {
                  return [];
                },
                itemRecentBuilder: (context, recent) {
                  return RecentSearchItemTileWidget(recent);
                },
                suggestionsCallback: (pattern) async {
                  return [];
                },
                itemBuilder: (context, email) {
                  return EmailQuickSearchItemTileWidget(email, controller.selectedMailbox.value);
                },
                onSuggestionSelected: (autoCompleteResult) async {
                }),
          )),
          const SizedBox(width: 16),
        ]
    );
  }
}