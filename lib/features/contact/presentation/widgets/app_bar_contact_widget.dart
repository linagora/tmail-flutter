
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AppBarContactWidget extends StatelessWidget {

  final _imagePaths = Get.find<ImagePaths>();

  final Function()? onCloseContactView;

  AppBarContactWidget({
      Key? key,
      this.onCloseContactView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Positioned(
        left: 0,
        child: buildIconWeb(
            icon: SvgPicture.asset(_imagePaths.icCloseComposer,
                color: AppColor.colorCloseButton,
                width: 24,
                height: 24,
                fit: BoxFit.fill),
            minSize: 25,
            iconSize: 25,
            iconPadding: const EdgeInsets.all(5),
            splashRadius: 15,
            tooltip: AppLocalizations.of(context).close,
            onTap: onCloseContactView),
      ),
      Center(child: Text(
          AppLocalizations.of(context).contains,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black))),
    ]);
  }
}