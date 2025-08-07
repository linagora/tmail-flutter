
import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/presentation/views/text/type_ahead_form_field_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_email_address_drop_down_button.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_horizontal_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_label_field_widget.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_creator_form_desktop_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_creator_form_mobile_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_decoration_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_signature_input_field_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IdentityCreatorView extends GetWidget<IdentityCreatorController> {

  @override
  final controller = Get.find<IdentityCreatorController>();

  IdentityCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    Widget bodyCreatorView;

    if (controller.responsiveUtils.isMobile(context)) {
      bodyCreatorView = Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultLabelFieldWidget(
              label: '${appLocalizations.name} (${appLocalizations.required})',
            ),
            Obx(() => TextFieldBuilder(
              onTextChange:  (value) => controller.updateNameIdentity(
                context,
                value,
              ),
              textInputAction: TextInputAction.next,
              autoFocus: true,
              maxLines: 1,
              textDirection: DirectionUtils.getDirectionByLanguage(context),
              controller: controller.inputNameIdentityController,
              focusNode: controller.inputNameIdentityFocusNode,
              textStyle: ThemeUtils.textStyleBodyBody3(
                color: AppColor.m3SurfaceBackground,
              ),
              keyboardType: TextInputType.text,
              semanticLabel: 'Identity input field',
              decoration: (IdentityInputDecorationBuilder()
                ..setContentPadding(EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: PlatformInfo.isWeb ? 15 : 12,
                ))
                ..setErrorText(controller.errorNameIdentity.value)
                ..setHintText(appLocalizations.enterName)
                ..setHintStyle(ThemeUtils.textStyleBodyBody3(
                  color: AppColor.m3Tertiary,
                ))
              ).build(),
            )),
            const SizedBox(height: 15),
            DefaultLabelFieldWidget(label: appLocalizations.email.inCaps),
            Obx(() => DefaultEmailAddressDropDownButton(
              imagePaths: controller.imagePaths,
              emailAddresses: controller.listEmailAddressDefault,
              emailAddressSelected: controller.emailOfIdentity.value,
              isEnabled: controller.actionType.value == IdentityActionType.create,
              onEmailAddressSelected: (emailAddress) =>
                  controller.updateEmailOfIdentity(
                    context,
                    emailAddress,
                  ),
            )),
            const SizedBox(height: 15),
            DefaultLabelFieldWidget(label: appLocalizations.reply_to),
            Obx(() => DefaultEmailAddressDropDownButton(
              imagePaths: controller.imagePaths,
              emailAddresses: controller.listEmailAddressOfReplyTo,
              emailAddressSelected: controller.replyToOfIdentity.value,
              onEmailAddressSelected: (emailAddress) =>
                  controller.updaterReplyToOfIdentity(
                    context,
                    emailAddress,
                  ),
            )),
            const SizedBox(height: 15),
            DefaultLabelFieldWidget(label: appLocalizations.bcc_to),
            Obx(() {
              return TypeAheadFormFieldBuilder<EmailAddress>(
                focusNode: controller.inputBccIdentityFocusNode,
                controller: controller.inputBccIdentityController,
                textInputAction: TextInputAction.done,
                textStyle: ThemeUtils.textStyleBodyBody3(
                  color: AppColor.m3SurfaceBackground,
                ),
                decoration: (IdentityInputDecorationBuilder()
                  ..setContentPadding(EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: PlatformInfo.isWeb ? 15 : 12,
                  ))
                  ..setErrorText(controller.errorBccIdentity.value)
                  ..setHintText(appLocalizations.enterEmailAddress)
                  ..setHintStyle(ThemeUtils.textStyleBodyBody3(
                    color: AppColor.m3Tertiary,
                  ))
                ).build(),
                debounceDuration: const Duration(milliseconds: 500),
                suggestionsCallback: (pattern) async {
                  controller.validateInputBccAddress(context, pattern);
                  if (pattern.trim().isEmpty) {
                    controller.updateBccOfIdentity(null);
                  } else {
                    controller.updateBccOfIdentity(EmailAddress(null, pattern));
                  }
                  return controller.getSuggestionEmailAddress(pattern);
                },
                itemBuilder: (_, emailAddress) {
                  return Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      emailAddress.emailAddress,
                      style: ThemeUtils.textStyleInter400.copyWith(
                        fontSize: 15,
                        height: 20 / 15,
                        letterSpacing: -0.15,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
                onSuggestionSelected: (emailSelected) {
                  controller.inputBccIdentityController.text = emailSelected.emailAddress;
                  controller.updateBccOfIdentity(emailSelected);
                },
                noItemsFoundBuilder: (_) => const SizedBox.shrink(),
                hideOnEmpty: true,
                hideOnError: true,
                hideOnLoading: true,
              );
            }),
            const SizedBox(height: 15),
            DefaultLabelFieldWidget(label: appLocalizations.signature),
            IdentitySignatureInputFieldWidget(controller: controller),
            const SizedBox(height: 15),
          ],
        ),
      );
    } else {
      bodyCreatorView = SingleChildScrollView(
        controller: controller.scrollController,
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 32,
            end: 32,
            bottom: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultHorizontalFieldWidget(
                label: '${appLocalizations.name} (${appLocalizations.required})',
                child: Obx(() => TextFieldBuilder(
                  onTextChange:  (value) => controller.updateNameIdentity(
                    context,
                    value,
                  ),
                  textInputAction: TextInputAction.next,
                  autoFocus: true,
                  maxLines: 1,
                  textDirection: DirectionUtils.getDirectionByLanguage(context),
                  controller: controller.inputNameIdentityController,
                  focusNode: controller.inputNameIdentityFocusNode,
                  textStyle: ThemeUtils.textStyleBodyBody3(
                    color: AppColor.m3SurfaceBackground,
                  ),
                  keyboardType: TextInputType.text,
                  semanticLabel: 'Identity input field',
                  decoration: (IdentityInputDecorationBuilder()
                    ..setContentPadding(EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: PlatformInfo.isWeb ? 15 : 12,
                    ))
                    ..setErrorText(controller.errorNameIdentity.value)
                    ..setHintText(appLocalizations.enterName)
                    ..setHintStyle(ThemeUtils.textStyleBodyBody3(
                      color: AppColor.m3Tertiary,
                    ))
                  ).build(),
                )),
              ),
              const SizedBox(height: 12),
              DefaultHorizontalFieldWidget(
                label: appLocalizations.email.inCaps,
                child: Obx(() => DefaultEmailAddressDropDownButton(
                  imagePaths: controller.imagePaths,
                  emailAddresses: controller.listEmailAddressDefault,
                  emailAddressSelected: controller.emailOfIdentity.value,
                  isEnabled: controller.actionType.value == IdentityActionType.create,
                  onEmailAddressSelected: (emailAddress) =>
                    controller.updateEmailOfIdentity(
                      context,
                      emailAddress,
                    ),
                )),
              ),
              const SizedBox(height: 12),
              DefaultHorizontalFieldWidget(
                label: appLocalizations.reply_to,
                child: Obx(() => DefaultEmailAddressDropDownButton(
                  imagePaths: controller.imagePaths,
                  emailAddresses: controller.listEmailAddressOfReplyTo,
                  emailAddressSelected: controller.replyToOfIdentity.value,
                  onEmailAddressSelected: (emailAddress) =>
                    controller.updaterReplyToOfIdentity(
                      context,
                      emailAddress,
                    ),
                )),
              ),
              const SizedBox(height: 12),
              DefaultHorizontalFieldWidget(
                label: appLocalizations.bcc_to,
                child: Obx(() {
                  return TypeAheadFormFieldBuilder<EmailAddress>(
                    focusNode: controller.inputBccIdentityFocusNode,
                    controller: controller.inputBccIdentityController,
                    textInputAction: TextInputAction.done,
                    textStyle: ThemeUtils.textStyleBodyBody3(
                      color: AppColor.m3SurfaceBackground,
                    ),
                    decoration: (IdentityInputDecorationBuilder()
                      ..setContentPadding(EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: PlatformInfo.isWeb ? 15 : 12,
                      ))
                      ..setErrorText(controller.errorBccIdentity.value)
                      ..setHintText(appLocalizations.enterEmailAddress)
                      ..setHintStyle(ThemeUtils.textStyleBodyBody3(
                        color: AppColor.m3Tertiary,
                      ))
                    ).build(),
                    debounceDuration: const Duration(milliseconds: 500),
                    suggestionsCallback: (pattern) async {
                      controller.validateInputBccAddress(context, pattern);
                      if (pattern.trim().isEmpty) {
                        controller.updateBccOfIdentity(null);
                      } else {
                        controller.updateBccOfIdentity(EmailAddress(null, pattern));
                      }
                      return controller.getSuggestionEmailAddress(pattern);
                    },
                    itemBuilder: (_, emailAddress) {
                      return Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          emailAddress.emailAddress,
                          style: ThemeUtils.textStyleInter400.copyWith(
                            fontSize: 15,
                            height: 20 / 15,
                            letterSpacing: -0.15,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                    onSuggestionSelected: (emailSelected) {
                      controller.inputBccIdentityController.text = emailSelected.emailAddress;
                      controller.updateBccOfIdentity(emailSelected);
                    },
                    noItemsFoundBuilder: (_) => const SizedBox.shrink(),
                    hideOnEmpty: true,
                    hideOnError: true,
                    hideOnLoading: true,
                  );
                }),
              ),
              const SizedBox(height: 12),
              DefaultHorizontalFieldWidget(
                label: appLocalizations.signature,
                child: IdentitySignatureInputFieldWidget(
                  controller: controller,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ResponsiveWidget(
      responsiveUtils: controller.responsiveUtils,
      mobile: IdentityCreatorFormMobileBuilder(
        controller: controller,
        formView: bodyCreatorView,
        enableRichTextKeyboard: PlatformInfo.isMobile,
      ),
      tablet: IdentityCreatorFormDesktopBuilder(
        controller: controller,
        formView: bodyCreatorView,
      ),
    );
  }
}