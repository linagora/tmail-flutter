import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SendingStateWidget extends StatelessWidget {

  final SendingState sendingState;
  final BoxConstraints? constraints;

  const SendingStateWidget({
    super.key,
    required this.sendingState,
    this.constraints
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = getBinding<ImagePaths>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: sendingState.getBackgroundColor(),
        borderRadius: const BorderRadius.all(Radius.circular(16))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            sendingState.getIcon(imagePath!),
            fit: BoxFit.fill,
            width: 20,
            height: 20
          ),
          const SizedBox(width: 4),
          if (constraints != null)
            ConstrainedBox(
              constraints: constraints!,
              child: Text(
                sendingState.getTitle(context),
                maxLines: 1,
                overflow: CommonTextStyle.defaultTextOverFlow,
                softWrap: CommonTextStyle.defaultSoftWrap,
                style: TextStyle(
                  fontSize: 15,
                  color: sendingState.getTitleColor(),
                  fontWeight: FontWeight.normal
                )
              ),
            )
          else
            Text(
              sendingState.getTitle(context),
              maxLines: 1,
              overflow: CommonTextStyle.defaultTextOverFlow,
              softWrap: CommonTextStyle.defaultSoftWrap,
              style: TextStyle(
                fontSize: 15,
                color: sendingState.getTitleColor(),
                fontWeight: FontWeight.normal
              )
            )
        ]
      ),
    );
  }
}