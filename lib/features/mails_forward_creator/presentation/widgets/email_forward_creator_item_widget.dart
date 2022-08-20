import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class EmailForwardCreatorItemWidget extends StatelessWidget {
  final _responsiveUtils = Get.find<ResponsiveUtils>();
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
      padding: EdgeInsets.only(
          top: 15,
          bottom: 15,
          left: _responsiveUtils.isMobile(context) ? 16 : 24,
          right: _responsiveUtils.isMobile(context) ? 0 : 24),
      color: Colors.white,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(emailForward,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black)),
        const Spacer(),
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
