import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension GetThreadDetailLoadingView on ThreadDetailController {
  Widget getThreadDetailLoadingView({
    required bool isResponsiveDesktop,
  }) {
    final isLoading = viewState.value.fold(
      (failure) => false,
      (success) => success is GettingThreadById
    );
    if (!isLoading) return const SizedBox.shrink();

    return Expanded(
      child: Container(
        alignment: Alignment.center,
        color: Colors.white,
        margin: isResponsiveDesktop
          ? const EdgeInsetsDirectional.only(end: 16)
          : null,
        padding: const EdgeInsets.only(top: 16),
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CupertinoLoadingWidget(),
        ),
      ),
    );
  }
}