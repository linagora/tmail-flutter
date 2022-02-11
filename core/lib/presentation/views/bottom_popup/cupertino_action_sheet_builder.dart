
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';

class CupertinoActionSheetBuilder {

  final BuildContext _context;
  final List<Widget> _actionTiles = [];

  Widget? _titleWidget;
  Widget? _messageWidget;
  Widget? _cancelWidget;

  CupertinoActionSheetBuilder(this._context);

  void title(Widget? titleWidget) {
    _titleWidget = titleWidget;
  }

  void message(Widget? messageWidget) {
    _messageWidget = messageWidget;
  }

  void addCancelButton(Widget? cancelWidget) {
    _cancelWidget = cancelWidget;
  }

  void addTiles(List<Widget> tiles) {
    _actionTiles.addAll(tiles);
  }

  void build() {
    showCupertinoModalPopup(
      context: _context,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      builder: (context) => CupertinoActionSheet(
        title: _titleWidget,
        message: _messageWidget,
        actions: _actionTiles,
        cancelButton: _cancelWidget,
      )
    );
  }
}