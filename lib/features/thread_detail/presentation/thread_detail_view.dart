import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_email_ids_by_thread_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_detail_loading_view.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_details_email_views.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

class ThreadDetailView extends GetWidget<ThreadDetailController> {
  const ThreadDetailView({super.key});

  bool get isSearchActivated => controller
    .mailboxDashBoardController
    .searchController
    .isSearchEmailRunning;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Obx(() => controller.getThreadDetailLoadingView()),
          Obx(() {
            return controller.viewState.value.fold(
              (failure) => const SizedBox.shrink(),
              (success) {
                if (success is GettingEmailIdsByThreadId) {
                  return const SizedBox.shrink();
                }

                return Expanded(
                  child: Padding(
                    padding: _padding(context),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: controller.getThreadDetailEmailViews()
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          if (controller.responsiveUtils.isDesktop(context))
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  EdgeInsetsGeometry _padding(BuildContext context) {
    if (controller.responsiveUtils.isDesktop(context)) {
      return const EdgeInsetsDirectional.only(end: 16);
    }
    return EdgeInsets.zero;
  }
}