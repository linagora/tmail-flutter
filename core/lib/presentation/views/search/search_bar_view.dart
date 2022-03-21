
import 'package:core/core.dart';
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
    return InkWell(
      onTap: () => _onOpenSearchViewAction?.call(),
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: Container(
          key: Key('search_bar_widget'),
          alignment: Alignment.topCenter,
          height: _heightSearchBar ?? 40,
          width: _maxSizeWidth ?? double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorBgSearchBar),
          padding: _padding ?? EdgeInsets.zero,
          margin: _margin ?? EdgeInsets.zero,
          child: MediaQuery(
              data: MediaQueryData(padding: EdgeInsets.zero),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSearchButton(),
                  Expanded(child: Text(
                    _hintTextSearch ?? '',
                    maxLines: 1,
                    style: TextStyle(fontSize: 17, color: AppColor.colorHintSearchBar)))
                ]
              )
          )
      ),
    );
  }

 Widget _buildSearchButton() {
   return Material(
     color: Colors.transparent,
     shape: CircleBorder(),
     child: Padding(
       padding: EdgeInsets.only(left: 2),
       child: IconButton(
         splashRadius: 20,
         icon: SvgPicture.asset(_imagePaths.icSearchBar, width: 18, height: 18, fit: BoxFit.fill),
         onPressed: () => _onOpenSearchViewAction?.call()
       )
     )
   );
 }
}