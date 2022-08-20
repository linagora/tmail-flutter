import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class EmailForwardCreatorItemWidget extends StatelessWidget {
  final _imagePaths = Get.find<ImagePaths>();
  final VoidCallback onDelete;
  final String emailForward;

  EmailForwardCreatorItemWidget({
    Key? key,
    required this.emailForward,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.white,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        CircleAvatar(
            backgroundColor: AppColor.colorTextButton,
            radius: 16,
            child: Text(emailForward[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500))),
        const SizedBox(width: 10),
        Expanded(child: Text(emailForward,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black))),
        buildIconWeb(
            icon: SvgPicture.asset(
              _imagePaths.icDeleteEmailAddress,
              fit: BoxFit.fill,
            ),
            onTap: onDelete),
      ]),
    );
  }
}
