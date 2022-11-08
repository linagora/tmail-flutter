
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/contact/presentation/contact_controller.dart';
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/contact/presentation/utils/contact_utils.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/app_bar_contact_widget.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_suggestion_box_item.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContactView extends GetWidget<ContactController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  @override
  final controller = Get.find<ContactController>();

  ContactView({Key? key}) : super(key: key) {
    controller.arguments = Get.arguments;
  }

  ContactView.fromArguments(
      ContactArguments arguments, {
      Key? key,
      SelectedContactCallbackAction? onSelectedContactCallback,
      VoidCallback? onDismissCallback
  }) : super(key: key) {
    controller.arguments = arguments;
    controller.onSelectedContactCallback = onSelectedContactCallback;
    controller.onDismissContactView = onDismissCallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black38,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            bottom: false,
            left: false,
            right: false,
            top: ContactUtils.supportAppBarTopBorder(context, _responsiveUtils),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ContactUtils.getRadiusBorderAppBarTop(
                            context,
                            _responsiveUtils)),
                        topRight: Radius.circular(ContactUtils.getRadiusBorderAppBarTop(
                            context,
                            _responsiveUtils))),
                    color: Colors.white),
                child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ContactUtils.getRadiusBorderAppBarTop(
                            context,
                            _responsiveUtils)),
                        topRight: Radius.circular(ContactUtils.getRadiusBorderAppBarTop(
                            context,
                            _responsiveUtils))),
                    child: SafeArea(child: Container(
                      color: Colors.white,
                      child: Column(children: [
                        Container(
                            height: 52,
                            color: Colors.white,
                            padding: ContactUtils.getPaddingAppBar(context, _responsiveUtils),
                            child: AppBarContactWidget(
                                onCloseContactView: () => controller.closeContactView(context))
                        ),
                        const Divider(color: AppColor.colorDividerComposer, height: 1),
                        (SearchAppBarWidget(
                              _imagePaths,
                              controller.searchQuery.value,
                              controller.textInputSearchFocus,
                              controller.textInputSearchController,
                              hasBackButton: false,
                              hasSearchButton: true)
                          ..addPadding(EdgeInsets.zero)
                          ..setHeightSearchBar(44)
                          ..setMargin(ContactUtils.getPaddingSearchInputForm(context, _responsiveUtils))
                          ..addDecoration(BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.colorBgSearchBar))
                          ..addIconClearText(SvgPicture.asset(
                              _imagePaths.icClearTextSearch,
                              width: 18,
                              height: 18,
                              fit: BoxFit.fill))
                          ..setHintText(AppLocalizations.of(context).hintSearchInputContact)
                          ..addOnClearTextSearchAction(() => controller.clearAllTextInputSearchForm())
                          ..addOnTextChangeSearchAction(controller.onTextSearchChange)
                          ..addOnSearchTextAction((query) => {}))
                        .build(),
                        Expanded(child: Obx(() {
                          if (controller.listContactSearched.isNotEmpty) {
                            return Container(
                                color: Colors.white,
                                child: ListView.separated(
                                    itemCount: controller.listContactSearched.length,
                                    separatorBuilder: (context, index) {
                                      return Padding(
                                        padding: ContactUtils.getPaddingDividerSearchResultList(context, _responsiveUtils),
                                        child: const Divider(
                                            height: 1,
                                            color: AppColor.colorDivider),
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      final emailAddress = controller.listContactSearched[index];
                                      final suggestionEmailAddress = _toSuggestionEmailAddress(
                                        emailAddress,
                                        controller.contactSelected != null
                                          ? [controller.contactSelected!]
                                          : []
                                      );
                                      return ContactSuggestionBoxItem(
                                        suggestionEmailAddress,
                                        padding: ContactUtils.getPaddingSearchResultList(context, _responsiveUtils),
                                        selectedContactCallbackAction: (contact) => controller.selectContact(context, contact),
                                      );
                                    }
                                )
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        })),
                      ]),
                    ))
                )
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