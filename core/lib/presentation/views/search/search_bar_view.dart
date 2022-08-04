
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnOpenSearchViewAction = Function();

class SearchBarView {
  OnOpenSearchViewAction? _onOpenSearchViewAction;

  final ImagePaths _imagePaths;

  double? _heightSearchBar;
  EdgeInsets? _padding;
  EdgeInsets? _margin;
  String? _hintTextSearch;
  double? _maxSizeWidth;
  Widget? _rightButton;


  SearchBarView(this._imagePaths);

  void addOnOpenSearchViewAction(OnOpenSearchViewAction onOpenSearchViewAction) {
    _onOpenSearchViewAction = onOpenSearchViewAction;
  }

  void setHeightSearchBar(double heightSearchBar) {
    _heightSearchBar = heightSearchBar;
  }

  void addPadding(EdgeInsets padding) {
    _padding = padding;
  }

  void addRightButton(Widget rightButton) {
    _rightButton = rightButton;
  }

  void addMargin(EdgeInsets margin) {
    _margin = margin;
  }

  void hintTextSearch(String text) {
    _hintTextSearch = text;
  }

  void maxSizeWidth(double? size) {
    _maxSizeWidth = size;
  }

  Widget build() {
    return Container(
        key: Key('search_bar_widget'),
        alignment: Alignment.center,
        height: _heightSearchBar ?? 40,
        width: _maxSizeWidth ?? double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColor.colorBgSearchBar),
        padding: _padding ?? EdgeInsets.zero,
        margin: _margin ?? EdgeInsets.zero,
        child: InkWell(
          onTap: () => _onOpenSearchViewAction?.call(),
          mouseCursor: SystemMouseCursors.text,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              buildIconWeb(
                  splashRadius: 15,
                  minSize: 40,
                  iconPadding: EdgeInsets.zero,
                  icon: SvgPicture.asset(_imagePaths.icSearchBar, width: 16, height: 16, fit: BoxFit.fill),
                  onTap: () => _onOpenSearchViewAction?.call()),
              Expanded(
                child: Text(
                    _hintTextSearch ?? '',
                    maxLines: 1,
                    style: TextStyle(fontSize: kIsWeb ? 15 : 17, color: AppColor.colorHintSearchBar)),
              ),
              if(_rightButton != null)
                _rightButton!
            ]
          ),
        ),
    );
  }
}