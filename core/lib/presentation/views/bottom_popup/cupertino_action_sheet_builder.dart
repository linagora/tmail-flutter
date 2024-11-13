
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class CupertinoActionSheetBuilder {

  final BuildContext _context;
  final Key? key;
  final List<Widget> _actionTiles = [];

  Widget? _titleWidget;
  Widget? _messageWidget;
  Widget? _cancelWidget;

  CupertinoActionSheetBuilder(this._context, {this.key});

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

  Future<dynamic> show() {
    return showCupertinoModalPopup(
      context: _context,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      builder: (context) => PointerInterceptor(child: CupertinoActionSheet(
        key: key,
        title: _titleWidget,
        message: _messageWidget,
        actions: _actionTiles,
        cancelButton: _cancelWidget,
      ))
    );
  }
}