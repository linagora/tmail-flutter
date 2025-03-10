import 'package:core/presentation/state/success.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/email_rules_header_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/list_email_rules_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';

class EmailRulesView extends GetWidget<EmailRulesController> with AppLoaderMixin {

  EmailRulesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingDetailViewBuilder(
      responsiveUtils: controller.responsiveUtils,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: SettingsUtils.getSettingContentWithoutHeaderPadding(
            context,
            controller.responsiveUtils,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EmailRulesHeaderWidget(
                imagePaths: controller.imagePaths,
                responsiveUtils: controller.responsiveUtils,
                createRule: () => controller.goToCreateNewRule(context),
              ),
              const SizedBox(height: 16),
              _buildLoadingView(),
              const ListEmailRulesWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
            (failure) => const SizedBox.shrink(),
            (success) => success is LoadingState
            ? Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: loadingWidget)
            : const SizedBox.shrink()
    ));
  }
}
