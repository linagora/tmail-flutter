import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/container/tmail_container_widget.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/trace_log/trace_log_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TraceLogView extends GetWidget<TraceLogController> with AppLoaderMixin {
  const TraceLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUtils.getBackgroundColor(context, controller.responsiveUtils),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: SettingsUtils.getContentBackgroundColor(context, controller.responsiveUtils),
        decoration: SettingsUtils.getBoxDecorationForContent(context, controller.responsiveUtils),
        margin: SettingsUtils.getMarginViewForSettingDetails(context, controller.responsiveUtils),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).traceLogSettingExplanation,
              style: const TextStyle(
                fontSize: 16,
                height: 20 / 16,
                color: AppColor.colorTextSettingDescriptions)),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                    children: [
                      Text(
                        AppLocalizations.of(context).totalSize,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 24 / 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(() => Text(
                          filesize(controller.tracLog.value?.size ?? 0),
                          style: const TextStyle(
                            fontSize: 17,
                            height: 24 / 17,
                            color: Colors.black
                          )
                        ))
                      )
                    ]
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Obx(() {
                      if (controller.tracLog.value != null) {
                        if (controller.isExporting) {
                          return const TMailContainerWidget(
                              borderRadius: 10,
                              width: 60,
                              backgroundColor: AppColor.primaryColor,
                              child: CupertinoLoadingWidget(size: 16));
                        } else {
                          return TMailButtonWidget(
                            text: AppLocalizations.of(context).exportFile,
                            backgroundColor: AppColor.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 17
                            ),
                            textAlign: TextAlign.center,
                            borderRadius: 10,
                            onTapActionCallback: () => controller.exportTraceLogFile(controller.tracLog.value!),
                          );
                        }
                      } else {
                        return const SizedBox.shrink();
                      }
                    })),
                    const SizedBox(width: 16),
                    Expanded(child: Obx(() {
                      if (controller.tracLog.value != null) {
                        if (controller.isDeleting) {
                          return const TMailContainerWidget(
                            borderRadius: 10,
                            width: 60,
                            backgroundColor: AppColor.primaryColor,
                            child: CupertinoLoadingWidget(size: 16));
                        } else {
                          return TMailButtonWidget(
                            text: AppLocalizations.of(context).clearLogCache,
                            backgroundColor: AppColor.toastErrorBackgroundColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 17
                            ),
                            textAlign: TextAlign.center,
                            borderRadius: 10,
                            onTapActionCallback: () => controller.deleteTraceLogFile(controller.tracLog.value!.path),
                          );
                        }
                      } else {
                        return const SizedBox.shrink();
                      }
                    })),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}