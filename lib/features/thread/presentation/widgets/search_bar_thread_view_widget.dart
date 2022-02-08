
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnOpenSearchViewAction = Function();

class SearchBarThreadViewWidget {
 OnOpenSearchViewAction? _onOpenSearchViewAction;

 final BuildContext _context;
 final ImagePaths _imagePaths;

  double? _heightSearchBar;
  EdgeInsets? _padding;
  EdgeInsets? _margin;

 SearchBarThreadViewWidget(
    this._context,
    this._imagePaths,
  );

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

  Widget build() {
    return GestureDetector(
      onTap: () => _onOpenSearchViewAction?.call(),
      child: Container(
          key: Key('search_bar_widget'),
          alignment: Alignment.topCenter,
          height: _heightSearchBar ?? 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorBgSearchBar),
          padding: _padding ?? EdgeInsets.zero,
          margin: _margin ?? EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: MediaQuery(
              data: MediaQueryData(padding: EdgeInsets.zero),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSearchButton(),
                  Text(
                    AppLocalizations.of(_context).hint_search_emails,
                    style: TextStyle(fontSize: 17, color: AppColor.colorHintSearchBar),)
                ]
              )
          )
      ),
    );
  }

 Widget _buildSearchButton() {
   return Material(
     borderRadius: BorderRadius.circular(12),
     color: Colors.transparent,
     child: Padding(
       padding: EdgeInsets.only(left: 2),
       child: IconButton(
         color: AppColor.appColor,
         icon: SvgPicture.asset(_imagePaths.icSearchBar, width: 18, height: 18, fit: BoxFit.fill),
         onPressed: () => _onOpenSearchViewAction?.call()
       )
     )
   );
 }
}