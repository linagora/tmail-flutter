
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class StorageWidgetBuilder {
  final BuildContext _context;

  StorageWidgetBuilder(this._context);

  Widget build() {
    return Container(
      key: const Key('storage_widget'),
      padding: const EdgeInsets.only(left: 40, top: 16, bottom: 20, right: 40),
      color: AppColor.storageBackgroundColor,
      alignment: Alignment.bottomLeft,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(_context).storage,
            maxLines: 1,
            style: const TextStyle(fontSize: 12, color: AppColor.storageTitleColor, fontWeight: FontWeight.w500)),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: AppColor.storageMaxSizeColor, fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                    text: '299.6MB',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColor.storageUseSizeColor)),
                  TextSpan(
                    text: ' / unlimited',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColor.storageMaxSizeColor))
                ]
              )
            )
          )
        ]
      )
    );
  }
}