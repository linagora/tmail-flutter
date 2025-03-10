import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/state/banner_state.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/autocomplete_contact_text_field_with_tags.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/forward_warning_banner.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/list_email_forward_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ForwardView extends GetWidget<ForwardController> with AppLoaderMixin {

  ForwardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          if (controller.forwardWarningBannerState.value == BannerState.enabled) {
            return ForwardWarningBanner(
              imagePaths: controller.imagePaths,
              responsiveUtils: controller.responsiveUtils,
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Expanded(
          child: SettingDetailViewBuilder(
            responsiveUtils: controller.responsiveUtils,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.responsiveUtils.isWebDesktop(context))
                  ...[
                    const SettingHeaderWidget(menuItem: AccountMenuItem.forward),
                    const Divider(height: 1, color: AppColor.colorDividerHeaderSetting),
                  ],
                Expanded(child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: SettingsUtils.getSettingContentPadding(
                      context,
                      controller.responsiveUtils,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!controller.responsiveUtils.isWebDesktop(context))
                          const SettingExplanationWidget(
                            menuItem: AccountMenuItem.forward,
                            padding: EdgeInsetsDirectional.only(bottom: 24),
                          ),
                        _buildKeepLocalSwitchButton(context),
                        Obx(() => controller.currentForward.value != null
                          ? _buildAddRecipientsFormWidget(context)
                          : const SizedBox.shrink()
                        ),
                        _buildLoadingView(),
                        Obx(() {
                          if (controller.listRecipientForward.isNotEmpty) {
                            return const ListEmailForwardsWidget();
                          } else {
                            return const SizedBox.shrink();
                          }
                        })
                      ],
                    ),
                  )
                ))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeepLocalSwitchButton(BuildContext context) {
    return Obx(() {
      return controller.listRecipientForward.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Row(children: [
                  InkWell(
                    onTap: controller.handleEditLocalCopy,
                    child: SvgPicture.asset(
                      controller.currentForwardLocalCopyState
                        ? controller.imagePaths.icSwitchOn
                        : controller.imagePaths.icSwitchOff,
                      fit: BoxFit.fill,
                      width: 36,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).keepLocalCopyForwardLabel,
                      overflow: CommonTextStyle.defaultTextOverFlow,
                      softWrap: CommonTextStyle.defaultSoftWrap,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black)
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox();
    });

  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is LoadingState
        ? loadingWidget
        : const SizedBox.shrink()
    ));
  }

  Widget _buildAddRecipientsFormWidget(BuildContext context) {
    return AutocompleteContactTextFieldWithTags(
      listEmailAddress: controller.recipientController.listRecipients,
      internalDomain: controller.accountDashBoardController.sessionCurrent?.internalDomain ?? '',
      minInputLengthAutocomplete: controller.accountDashBoardController.minInputLengthAutocomplete,
      controller: controller.recipientController.inputRecipientController,
      onSuggestionCallback: controller.recipientController.getAutoCompleteSuggestion,
      hasAddContactButton: true,
      onAddContactCallback: (listRecipientsSelected) {
        controller.addRecipientAction(context, listRecipientsSelected);
      },
      onExceptionCallback: (exception) {
        controller.handleExceptionCallback(context, exception);
      },
    );
  }
}
