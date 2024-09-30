
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/cupertino.dart';
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
    return Dialog(
      key: _key ?? const Key('DownloadingFileBuilder'),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 20
              ),
              child: Text(
                _title,
                style: const TextStyle(
                  fontSize: 17.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            const SizedBox(
              width: 20.0,
              height: 20.0,
              child: CupertinoActivityIndicator()
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Text(
                _content,
                style: const TextStyle(
                  fontSize: 13.0,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2
              ),
            ),
            const SizedBox(height: 16),
            if (_actionText.isNotEmpty && _onCancelDownloadActionClick != null)
              ... [
                const Divider(),
                TextButton(
                  onPressed: _onCancelDownloadActionClick,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColor.primaryColor,
                    overlayColor: Colors.black12,
                    fixedSize: const Size.fromWidth(250),
                  ),
                  child: Text(
                    _actionText,
                    style: const TextStyle(
                      fontSize: 17.0,
                      color: AppColor.primaryColor
                    )
                  ),
                )
              ]
          ],
        ),
      ),
    );
  }
}