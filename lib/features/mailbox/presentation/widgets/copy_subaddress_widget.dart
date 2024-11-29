import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

typedef OnCopyButtonAction = void Function();

class CopySubaddressWidget extends StatelessWidget {

  final BuildContext context;
  final ImagePaths imagePath;
  final String subaddress;

  final OnCopyButtonAction onCopyButtonAction;

  const CopySubaddressWidget({
    super.key,
    required this.context,
    required this.imagePath,
    required this.subaddress,
    required this.onCopyButtonAction
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              subaddress,
              style: const TextStyle(fontSize: 17.0, color: AppColor.colorMessageDialog),
            ),
          ),
          TMailButtonWidget.fromIcon(
              icon: imagePath.icCopy,
              iconSize: 30,
              padding: const EdgeInsets.all(3),
              backgroundColor: Colors.transparent,
              margin: const EdgeInsetsDirectional.only(top: 16, end: 16),
              onTapActionCallback: onCopyButtonAction
          )
        ],
      ),
    );
  }
}