import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/email_rules_header_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/list_email_rules_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';

class EmailRulesView extends GetWidget<EmailRulesController> with AppLoaderMixin {
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  EmailRulesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _responsiveUtils.isWebDesktop(context)
          ? AppColor.colorBgDesktop
          : Colors.white,
      body: Container(
        width: double.infinity,
        margin: SettingsUtils.getMarginViewForSettingDetails(context, _responsiveUtils),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EmailRulesHeaderWidget(
                imagePaths: _imagePaths,
                responsiveUtils: _responsiveUtils,
                createRule: () => controller.goToCreateNewRule(),
              ),
              SizedBox(height: _responsiveUtils.isWebDesktop(context) ? 24 : 16),
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
