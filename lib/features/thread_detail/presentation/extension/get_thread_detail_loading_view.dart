import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension GetThreadDetailLoadingView on ThreadDetailController {
  Widget getThreadDetailLoadingView({
    required bool isResponsiveDesktop,
  }) {
    if (!loadingThreadDetail) return const SizedBox.shrink();

    return Expanded(
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
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