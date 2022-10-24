
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/contact/presentation/contact_controller.dart';
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/contact/presentation/utils/contact_utils.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/app_bar_contact_widget.dart';
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
      OnSelectedContactCallback? onSelectedContactCallback,
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
                                      return _buildItemSearchContact(context, emailAddress);
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

  Widget _buildItemSearchContact(BuildContext context, EmailAddress emailAddress) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () => controller.selectContact(context, emailAddress),
        contentPadding: ContactUtils.getPaddingSearchInputForm(context, _responsiveUtils),
        leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44) * 0.5,
                border: Border.all(color: Colors.transparent),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 1.0],
                    colors: emailAddress.avatarColors),
                color: AppColor.avatarColor
            ),
            child: Text(
                emailAddress.asString().isNotEmpty
                    ? emailAddress.asString()[0].toUpperCase()
                    : '',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600))),
        title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    emailAddress.asString(),
                    maxLines: 1,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.normal)),
                if (emailAddress.displayName.isNotEmpty && emailAddress.emailAddress.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                          emailAddress.emailAddress,
                          maxLines: 1,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          style: const TextStyle(
                              color: AppColor.colorContentEmail,
                              fontSize: 13,
                              fontWeight: FontWeight.normal)))
            ]
        ),
        trailing: controller.contactSelected?.email == emailAddress.email
            ? SvgPicture.asset(_imagePaths.icFilterSelected,
                width: 24,
                height: 24,
                fit: BoxFit.fill)
            : null,
      ),
    );
  }
}