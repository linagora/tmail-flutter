
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnOpenSearchViewAction = Function();
typedef OnOpenAdvancedSearchViewAction = Function();


class SearchBarView {
 OnOpenSearchViewAction? _onOpenSearchViewAction;
 OnOpenAdvancedSearchViewAction? _onOpenAdvancedSearchViewAction;

 final ImagePaths _imagePaths;

  double? _heightSearchBar;
  EdgeInsets? _padding;
  EdgeInsets? _margin;
  String? _hintTextSearch;
  double? _maxSizeWidth;
  bool _checkOpenAdvancedSearch = false;

 SearchBarView(this._imagePaths);

  void addOnOpenSearchViewAction(OnOpenSearchViewAction onOpenSearchViewAction) {
    _onOpenSearchViewAction = onOpenSearchViewAction;
  }

  void addOnOpenAdvancedSearchViewAction(OnOpenAdvancedSearchViewAction onOpenAdvancedSearchViewAction) {
    _onOpenAdvancedSearchViewAction = onOpenAdvancedSearchViewAction;
  }

 void addCheckOpenAdvancedSearch(bool checkOpenAdvancedSearch) {
   _checkOpenAdvancedSearch = checkOpenAdvancedSearch;
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
            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                Expanded(child:
                  Text(
                      _hintTextSearch ?? '',
                      maxLines: 1,
                      style: TextStyle(fontSize: kIsWeb ? 15 : 17, color: AppColor.colorHintSearchBar))),
                if(_onOpenAdvancedSearchViewAction!=null)
                  buildIconWeb(
                    splashRadius: 15,
                    minSize: 40,
                    iconPadding: EdgeInsets.zero,
                    icon: SvgPicture.asset(_imagePaths.icFilterAdvanced,
                        width: 16,
                        height: 16,
                        fit: BoxFit.fill,
                        color: _checkOpenAdvancedSearch ? AppColor.colorFilterMessageEnabled : AppColor.colorFilterMessageDisabled,
                    ),
                    onTap: () => _onOpenAdvancedSearchViewAction?.call()),
              ]
            )),
    );
  }
}