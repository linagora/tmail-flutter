import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/state/banner_state.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/autocomplete_contact_text_field_with_tags.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/forward_warning_banner.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/keep_copy_in_inbox_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/list_email_forward_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/number_of_recipient_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';

class ForwardView extends GetWidget<ForwardController> with AppLoaderMixin {

  ForwardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWebDesktop = controller.responsiveUtils.isWebDesktop(context);

    final bodyWidget = Column(
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
            child: Container(
              color: SettingsUtils.getContentBackgroundColor(
                context,
                controller.responsiveUtils,
              ),
              decoration: SettingsUtils.getBoxDecorationForContent(
                context,
                controller.responsiveUtils,
              ),
              width: double.infinity,
              padding: controller.responsiveUtils.isDesktop(context)
                  ? const EdgeInsetsDirectional.only(
                      start: 22,
                      end: 22,
                      top: 30,
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWebDesktop)
                    SettingHeaderWidget(
                      menuItem: AccountMenuItem.forward,
                      textStyle: ThemeUtils.textStyleInter600().copyWith(
                        color: Colors.black.withValues(alpha: 0.9),
                      ),
                      padding: const EdgeInsets.only(bottom: 16),
                    )
                  else
                    const SettingExplanationWidget(
                      menuItem: AccountMenuItem.forward,
                      padding: EdgeInsetsDirectional.only(
                        start: 16,
                        end: 16,
                        bottom: 16,
                      ),
                      isCenter: true,
                      textAlign: TextAlign.center,
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: _getScrollViewPadding(
                          context,
                          controller.responsiveUtils,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => KeepCopyInInboxWidget(
                              imagePaths: controller.imagePaths,
                              recipientForwards: controller.listRecipientForward,
                              localCopyState: controller.currentForwardLocalCopyState,
                              onToggleLocalCopy: controller.handleEditLocalCopy,
                            )),
                            Obx(
                              () => NumberOfRecipientWidget(
                                numberOfRecipient:
                                  controller.listRecipientForward.length,
                              ),
                            ),
                            Obx(
                              () => controller.currentForward.value != null
                                  ? _buildAddRecipientsFormWidget(context)
                                  : const SizedBox.shrink(),
                            ),
                            _buildLoadingView(),
                            Obx(() {
                              if (controller.listRecipientForward.isNotEmpty) {
                                return const ListEmailForwardsWidget();
                              } else {
                                return const SizedBox.shrink();
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (PlatformInfo.isMobile) {
      return GestureDetector(
        onTap: controller.clearInputFocus,
        child: bodyWidget,
      );
    } else {
      return bodyWidget;
    }
  }

  EdgeInsetsGeometry _getScrollViewPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if (responsiveUtils.isWebDesktop(context)) {
      return EdgeInsets.zero;
    } else if (responsiveUtils.isMobile(context)) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 16);
    } else {
      return const EdgeInsetsDirectional.symmetric(horizontal: 32);
    }
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is LoadingState
        ? Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: loadingWidget,
          )
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
