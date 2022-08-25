import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/forward_header_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/list_email_forward_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';

class ForwardView extends GetWidget<ForwardController> with AppLoaderMixin {
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  ForwardView({Key? key}) : super(key: key);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ForwardHeaderWidget(
                imagePaths: _imagePaths,
                responsiveUtils: _responsiveUtils,
              ),
              SizedBox(height: _responsiveUtils.isWebDesktop(context) ? 24 : 16),
              _buildLoadingView(),
              ListEmailForwardsWidget()
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
