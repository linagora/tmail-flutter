import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/contact/presentation/contact_controller.dart';
import 'package:tmail_ui_user/features/contact/presentation/styles/contact_view_style.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/app_bar_contact_widget.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_item_widget.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_list_action_widget.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContactView extends GetWidget<ContactController> {

  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black38,
        body: PointerInterceptor(
          child: GestureDetector(
            onTap: PlatformInfo.isWeb
              ? null
              : FocusScope.of(context).unfocus,
            child: SafeArea(
              bottom: false,
              left: false,
              right: false,
              top: ContactViewStyle.isAppBarTopBorderSupported(
                context,
                controller.responsiveUtils
              ),
              child: Center(
                child: Container(
                  height: ContactViewStyle.getContactViewHeight(
                    context,
                    controller.responsiveUtils
                  ),
                  width: ContactViewStyle.getContactViewWidth(
                    context,
                    controller.responsiveUtils
                  ),
                  decoration: BoxDecoration(
                    borderRadius: ContactViewStyle.getContactViewBorderRadius(
                      context,
                      controller.responsiveUtils
                    ),
                    color: Colors.white
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Obx(() => AppBarContactWidget(
                          title: controller.contactArguments.value?.contactViewTitle,
                          imagePaths: controller.imagePaths,
                          responsiveUtils: controller.responsiveUtils,
                          onCloseContactView: controller.closeContactView,
                        )),
                        Obx(() => SearchAppBarWidget(
                          imagePaths: controller.imagePaths,
                          searchQuery: controller.searchQuery.value,
                          searchFocusNode: controller.textInputSearchFocus,
                          searchInputController: controller.textInputSearchController,
                          hasBackButton: false,
                          hasSearchButton: true,
                          searchIconSize: 20,
                          autoFocus: false,
                          searchIconColor: AppColor.colorHintSearchBar,
                          margin: ContactViewStyle.getSearchInputFormMargin(
                            context,
                            controller.responsiveUtils,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: AppColor.colorBgSearchBar
                          ),
                          hintText: AppLocalizations.of(context).hintSearchInputContact,
                          inputHintTextStyle: ContactViewStyle.searchInputHintTextStyle,
                          inputTextStyle: ContactViewStyle.searchInputTextStyle,
                          onClearTextSearchAction: controller.clearAllTextInputSearchForm,
                          onTextChangeSearchAction: controller.onTextSearchChange,
                          onSearchTextAction: controller.onSearchTextAction,
                        )),
                        Obx(() => ContactLoadingBarWidget(
                          viewState: controller.searchViewState.value,
                        )),
                        Expanded(
                          child: Obx(() {
                            if (controller.searchStatus.value == SearchStatus.ACTIVE) {
                              return _buildSearchedContactListView();
                            } else {
                              return _buildSelectedContactListView();
                            }
                          })
                        ),
                        ContactListActionWidget(
                          onClearFilterAction: controller.handleOnClearFilterAction,
                          onDoneAction: controller.handleOnDoneAction,
                        ),
                      ]
                    ),
                  )
                ),
              ),
            ),
          ),
        )
    );
  }

  Widget _buildSearchedContactListView() {
    return Obx(() {
      if (controller.searchedContactList.isEmpty) {
        return const SizedBox.shrink();
      }

      return ListView.separated(
        itemCount: controller.searchedContactList.length,
        separatorBuilder: (context, index) {
          return Padding(
            padding: ContactViewStyle.getDividerSearchResultListPadding(
              context,
              controller.responsiveUtils
            ),
            child: const Divider(height: 1, color: AppColor.colorDivider),
          );
        },
        itemBuilder: (context, index) {
          return ContactItemWidget(
            emailAddress: controller.searchedContactList[index],
            selectedContactList: controller.selectedContactList,
            imagePaths: controller.imagePaths,
            responsiveUtils: controller.responsiveUtils,
            onSelectContactAction: controller.handleOnSelectContactAction,
            onDeleteContactAction: controller.handleOnDeleteContactAction,
          );
        }
      );
    });
  }

  Widget _buildSelectedContactListView() {
    return Obx(() {
      if (controller.selectedContactList.isEmpty) {
        return const SizedBox.shrink();
      }

      return ListView.separated(
        itemCount: controller.selectedContactList.length,
        separatorBuilder: (context, index) {
          return Padding(
            padding: ContactViewStyle.getDividerSearchResultListPadding(
              context,
              controller.responsiveUtils
            ),
            child: const Divider(height: 1, color: AppColor.colorDivider),
          );
        },
        itemBuilder: (context, index) {
          return ContactItemWidget(
            emailAddress: controller.selectedContactList[index],
            selectedContactList: controller.selectedContactList,
            imagePaths: controller.imagePaths,
            responsiveUtils: controller.responsiveUtils,
            onSelectContactAction: controller.handleOnSelectContactAction,
            onDeleteContactAction: controller.handleOnDeleteContactAction,
          );
        }
      );
    });
  }
}