
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/email_receive_time_type.dart';

class EmailReceiveTimeActionTileWidget extends StatelessWidget {

  final EmailReceiveTimeType? receiveTimeSelected;
  final EmailReceiveTimeType receiveTimeType;
  final Function(EmailReceiveTimeType)? onCallBack;

  const EmailReceiveTimeActionTileWidget({
    Key? key,
    this.receiveTimeSelected,
    required this.receiveTimeType,
    this.onCallBack
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

    return InkWell(
        onTap: () => onCallBack?.call(receiveTimeType),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SizedBox(
              width: 320,
              child: Row(children: [
                Expanded(child: Text(
                    receiveTimeType.getTitle(context),
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.normal))),
                if (receiveTimeType == receiveTimeSelected)
                  const SizedBox(width: 12),
                if (receiveTimeType == receiveTimeSelected)
                  SvgPicture.asset(
                      imagePaths.icFilterSelected,
                      width: 24,
                      height: 24,
                      fit: BoxFit.fill),
              ])
          ),
        )
    );
  }
}