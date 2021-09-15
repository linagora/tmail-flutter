
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

typedef OnCloseContextMenuAction = void Function();

class ContextMenuBuilder {

  final BuildContext _context;
  final List<Widget> _actionTiles = [];
  final bool areTilesHorizontal;

  Widget? _header;
  Widget? _footer;
  OnCloseContextMenuAction? _onCloseContextMenuAction;

  ContextMenuBuilder(
    this._context,
    {
      this.areTilesHorizontal = false
    }
  );

  void addTiles(List<Widget> tiles) {
    _actionTiles.addAll(tiles);
  }

  void addHeader(Widget header) {
    _header = header;
  }

  void addFooter(Widget footer) {
    _footer = footer;
  }

  void addOnCloseContextMenuAction(OnCloseContextMenuAction onCloseContextMenuAction) {
    _onCloseContextMenuAction = onCloseContextMenuAction;
  }

  RoundedRectangleBorder _shape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0)));
  }

  BoxDecoration _decoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(20.0),
        topRight: const Radius.circular(20.0)));
  }

  void build() {
    Get.bottomSheet(
      GestureDetector(
        onTap: () {
          if (_onCloseContextMenuAction != null) {
            _onCloseContextMenuAction!();
          }},
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.zero,
            decoration: _decoration(_context),
            child: GestureDetector(
              onTap: () => {},
              child: Wrap(
                children: [
                  _header ?? SizedBox.shrink(),
                  Divider(),
                  areTilesHorizontal
                      ? Row(children: [
                          ..._actionTiles,
                          _actionTiles.isNotEmpty && _footer != null ? Divider() : SizedBox.shrink()
                        ])
                      : Column(children: [
                          ..._actionTiles,
                          _actionTiles.isNotEmpty && _footer != null ? Divider() : SizedBox.shrink()
                        ]),
                  _footer != null
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Wrap(children: [_footer ?? SizedBox.shrink()]))
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
      useRootNavigator: true,
      shape: _shape(),
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent
    );
  }
}