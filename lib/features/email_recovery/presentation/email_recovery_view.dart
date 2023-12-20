import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_controller.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/email_recovery_view_styles.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/email_recovery_form/email_recovery_form_desktop_builder.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/email_recovery_form/email_recovery_form_mobile_builder.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/email_recovery_form/email_recovery_form_tablet_builder.dart';

class EmailRecoveryView extends GetWidget<EmailRecoveryController> {
  @override
  final controller = Get.find<EmailRecoveryController>();

  EmailRecoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: ResponsiveWidget(
        responsiveUtils: controller.responsiveUtils,
        mobile: Scaffold(
          backgroundColor: PlatformInfo.isWeb ? Colors.black.withAlpha(24) : Colors.black38,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              bottom: false,
              left: false,
              right: false,
              child: Container(
                decoration: EmailRecoveryViewStyles.backgroundDecorationMobile,
                margin: EmailRecoveryViewStyles.backgroundMarginMobile,
                child: ClipRRect(
                  borderRadius: EmailRecoveryViewStyles.clipRRectBorderRadiusMobile,
                  child: SafeArea(
                    child: EmailRecoveryFormMobileBuilder(),
                  ),
                ),
              ),
            ),
          ),
        ),
        tablet: Scaffold(
          backgroundColor: Colors.black.withAlpha(24),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: EmailRecoveryViewStyles.backgroundDecorationMobile,
                width: double.infinity,
                height: controller.responsiveUtils.getSizeScreenHeight(context) * 0.7,
                child: ClipRRect(
                  borderRadius: EmailRecoveryViewStyles.clipRRectBorderRadiusMobile,
                  child: EmailRecoveryFormTabletBuilder(),
                ),
              ),
            ),
          ),
        ),
        desktop: Scaffold(
          backgroundColor: Colors.black.withAlpha(24),
          body: GestureDetector(
            onTap:() => FocusScope.of(context).unfocus(),
            child: Center(
              child: Card(
                color: Colors.transparent,
                shape: EmailRecoveryViewStyles.shapeBorderDesktop,
                child: Container(
                  decoration: EmailRecoveryViewStyles.backgroundDecorationDesktop,
                  width: controller.responsiveUtils.getSizeScreenWidth(context) * 0.38,
                  height: controller.responsiveUtils.getSizeScreenHeight(context) * 0.6,
                  child: ClipRRect(
                    borderRadius: EmailRecoveryViewStyles.clipRRectBorderRadiusDesktop,
                    child: EmailRecoveryFormDesktopBuilder(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}