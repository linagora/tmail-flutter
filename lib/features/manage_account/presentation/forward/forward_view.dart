import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/autocomplete_contact_text_field_with_tags.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/forward_header_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/list_email_forward_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ForwardView extends GetWidget<ForwardController> with AppLoaderMixin {

  ForwardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUtils.getBackgroundColor(context, controller.responsiveUtils),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: SettingsUtils.getContentBackgroundColor(context, controller.responsiveUtils),
        decoration: SettingsUtils.getBoxDecorationForContent(context, controller.responsiveUtils),
        margin: SettingsUtils.getMarginViewForForwardSettingDetails(context, controller.responsiveUtils),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.responsiveUtils.isWebDesktop(context))
              ...[
                ForwardHeaderWidget(imagePaths: controller.imagePaths, responsiveUtils: controller.responsiveUtils),
                const Divider(height: 1, color: AppColor.colorDividerHeaderSetting)
              ],
            Expanded(child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (!controller.responsiveUtils.isWebDesktop(context))
                  _buildTitleHeader(context),
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
              ])
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildTitleHeader(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      padding: SettingsUtils.getPaddingTitleHeaderForwarding(context, controller.responsiveUtils),
      child: Text(
        AppLocalizations.of(context).forwardingSettingExplanation,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColor.colorSettingExplanation
        )
      ),
    );
  }

  Widget _buildKeepLocalSwitchButton(BuildContext context) {
    return Obx(() {
      return controller.listRecipientForward.isNotEmpty
          ? Container(
              color: Colors.transparent,
              padding: SettingsUtils.getPaddingKeepLocalSwitchButtonForwarding(context, controller.responsiveUtils),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: controller.handleEditLocalCopy,
                    child: SvgPicture.asset(
                      controller.currentForwardLocalCopyState
                        ? controller.imagePaths.icSwitchOn
                        : controller.imagePaths.icSwitchOff,
                      fit: BoxFit.fill,
                      width: 36,
                      height: 24))),
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
                )
              ]))
          : const SizedBox();
    });

  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is LoadingState
        ? Padding(
            padding: const EdgeInsets.all(24),
            child: loadingWidget)
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
