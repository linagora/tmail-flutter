
import 'package:byte_converter/byte_converter.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/download/download_task_state.dart';

class DownloadTaskItemWidget extends StatelessWidget with AppLoaderMixin {

  final DownloadTaskState taskState;

  const DownloadTaskItemWidget(this.taskState, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _imagePaths = Get.find<ImagePaths>();

    return Container(
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      width: 240,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 12),
          Container(
            width: 30,
            color: Colors.transparent,
            height: 30,
            child: Stack(alignment: Alignment.center, children: [
              SvgPicture.asset(
                  taskState.attachment.getIcon(_imagePaths),
                  width: 16,
                  height: 16,
                  fit: BoxFit.fill),
              circularPercentLoadingWidget(taskState.percentDownloading)
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(taskState.attachment.generateFileName(),
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                    '${ByteConverter(taskState.downloaded.toDouble()).toHumanReadable(SizeUnit.MB)}/'
                        '${ByteConverter(taskState.total.toDouble()).toHumanReadable(SizeUnit.MB)}',
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 12))
              ],
            ),
          )
        ],
      ),
    );
  }
}