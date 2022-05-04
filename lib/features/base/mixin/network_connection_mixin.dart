
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

mixin NetworkConnectionMixin {

  final _imagePaths = Get.find<ImagePaths>();

  Widget buildNetworkConnectionWidget(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)),
        width: 320,
        margin: const EdgeInsets.only(bottom: 100),
        child: Material(
            elevation: 8,
            shape:  const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            child: ListTile(
                leading: SvgPicture.asset(_imagePaths.icNotConnection),
                title: Text(
                    AppLocalizations.of(context).no_internet_connection,
                    style: const TextStyle(fontSize: 15, color: Colors.black)),
              )
        )
    );
  }
}