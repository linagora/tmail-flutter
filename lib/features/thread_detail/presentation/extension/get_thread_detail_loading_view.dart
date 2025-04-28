import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_email_ids_by_thread_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension GetThreadDetailLoadingView on ThreadDetailController {
  Widget getThreadDetailLoadingView() {
    return viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is GettingEmailIdsByThreadId
        ? Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.only(top: 16),
              margin: const EdgeInsets.only(right: 16),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColor.lightIconTertiary,
                ),
              ),
            ),
        )
        : const SizedBox.shrink(),
    );
  }
}