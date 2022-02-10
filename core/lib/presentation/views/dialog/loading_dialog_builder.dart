
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';

class LoadingDialogBuilder {
  final Key _key;
  final String _title;

  LoadingDialogBuilder(this._key, this._title);

  Widget build() {
    return CupertinoAlertDialog(
      key: _key,
      title: Text(_title, style: TextStyle(fontSize: 17.0, color: AppColor.appColor)),
      content: Padding(
        padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 20.0,
                height: 20.0,
                child: CupertinoActivityIndicator()),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}