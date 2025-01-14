
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';

class DownloadAttachmentLoadingBar extends StatelessWidget {

  final dynamic viewState;

  const DownloadAttachmentLoadingBar({super.key, this.viewState});

  @override
  Widget build(BuildContext context) {
    if (viewState is StartDownloadAttachmentForWeb) {
      return const LinearProgressIndicator(
        color: AppColor.primaryColor,
        minHeight: 5,
        backgroundColor: AppColor.colorProgressLoadingBackground);
    } if (viewState is DownloadingAttachmentForWeb) {
      return LinearPercentIndicator(
        padding: EdgeInsets.zero,
        lineHeight: 5,
        percent: viewState.progress / 100,
        barRadius: const Radius.circular(1),
        backgroundColor: AppColor.colorProgressLoadingBackground,
        progressColor: AppColor.primaryColor);
    } else {
      return const SizedBox.shrink();
    }
  }
}
