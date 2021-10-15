
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:model/model.dart';

class EmailContentItemBuilder {

  final BuildContext _context;
  final EmailContent _emailContent;
  final Widget? loadingWidget;

  EmailContentItemBuilder(
    this._context,
    this._emailContent,
    {
      this.loadingWidget
    }
  );

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: _buildItem()
      )
    );
  }

  Widget _buildItem() {
    switch(_emailContent.type) {
      case EmailContentType.textHtml:
        return HtmlContentViewer(
          widthContent: MediaQuery.of(_context).size.width,
          contentHtml: _emailContent.content,
          loadingWidget: loadingWidget,
          mailtoDelegate: (uri) async {});
      case EmailContentType.textPlain:
        return Padding(
          padding: EdgeInsets.zero,
          child: Text(
            _emailContent.content,
            style: TextStyle(fontSize: 14, color: AppColor.nameUserColor)));
      case EmailContentType.other:
        return SizedBox.shrink();
    }
  }
}