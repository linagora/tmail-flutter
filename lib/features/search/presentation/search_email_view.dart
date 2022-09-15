
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/background/background_widget_builder.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/recent_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/search/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/search/presentation/utils/search_email_utils.dart';
import 'package:tmail_ui_user/features/search/presentation/widgets/app_bar_selection_mode.dart';
import 'package:tmail_ui_user/features/search/presentation/widgets/email_receive_time_action_tile_widget.dart';
import 'package:tmail_ui_user/features/search/presentation/widgets/email_receive_time_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';

class SearchEmailView extends GetWidget<SearchEmailController>
    with AppLoaderMixin {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  SearchEmailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: Colors.white,
          child: Column(children: [
            Container(
                height: 52,
                color: Colors.white,
                padding: SearchEmailUtils.getPaddingAppBar(context, _responsiveUtils),
                child: Obx(() {
                  if (controller.selectionMode.value == SelectMode.ACTIVE) {
                    return AppBarSelectionMode(
                        controller.listResultSearch.listEmailSelected,
                        controller.mailboxDashBoardController.mapMailbox,
                        onCancelSelection: () => controller.cancelSelectionMode(context),
                        onHandleEmailAction: (actionType, listEmails) =>
                            controller.handleSelectionEmailAction(context, actionType, listEmails));
                  } else {
                    return _buildSearchInputForm(context);
                  }
                })
            ),
            const Divider(color: AppColor.colorDividerComposer, height: 1),
            _buildListSearchFilterAction(context),
            _buildLoadingView(),
            Expanded(child: Obx(() {
              if (controller.searchIsRunning.isFalse) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(children: [
                    if (controller.currentSearchText.value.isNotEmpty)
                      _buildShowAllResultSearchButton(context, controller.currentSearchText.value),
                    if (controller.listSuggestionSearch.isNotEmpty && controller.currentSearchText.isNotEmpty)
                      _buildListSuggestionSearch(context, controller.listSuggestionSearch)
                    else if (controller.listRecentSearch.isNotEmpty && controller.listSuggestionSearch.isEmpty)
                      _buildListRecentSearch(context, controller.listRecentSearch)
                  ]),
                );
              } else {
                if (controller.listResultSearch.isNotEmpty) {
                  return Container(
                      color: Colors.white,
                      child: _buildListEmailBody(context, controller.listResultSearch)
                  );
                } else {
                  return _buildEmptyEmail(context);
                }
              }
            })),
            _buildLoadingViewLoadMore(),
          ]),
        ),
      ),
    );
  }

  Widget _buildSearchInputForm(BuildContext context) {
    return Row(
        children: [
          buildIconWeb(
              icon: SvgPicture.asset(_imagePaths.icBack,
                  width: 18,
                  height: 18,
                  color: AppColor.colorTextButton,
                  fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).back,
              onTap: () => controller.closeSearchView(context)
          ),
          Expanded(child: (TextFieldBuilder()
            ..onChange(controller.onTextSearchChange)
            ..textInputAction(TextInputAction.search)
            ..addController(controller.textInputSearchController)
            ..addFocusNode(controller.textInputSearchFocus)
            ..textStyle(const TextStyle(color: Colors.black, fontSize: 16))
            ..keyboardType(TextInputType.text)
            ..onSubmitted((value) {
              final query = value.trim();
              if (query.isNotEmpty) {
                controller.saveRecentSearch(RecentSearch.now(query));
                controller.submitSearchAction(context, query);
              }
            })
            ..maxLines(1)
            ..textDecoration(InputDecoration(
                contentPadding: const EdgeInsets.all(12),
                hintText: AppLocalizations.of(context).search_emails,
                fillColor: Colors.redAccent,
                hintStyle: const TextStyle(
                    color: AppColor.loginTextFieldHintColor,
                    fontSize: 16),
                border: InputBorder.none)))
              .build()),
          Obx(() {
            if (controller.currentSearchText.isNotEmpty) {
              return
                buildIconWeb(
                    icon: SvgPicture.asset(
                        _imagePaths.icClearTextSearch,
                        width: 18,
                        height: 18,
                        fit: BoxFit.fill),
                    tooltip: AppLocalizations.of(context).clearAll,
                    onTap: controller.clearAllTextInputSearchForm);
            } else {
              return const SizedBox.shrink();
            }
          })
        ]
    );
  }

  Widget _buildListSearchFilterAction(BuildContext context) {
    return Container(
      margin: SearchEmailUtils.getMarginSearchFilterButton(context, _responsiveUtils),
      padding: SearchEmailUtils.getPaddingSearchFilterButton(context, _responsiveUtils),
      height: 60,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: QuickSearchFilter.values.length,
          itemBuilder: (context, index) {
            return _buildQuickSearchFilterButton(
                context,
                QuickSearchFilter.values[index]);
          }
      ),
    );
  }

  Widget _buildQuickSearchFilterButton(BuildContext context, QuickSearchFilter filter) {
    return Obx(() {
      final filterSelected = controller.checkQuickSearchFilterSelected(filter);

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: () {
            if (filter != QuickSearchFilter.last7Days) {
              controller.selectQuickSearchFilter(context, filter);
            } else if (_responsiveUtils.isMobile(context)) {
              controller.openContextMenuAction(
                  context,
                  _emailReceiveTimeCupertinoActionTile(
                      context,
                      controller.emailReceiveTimeType.value,
                      (receiveTime) => controller.selectReceiveTimeQuickSearchFilter(context, receiveTime)));
            }
          },
          onTapDown: (detail) {
            if (filter == QuickSearchFilter.last7Days &&
                !_responsiveUtils.isMobile(context)) {
              final screenSize = MediaQuery.of(context).size;
              final offset = detail.globalPosition;
              final position = RelativeRect.fromLTRB(
                offset.dx,
                offset.dy,
                screenSize.width - offset.dx,
                screenSize.height - offset.dy,
              );
              controller.openPopupMenuAction(
                  context,
                  position,
                  _popupMenuEmailReceiveTimeType(
                      context,
                      controller.emailReceiveTimeType.value,
                      (receiveTime) => controller.selectReceiveTimeQuickSearchFilter(context, receiveTime)));
            }
          },
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: filter.getBackgroundColor(quickSearchFilterSelected: filterSelected)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SvgPicture.asset(
                    filter.getIcon(_imagePaths, quickSearchFilterSelected: filterSelected),
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill),
                const SizedBox(width: 4),
                Text(
                  filter.getTitle(context, receiveTimeType: controller.emailReceiveTimeType.value),
                  maxLines: 1,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                  softWrap: CommonTextStyle.defaultSoftWrap,
                  style: filter.getTextStyle(quickSearchFilterSelected: filterSelected),
                ),
                if (filter == QuickSearchFilter.last7Days)
                  ... [
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                        _imagePaths.icChevronDown,
                        width: 16,
                        height: 16,
                        fit: BoxFit.fill),
                  ]
              ])
          ),
        ),
      );
    });
  }

  List<PopupMenuEntry> _popupMenuEmailReceiveTimeType(
      BuildContext context,
      EmailReceiveTimeType? receiveTimeSelected,
      Function(EmailReceiveTimeType?)? onCallBack
      ) {
    return EmailReceiveTimeType.values
        .map((timeType) => PopupMenuItem(
        padding: EdgeInsets.zero,
        child: EmailReceiveTimeActionTileWidget(
            receiveTimeSelected: receiveTimeSelected,
            receiveTimeType: timeType,
            onCallBack: onCallBack)))
        .toList();
  }

  List<Widget> _emailReceiveTimeCupertinoActionTile(
      BuildContext context,
      EmailReceiveTimeType? receiveTimeSelected,
      Function(EmailReceiveTimeType?)? onCallBack
  ) {
    return EmailReceiveTimeType.values
        .map((timeType) => (EmailReceiveTimeCupertinoActionSheetActionBuilder(
                timeType.getTitle(context),
                timeType,
                timeTypeCurrent: receiveTimeSelected,
                iconLeftPadding: _responsiveUtils.isMobile(context)
                    ? const EdgeInsets.only(left: 12, right: 16)
                    : const EdgeInsets.only(right: 12),
                iconRightPadding: _responsiveUtils.isMobile(context)
                    ? const EdgeInsets.only(right: 12)
                    : EdgeInsets.zero,
                actionSelected: SvgPicture.asset(
                    _imagePaths.icFilterSelected,
                    width: 20,
                    height: 20,
                    fit: BoxFit.fill))
            ..onActionClick((timeType) => onCallBack?.call(timeType == receiveTimeSelected ? null : timeType)))
            .build())
        .toList();
  }

  Widget _buildShowAllResultSearchButton(BuildContext context, String textSearch) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final query = textSearch.trim();
          if (query.isNotEmpty) {
            controller.saveRecentSearch(RecentSearch.now(query));
            controller.showAllResultSearchAction(context, query);
          }
        },
        child: Padding(
            padding: SearchEmailUtils.getPaddingShowAllResultButton(context, _responsiveUtils),
            child: Row(children: [
              Text(AppLocalizations.of(context).showingResultsFor,
                  style: const TextStyle(fontSize: 13.0,
                      color: AppColor.colorTextButtonHeaderThread,
                      fontWeight: FontWeight.w500)
              ),
              const SizedBox(width: 4),
              Expanded(child: Text('"${controller.currentSearchText.value}"',
                  style: const TextStyle(
                      fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)))
            ])
        ),
      ),
    );
  }

  Widget _buildListRecentSearch(
      BuildContext context,
      List<RecentSearch> listRecentSearch
  ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: SearchEmailUtils.getPaddingSearchRecentTitle(context, _responsiveUtils),
          child: Text(AppLocalizations.of(context).recent,
              style: const TextStyle(fontSize: 13.0,
                  color: AppColor.colorTextButtonHeaderThread,
                  fontWeight: FontWeight.w500)
          )
      ),
      ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: listRecentSearch.length,
          itemBuilder: (context, index) {
            final recentSearch = listRecentSearch[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                child: RecentSearchItemTileWidget(
                    recentSearch,
                    contentPadding: SearchEmailUtils.getPaddingListRecentSearch(context, _responsiveUtils)),
                onTap: () => controller.searchEmailByRecentAction(context, recentSearch),
              ),
            );
          })
    ]);
  }

  Widget _buildListSuggestionSearch(
      BuildContext context,
      List<PresentationEmail> listSuggestionSearch
  ) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: listSuggestionSearch.length,
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              child: EmailQuickSearchItemTileWidget(
                  listSuggestionSearch[index],
                  controller.currentMailbox,
                  contentPadding: SearchEmailUtils.getPaddingSearchSuggestionList(context, _responsiveUtils)),
              onTap: () => controller.previewEmail(context, listSuggestionSearch[index]),
            ),
          );
        });
  }

  Widget _buildEmptyEmail(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
        (failure) => const SizedBox.shrink(),
        (success) => success is! SearchingState
            ? (BackgroundWidgetBuilder(context)
                  ..image(SvgPicture.asset(
                      _imagePaths.icEmptyImageDefault,
                      width: 120,
                      height: 120,
                      fit: BoxFit.fill))
                  ..text(AppLocalizations.of(context).no_emails_matching_your_search))
              .build()
            : const SizedBox.shrink())
    );
  }

  Widget _buildListEmailBody(BuildContext context, List<PresentationEmail> listPresentationEmail) {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification
              && controller.searchMoreState != SearchMoreState.waiting
              && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            controller.searchMoreEmailsAction();
          }
          return false;
        },
        child: ListView.builder(
            controller: controller.resultSearchScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            key: const PageStorageKey('list_presentation_email_in_search_view'),
            itemExtent: _getItemExtent(context),
            itemCount: listPresentationEmail.length,
            itemBuilder: (context, index) => Obx(() => (EmailTileBuilder(
                context,
                listPresentationEmail[index],
                controller.selectionMode.value,
                SearchStatus.ACTIVE,
                controller.searchQuery,
                padding: SearchEmailUtils.getPaddingSearchResultList(context, _responsiveUtils),
                paddingDivider: SearchEmailUtils.getPaddingDividerSearchResultList(context, _responsiveUtils),
                mailboxCurrent: listPresentationEmail[index].findMailboxContain(
                    controller.mailboxDashBoardController.mapMailbox))
              ..addOnPressEmailActionClick((action, email) =>
                  controller.pressEmailAction(
                      context,
                      action,
                      email,
                      mailboxContain: email.findMailboxContain(
                          controller.mailboxDashBoardController.mapMailbox)))
              ..addOnMoreActionClick((email, position) => _responsiveUtils.isMobile(context)
                  ? controller.openContextMenuAction(context, _contextMenuActionTile(context, email))
                  : controller.openPopupMenuAction(context, position, _popupMenuActionTile(context, email))))
              .build()))
    );
  }

  double? _getItemExtent(BuildContext context) {
    if (BuildUtils.isWeb) {
      return _responsiveUtils.isDesktop(context) ? 52 : 95;
    } else {
      return null;
    }
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
        (failure) => const SizedBox.shrink(),
        (success) => success is SearchingState
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: loadingWidget)
            : const SizedBox.shrink()));
  }

  List<Widget> _contextMenuActionTile(BuildContext context, PresentationEmail email) {
    return <Widget>[
      _markAsEmailSpamOrUnSpamAction(context, email),
    ];
  }

  Widget _markAsEmailSpamOrUnSpamAction(BuildContext context, PresentationEmail email) {
    final mailboxContain = email.findMailboxContain(controller.mailboxDashBoardController.mapMailbox);

    return (EmailActionCupertinoActionSheetActionBuilder(
        const Key('mark_as_spam_or_un_spam_action'),
        SvgPicture.asset(
            mailboxContain?.isSpam == true ? _imagePaths.icNotSpam : _imagePaths.icSpam,
            width: 28, height: 28, fit: BoxFit.fill, color: AppColor.colorTextButton),
        mailboxContain?.isSpam == true
            ? AppLocalizations.of(context).remove_from_spam
            : AppLocalizations.of(context).mark_as_spam,
        email,
        iconLeftPadding: _responsiveUtils.isMobile(context)
            ? const EdgeInsets.only(left: 12, right: 16)
            : const EdgeInsets.only(right: 12),
        iconRightPadding: _responsiveUtils.isMobile(context)
            ? const EdgeInsets.only(right: 12)
            : EdgeInsets.zero)
      ..onActionClick((email) => controller.pressEmailAction(context,
          mailboxContain?.isSpam == true
              ? EmailActionType.unSpam
              : EmailActionType.moveToSpam,
          email)))
      .build();
  }

  List<PopupMenuEntry> _popupMenuActionTile(BuildContext context, PresentationEmail email) {
    return [
      PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _markAsEmailSpamOrUnSpamAction(context, email)),
    ];
  }

  Widget _buildLoadingViewLoadMore() {
    return Obx(() => controller.viewState.value.fold(
        (failure) => const SizedBox.shrink(),
        (success) {
          return success is SearchingMoreState
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: loadingWidget)
              : const SizedBox.shrink();
        }));
  }
}