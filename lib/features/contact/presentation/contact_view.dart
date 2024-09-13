
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/contact/presentation/contact_controller.dart';
import 'package:tmail_ui_user/features/contact/presentation/utils/contact_utils.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/app_bar_contact_widget.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_suggestion_box_item.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContactView extends GetWidget<ContactController> {

  final _maxHeight = 656.0;
  final _maxWidth = 556.0;

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
              top: ContactUtils.supportAppBarTopBorder(context, controller.responsiveUtils),
              child: Center(
                child: Container(
                  height: _getHeightContactView(context),
                  width: _getWidthContactView(context),
                  decoration: BoxDecoration(
                    borderRadius: _getRadiusContactView(context),
                    color: Colors.white
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SafeArea(child: Container(
                      color: Colors.white,
                      child: Column(children: [
                        Container(
                            height: 52,
                            color: Colors.white,
                            padding: ContactUtils.getPaddingAppBar(context, controller.responsiveUtils),
                            child: AppBarContactWidget(
                                onCloseContactView: () => controller.closeContactView(context))
                        ),
                        const Divider(color: AppColor.colorDividerComposer, height: 1),
                        SearchAppBarWidget(
                          imagePaths: controller.imagePaths,
                          searchQuery: controller.searchQuery.value,
                          searchFocusNode: controller.textInputSearchFocus,
                          searchInputController: controller.textInputSearchController,
                          hasBackButton: false,
                          hasSearchButton: true,
                          margin: ContactUtils.getPaddingSearchInputForm(context, controller.responsiveUtils),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: AppColor.colorBgSearchBar),
                          iconClearText: SvgPicture.asset(
                            controller.imagePaths.icClearTextSearch,
                            width: 18,
                            height: 18,
                            fit: BoxFit.fill),
                          hintText: AppLocalizations.of(context).hintSearchInputContact,
                          onClearTextSearchAction: controller.clearAllTextInputSearchForm,
                          onTextChangeSearchAction: controller.onTextSearchChange,
                          onSearchTextAction: controller.onSearchTextAction,
                        ),
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
                      ]),
                    ))
                ),
              ),
            ),
          ),
        )
    );
  }

  BorderRadius _getRadiusContactView(BuildContext context) {
    if (PlatformInfo.isMobile && controller.responsiveUtils.isLandscapeMobile(context)) {
      return BorderRadius.zero;
    } else if (controller.responsiveUtils.isMobile(context)) {
      return BorderRadius.only(
        topRight: Radius.circular(
          ContactUtils.getRadiusBorderAppBarTop(
            context,
            controller.responsiveUtils
          )
        ),
        topLeft: Radius.circular(
          ContactUtils.getRadiusBorderAppBarTop(
            context,
            controller.responsiveUtils
          )
        )
      );
    } else {
      return const BorderRadius.all(Radius.circular(16));
    }
  }

  double _getHeightContactView(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (controller.responsiveUtils.isMobile(context)) {
        return double.infinity;
      } else {
        if (controller.responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return _maxHeight;
        } else {
          return double.infinity;
        }
      }
    } else {
      if (controller.responsiveUtils.isLandscapeMobile(context) ||
        controller.responsiveUtils.isPortraitMobile(context)) {
        return double.infinity;
      } else {
        if (controller.responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return _maxHeight;
        } else {
          return double.infinity;
        }
      }
    }
  }

  double _getWidthContactView(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (controller.responsiveUtils.isMobile(context)) {
        return double.infinity;
      } else {
        return _maxWidth;
      }
    } else {
      if (controller.responsiveUtils.isLandscapeMobile(context) ||
        controller.responsiveUtils.isPortraitMobile(context)) {
        return double.infinity;
      } else {
        return _maxWidth;
      }
    }
  }

  SuggestionEmailAddress _toSuggestionEmailAddress(EmailAddress item, List<EmailAddress> addedEmailAddresses) {
    if (addedEmailAddresses.contains(item)) {
      return SuggestionEmailAddress(item, state: SuggestionEmailState.duplicated);
    } else {
      return SuggestionEmailAddress(item);
    }
  }
}