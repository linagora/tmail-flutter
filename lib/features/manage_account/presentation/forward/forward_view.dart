import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/autocomplete_contact_text_field_with_tags.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/forward_header_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/list_email_forward_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ForwardView extends GetWidget<ForwardController> with AppLoaderMixin {
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();

  ForwardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUtils.getBackgroundColor(context, _responsiveUtils),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: SettingsUtils.getContentBackgroundColor(context, _responsiveUtils),
        decoration: SettingsUtils.getBoxDecorationForContent(context, _responsiveUtils),
        margin: SettingsUtils.getMarginViewForSettingDetails(context, _responsiveUtils),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_responsiveUtils.isWebDesktop(context))
              ...[
                ForwardHeaderWidget(imagePaths: _imagePaths, responsiveUtils: _responsiveUtils),
                Container(height: 1, color: AppColor.colorDividerHeaderSetting)
              ],
            Expanded(child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (!_responsiveUtils.isWebDesktop(context))
                  _buildTitleHeader(context),
                _buildLoadingView(),
                Obx(() {
                  if (controller.currentForward.value != null) {
                    return Column(children: [
                      _buildKeepLocalSwitchButton(context),
                      _buildAddRecipientsFormWidget(context),
                      if (controller.listRecipientForward.isNotEmpty)
                        ListEmailForwardsWidget()
                    ]);
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
      color: Colors.white,
      width: double.infinity,
      margin: SettingsUtils.getMarginTitleHeaderForwarding(context, _responsiveUtils),
      padding: SettingsUtils.getPaddingTitleHeaderForwarding(context, _responsiveUtils),
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
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 11),
      child: Row(children: [
        Obx(() {
          return InkWell(
            onTap: controller.handleEditLocalCopy,
            child: SvgPicture.asset(
              controller.currentForwardLocalCopyState
                ? _imagePaths.icSwitchOn
                : _imagePaths.icSwitchOff,
              fit: BoxFit.fill,
              width: 36,
              height: 24)
          );
        }),
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
        )
      ]),
    );
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
      controller.recipientController.listRecipients,
      controller: controller.recipientController.inputRecipientController,
      onSuggestionCallback: controller.recipientController.getAutoCompleteSuggestion,
      hasAddContactButton: true,
      onAddContactCallback: (listRecipientsSelected) {
        controller.addRecipientAction(context, listRecipientsSelected);
      },
      onExceptionCallback: () {
        _appToast.showBottomToast(
          context,
          AppLocalizations.of(context).incorrectEmailFormat,
          leadingIcon: SvgPicture.asset(
            _imagePaths.icNotConnection,
            width: 24,
            height: 24,
            color: Colors.white,
            fit: BoxFit.fill),
          backgroundColor: AppColor.toastErrorBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          maxWidth: _responsiveUtils.getMaxWidthToast(context));
      },
    );
  }
}
