
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/contact/presentation/contact_controller.dart';
import 'package:tmail_ui_user/features/contact/presentation/styles/contact_view_style.dart';
import 'package:tmail_ui_user/features/contact/presentation/utils/contact_utils.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/app_bar_contact_widget.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_suggestion_box_item.dart';
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
            onTap: () => FocusScope.of(context).unfocus(),
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
                          searchIconColor: AppColor.colorHintSearchBar,
                          margin: ContactViewStyle.getSearchInputFormMargin(
                            context,
                            controller.responsiveUtils
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
                        if (PlatformInfo.isWeb)
                          Obx(() {
                            final username = controller.session.value?.username.value ?? '';
                            if (username.isNotEmpty) {
                              final userEmailAddress = EmailAddress(
                                AppLocalizations.of(context).me,
                                username);
                              final fromMeSuggestionEmailAddress = SuggestionEmailAddress(userEmailAddress, state: SuggestionEmailState.valid);
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  children: [
                                    ContactSuggestionBoxItem(
                                      fromMeSuggestionEmailAddress,
                                      padding: ContactUtils.getPaddingSearchResultList(context, controller.responsiveUtils),
                                      selectedContactCallbackAction: (contact) {
                                        controller.selectContact(context, contact);
                                      },
                                    ),
                                    Padding(
                                      padding: ContactUtils.getPaddingDividerSearchResultList(context, controller.responsiveUtils),
                                      child: const Divider(height: 1, color: AppColor.colorDivider),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                        Expanded(child: Obx(() {
                          if (controller.listContactSearched.isNotEmpty) {
                            if (PlatformInfo.isMobile) {
                              return Container(
                                color: Colors.white,
                                child: ListView.separated(
                                  itemCount: controller.listContactSearched.length,
                                  separatorBuilder: (context, index) {
                                    return Padding(
                                      padding: ContactUtils.getPaddingDividerSearchResultList(context, controller.responsiveUtils),
                                      child: const Divider(height: 1, color: AppColor.colorDivider),
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    final emailAddress = controller.listContactSearched[index];
                                    final suggestionEmailAddress = _toSuggestionEmailAddress(
                                      emailAddress,
                                      controller.contactSelected != null ? [controller.contactSelected!] : []
                                    );
                                    return ContactSuggestionBoxItem(
                                      suggestionEmailAddress,
                                      padding: ContactUtils.getPaddingSearchResultList(context, controller.responsiveUtils),
                                      selectedContactCallbackAction: (contact) => controller.selectContact(context, contact),
                                    );
                                  }
                                )
                              );
                            } else {
                              return Container(
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ListView.separated(
                                  itemCount: controller.listContactSearched.length,
                                  separatorBuilder: (context, index) {
                                    return Padding(
                                      padding: ContactUtils.getPaddingDividerSearchResultList(context, controller.responsiveUtils),
                                      child: const Divider(height: 1, color: AppColor.colorDivider),
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    final emailAddress = controller.listContactSearched[index];
                                    final suggestionEmailAddress = _toSuggestionEmailAddress(
                                      emailAddress,
                                      controller.contactSelected != null ? [controller.contactSelected!] : []
                                    );
                                    return ContactSuggestionBoxItem(
                                      suggestionEmailAddress,
                                      padding: ContactUtils.getPaddingSearchResultList(context, controller.responsiveUtils),
                                      selectedContactCallbackAction: (contact) => controller.selectContact(context, contact),
                                    );
                                  }
                                )
                              );
                            }
                          } else {
                            return const SizedBox.shrink();
                          }
                        })),
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

  SuggestionEmailAddress _toSuggestionEmailAddress(EmailAddress item, List<EmailAddress> addedEmailAddresses) {
    if (addedEmailAddresses.contains(item)) {
      return SuggestionEmailAddress(item, state: SuggestionEmailState.duplicated);
    } else {
      return SuggestionEmailAddress(item);
    }
  }
}