import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_controller.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/email_recovery_form/email_recovery_form_desktop_builder.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/email_recovery_form/email_recovery_form_mobile_builder.dart';

class EmailRecoveryView extends GetWidget<EmailRecoveryController> {
  @override
  final controller = Get.find<EmailRecoveryController>();

  EmailRecoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: ResponsiveWidget(
        responsiveUtils: controller.responsiveUtils,
        mobile: EmailRecoveryFormMobileBuilder(controller),
        tablet: EmailRecoveryFormDesktopBuilder(controller),
      ),
    );
  }
}