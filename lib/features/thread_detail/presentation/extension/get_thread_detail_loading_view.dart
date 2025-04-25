import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_email_ids_by_thread_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension GetThreadDetailLoadingView on ThreadDetailController {
  Widget getThreadDetailLoadingView() {
    return viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is GettingEmailIdsByThreadId
        ? Center(
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: const CircularProgressIndicator(
                color: AppColor.lightIconTertiary,
              ),
            ),
          )
        : const SizedBox.shrink(),
    );
  }
}