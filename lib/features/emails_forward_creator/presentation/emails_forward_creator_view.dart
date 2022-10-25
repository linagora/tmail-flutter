import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/emails_forward_creator/presentation/emails_forward_creator_controller.dart';
import 'package:tmail_ui_user/features/emails_forward_creator/presentation/model/email_forward_creator_arguments.dart';
import 'package:tmail_ui_user/features/emails_forward_creator/presentation/widgets/email_forward_creator_item_widget.dart';
import 'package:tmail_ui_user/features/emails_forward_creator/presentation/widgets/emails_forward_input_with_drop_list_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailsForwardCreatorView extends GetWidget<EmailsForwardCreatorController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  final controller = Get.find<EmailsForwardCreatorController>();

  EmailsForwardCreatorView({Key? key}) : super(key: key) {
    controller.arguments = Get.arguments;
  }

  EmailsForwardCreatorView.fromArguments(
      EmailForwardCreatorArguments arguments, {
      Key? key,
      OnAddEmailForwardCallback? onAddEmailForwardCallback,
      VoidCallback? onDismissCallback
  }) : super(key: key) {
    controller.arguments = arguments;
    controller.onAddEmailForwardCallback = onAddEmailForwardCallback;
    controller.onDismissForwardCreatorCallback = onDismissCallback;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: Scaffold(
            backgroundColor: BuildUtils.isWeb
                ? Colors.black.withAlpha(24)
                : Colors.black38,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                bottom: false,
                left: false,
                right: false,
                child: Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        color: Colors.white),
                    margin: const EdgeInsets.only(top: BuildUtils.isWeb ? 70 : 0),
                    child: ClipRRect(
                        borderRadius: const  BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        child: SafeArea(child: _buildEmailForwardCreatorList(context))
                    )
                ),
              ),
            )
        ),
        tablet: Scaffold(
            backgroundColor: Colors.black.withAlpha(24),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Align(alignment: Alignment.bottomCenter, child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )),
                  width: double.infinity,
                  height: _responsiveUtils.getSizeScreenHeight(context) * 0.7,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                      child: _buildEmailForwardCreatorList(context)
                  )
              )),
            )
        ),
        desktop: Scaffold(
            backgroundColor: Colors.black.withAlpha(24),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(child: Card(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      width: _responsiveUtils.getSizeScreenWidth(context) * 0.6,
                      height: _responsiveUtils.getSizeScreenHeight(context) * 0.7,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          child: _buildEmailForwardCreatorList(context)
                      )
                  )
              )),
            )
        )
    );
  }

  Widget _buildEmailForwardCreatorList(BuildContext context) {
    return Stack(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.only(top: 16),
              alignment: Alignment.center,
              child: Text(
                  AppLocalizations.of(context).addRecipients,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: (EmailsForwardInputWithDropListFieldBuilder(
                AppLocalizations.of(context).recipientsLabel,
                controller.inputEmailForwardController)
              ..addOnSelectedSuggestionAction((newEmailAddress) {
                controller.addToListEmailForwards(newEmailAddress);
                controller.clearAll();
              })
              ..addOnSummitedCallbackAction((pattern) {
                if (pattern != null && pattern.trim().isNotEmpty && pattern.isEmail == true) {
                  controller.addToListEmailForwards(EmailAddress(null, pattern.trim()));
                  controller.clearAll();
                }
              })
              ..addOnSuggestionCallbackAction(controller.getAutoCompleteSuggestion)).build(),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.listEmailForwards.length,
              itemBuilder: (BuildContext context, int index) {
                final item = controller.listEmailForwards.toList()[index];
                return EmailForwardCreatorItemWidget(
                    emailForward: item.emailAddress,
                    onDelete: () {
                      controller.listEmailForwards.remove(item);
                    }
                );
              },
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildButtonAddNewEmailsForward(context),
          ),
        ]),
        Positioned(top: 8, right: 8,
          child: buildIconWeb(
            icon: SvgPicture.asset(
              _imagePaths.icCloseMailbox,
              fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).close,
            onTap: () => controller.closeView(context)))
      ],
    );
  }

  Widget _buildButtonAddNewEmailsForward(BuildContext context) {
      return (ButtonBuilder(_imagePaths.icAddEmailForward)
        ..key(const Key('button_add_emails_forward_creator'))
        ..decoration(BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColor.colorTextButton))
        ..paddingIcon(const EdgeInsets.only(right: 8))
        ..iconColor(Colors.white)
        ..size(20)
        ..radiusSplash(10)
        ..padding(const EdgeInsets.symmetric(vertical: 12))
        ..textStyle(const TextStyle(
          fontSize: 17,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ))
        ..onPressActionClick(() => controller.addEmailForwards(context))
        ..text(
          AppLocalizations.of(context).addRecipients,
          isVertical: false,
        ))
      .build();
  }

}