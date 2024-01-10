import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/styles/sending_state_widget_style.dart';

class SendingStateWidget extends StatelessWidget {

  final SendingState sendingState;
  final BoxConstraints? constraints;

  final _imagePath = Get.find<ImagePaths>();

  SendingStateWidget({
    super.key,
    required this.sendingState,
    this.constraints
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: SendingStateWidgetStyle.padding,
      decoration: BoxDecoration(
        color: sendingState.getBackgroundColor(),
        borderRadius: const BorderRadius.all(Radius.circular(SendingStateWidgetStyle.radius))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (sendingState == SendingState.running)
            const CupertinoLoadingWidget(size: SendingStateWidgetStyle.iconSize)
          else
            SvgPicture.asset(
              sendingState.getIcon(_imagePath),
              fit: BoxFit.fill,
              width: SendingStateWidgetStyle.iconSize,
              height: SendingStateWidgetStyle.iconSize
            ),
          const SizedBox(width: SendingStateWidgetStyle.space),
          if (constraints != null)
            ConstrainedBox(
              constraints: constraints!,
              child: Text(
                sendingState.getTitle(context),
                maxLines: 1,
                overflow: CommonTextStyle.defaultTextOverFlow,
                softWrap: CommonTextStyle.defaultSoftWrap,
                style: SendingStateWidgetStyle.getTitleTextStyle(sendingState)
              ),
            )
          else
            Text(
              sendingState.getTitle(context),
              maxLines: 1,
              overflow: CommonTextStyle.defaultTextOverFlow,
              softWrap: CommonTextStyle.defaultSoftWrap,
              style: SendingStateWidgetStyle.getTitleTextStyle(sendingState)
            )
        ]
      ),
    );
  }
}