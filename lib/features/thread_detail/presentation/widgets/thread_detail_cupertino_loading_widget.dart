import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

class ThreadDetailCupertinoLoadingWidget extends StatelessWidget {
  const ThreadDetailCupertinoLoadingWidget({
    super.key,
    required this.threadDetailController,
  });

  final ThreadDetailController threadDetailController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return threadDetailController.viewState.value.fold(
        (failure) => const SizedBox.shrink(),
        (success) =>
            success is GettingThreadById || success is GettingEmailsByIds
                ? const Center(child: CupertinoLoadingWidget())
                : const SizedBox.shrink(),
      );
    });
  }
}
