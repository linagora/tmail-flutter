
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef OnCancelDownloadActionClick = void Function();

class DownloadingFileDialogBuilder {
  Key? _key;
  String _title = '';
  String _content = '';
  String _actionText = '';
  OnCancelDownloadActionClick? _onCancelDownloadActionClick;

  DownloadingFileDialogBuilder();

  void key(Key key) {
    _key = key;
  }

  void title(String title) {
    _title = title;
  }

  void content(String content) {
    _content = content;
  }

  void actionText(String actionText) {
    _actionText = actionText;
  }

  void addCancelDownloadActionClick(OnCancelDownloadActionClick onCancelDownloadActionClick) {
    _onCancelDownloadActionClick = onCancelDownloadActionClick;
  }

  Widget build() {
    return CupertinoAlertDialog(
      key: _key ?? Key('DownloadingFileBuilder'),
      title: Text(_title, style: TextStyle(fontSize: 17.0, color: Colors.black)),
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
              Text(
                _content,
                style: TextStyle(fontSize: 13.0, color: Colors.black),
                softWrap: false,
                maxLines: 1)
            ],
          ),
        )),
      actions: [
        if (_actionText.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: kIsWeb ? 16 : 0, top: kIsWeb ? 16 : 0),
            child: TextButton(
              onPressed: () => _onCancelDownloadActionClick?.call(),
              child: Text(_actionText, style: TextStyle(fontSize: 17.0, color: AppColor.appColor)),
            ))
      ],
    );
  }
}