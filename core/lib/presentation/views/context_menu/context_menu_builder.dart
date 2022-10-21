
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

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
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0)));
  }

  BoxDecoration _decoration(BuildContext context) {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0)));
  }

  void build() {
    Get.bottomSheet(
      PointerInterceptor(child: GestureDetector(
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
                  _header ?? const SizedBox.shrink(),
                  const Divider(),
                  areTilesHorizontal
                      ? Row(children: [
                          ..._actionTiles,
                          _actionTiles.isNotEmpty && _footer != null ? const Divider() : const SizedBox.shrink()
                        ])
                      : Column(children: [
                          ..._actionTiles,
                          _actionTiles.isNotEmpty && _footer != null ? const Divider() : const SizedBox.shrink()
                        ]),
                  _footer != null
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Wrap(children: [_footer ?? const SizedBox.shrink()]))
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      )),
      useRootNavigator: true,
      shape: _shape(),
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent
    );
  }
}