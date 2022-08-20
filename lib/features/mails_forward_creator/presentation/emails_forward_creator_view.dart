import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mails_forward_creator/presentation/emails_forward_creator_controller.dart';
import 'package:tmail_ui_user/features/mails_forward_creator/presentation/widgets/email_forward_creator_item_widget.dart';
import 'package:tmail_ui_user/features/mails_forward_creator/presentation/widgets/emails_forward_input_with_drop_list_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailsForwardCreatorView extends GetWidget<EmailsForwardCreatorController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  EmailsForwardCreatorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: Scaffold(
            backgroundColor: Colors.black38,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                        color: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            )),
                        child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                )),
                            width: double.infinity,
                            height: _responsiveUtils.getSizeScreenHeight(context) - 70,
                            child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16)),
                                child: _buildRulesFilterFormOnMobile(context)
                            )
                        )
                    )
                ),
              ),
            )
        ),
        tablet: Scaffold(
            backgroundColor: Colors.black38,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Align(alignment: Alignment.bottomCenter, child: Card(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )),
                  child: Container(
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
                          child: _buildRulesFilterFormOnTablet(context)
                      )
                  )
              )),
            )
        ),
        desktop: Scaffold(
            backgroundColor: Colors.black38,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Align(alignment: Alignment.center, child: Card(
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
                          child: _buildRulesFilterFormOnDesktop(context)
                      )
                  )
              )
              ),
            )
        )
    );
  }

  Widget _buildRulesFilterFormOnDesktop(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(
        alignment: Alignment.centerRight,
        child: buildIconWeb(
            icon: SvgPicture.asset(
                _imagePaths.icCloseMailbox,
                fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).close,
            onTap: () => controller.closeView(context)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: (EmailsForwardInputWithDropListFieldBuilder(
            AppLocalizations.of(context).emailForwardLabel,
            controller.inputEmailForwardController)
          ..addOnSelectedSuggestionAction((newEmailAddress) {
            controller.addToListEmailForwards(newEmailAddress);
            controller.clearAll();
          })
          ..addOnSummitedCallbackAction((pattern) {
            if (pattern != null && pattern.trim().isNotEmpty) {
              controller.addToListEmailForwards(EmailAddress(null, pattern.trim()));
              controller.clearAll();
            }
          })
          ..addOnSuggestionCallbackAction((pattern) {
            if (pattern != null) {
              controller.getAutoCompleteSuggestion(word: pattern.trim());
            }
          }))
            .build(),
      ),
      Expanded(
        child: Obx(() => ListView.builder(
          itemCount: controller.listEmailForwards.length,
          itemBuilder: (BuildContext context, int index) {
            final item = controller.listEmailForwards[index];
            return EmailForwardCreatorItemWidget(
              emailForward: item.emailAddress,
              onDelete: () {
                controller.listEmailForwards.removeAt(index);
              }
            );
          },
        )),
      ),
    ]);
  }

  Widget _buildRulesFilterFormOnTablet(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(
        alignment: Alignment.centerRight,
        child: buildIconWeb(
            icon: SvgPicture.asset(
                _imagePaths.icCloseMailbox,
                fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).close,
            onTap: () => controller.closeView(context)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: (EmailsForwardInputWithDropListFieldBuilder(
            AppLocalizations.of(context).emailForwardLabel,
            controller.inputEmailForwardController)
          ..addOnSelectedSuggestionAction((newEmailAddress) {
            controller.addToListEmailForwards(newEmailAddress);
            controller.clearAll();
          })
          ..addOnSummitedCallbackAction((pattern) {
            if (pattern != null && pattern.trim().isNotEmpty) {
              controller.addToListEmailForwards(EmailAddress(null, pattern.trim()));
              controller.clearAll();
            }
          })
          ..addOnSuggestionCallbackAction((pattern) {
            if (pattern != null) {
              controller.getAutoCompleteSuggestion(word: pattern.trim());
            }
          }))
            .build(),
      ),
      Expanded(
        child: Obx(() => ListView.builder(
          itemCount: controller.listEmailForwards.length,
          itemBuilder: (BuildContext context, int index) {
            final item = controller.listEmailForwards[index];
            return EmailForwardCreatorItemWidget(
                emailForward: item.emailAddress,
                onDelete: () {
                  controller.listEmailForwards.removeAt(index);
                }
            );
          },
        )),
      ),
    ]);
  }

  Widget _buildRulesFilterFormOnMobile(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(
        alignment: Alignment.centerRight,
        child: buildIconWeb(
            icon: SvgPicture.asset(
                _imagePaths.icCloseMailbox,
                fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).close,
            onTap: () => controller.closeView(context)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: (EmailsForwardInputWithDropListFieldBuilder(
            AppLocalizations.of(context).emailForwardLabel,
            controller.inputEmailForwardController)
          ..addOnSelectedSuggestionAction((newEmailAddress) {
            controller.addToListEmailForwards(newEmailAddress);
            controller.clearAll();
          })
          ..addOnSummitedCallbackAction((pattern) {
            if (pattern != null && pattern.trim().isNotEmpty) {
              controller.addToListEmailForwards(EmailAddress(null, pattern.trim()));
              controller.clearAll();
            }
          })
          ..addOnSuggestionCallbackAction((pattern) {
            if (pattern != null) {
              controller.getAutoCompleteSuggestion(word: pattern.trim());
            }
          }))
            .build(),
      ),
      Expanded(
        child: Obx(() => ListView.builder(
          itemCount: controller.listEmailForwards.length,
          itemBuilder: (BuildContext context, int index) {
            final item = controller.listEmailForwards[index];
            return EmailForwardCreatorItemWidget(
                emailForward: item.emailAddress,
                onDelete: () {
                  controller.listEmailForwards.removeAt(index);
                }
            );
          },
        )),
      ),
    ]);
  }

  Widget _buildButtonAddNewEmailsForward(BuildContext context) {
    if (!_responsiveUtils.isMobile(context)) {
      return (ButtonBuilder(_imagePaths.icAddEmailForward)
        ..key(const Key('button_add_emails_forward_creator'))
        ..decoration(BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColor.colorTextButton))
        ..paddingIcon(const EdgeInsets.only(right: 8))
        ..iconColor(Colors.white)
        ..maxWidth(130)
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
          AppLocalizations.of(context).addEmailForward,
          isVertical: false,
        ))
          .build();
    } else {
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
          AppLocalizations.of(context).addEmailForward,
          isVertical: false,
        ))
          .build();
    }
  }

}