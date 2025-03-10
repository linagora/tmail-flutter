import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

typedef OnCopyButtonAction = void Function();

class CopySubaddressWidget extends StatelessWidget {

  final ImagePaths imagePath;
  final String subaddress;

  final OnCopyButtonAction onCopyButtonAction;

  const CopySubaddressWidget({
    super.key,
    required this.imagePath,
    required this.subaddress,
    required this.onCopyButtonAction
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            subaddress,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17.0, color: AppColor.colorMessageDialog),
          ),
        ),
        TMailButtonWidget.fromIcon(
            icon: imagePath.icCopy,
            iconSize: 30,
            padding: const EdgeInsets.all(5),
            backgroundColor: Colors.transparent,
            onTapActionCallback: onCopyButtonAction,
        )
      ],
    );
  }
}