
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

typedef OnCancelSearchPressed = Function();
typedef OnClearTextSearchAction = Function();
typedef OnTextChangeSearchAction = Function(String);
typedef OnSearchTextAction = Function(String);

class SearchAppBarWidget {
 OnCancelSearchPressed? _onCancelSearchPressed;
 OnTextChangeSearchAction? _onTextChangeSearchAction;
 OnClearTextSearchAction? _onClearTextSearchAction;
 OnSearchTextAction? _onSearchTextAction;

  final ImagePaths _imagePaths;
  final SearchQuery? _searchQuery;
  final TextEditingController? _searchInputController;
  final FocusNode? _searchFocusNode;
  final List<String>? suggestionSearch;
  final bool hasBackButton;
  final bool hasSearchButton;

  double? _heightSearchBar;
  Decoration? _decoration;
  EdgeInsets? _padding;
  EdgeInsets? _margin;
  String? _hintText;
  Widget? _iconClearText;

  SearchAppBarWidget(
    this._imagePaths,
    this._searchQuery,
    this._searchFocusNode,
    this._searchInputController,
     {
       this.hasBackButton = true,
       this.suggestionSearch,
       this.hasSearchButton = false,
     }
  );

  void addOnCancelSearchPressed(OnCancelSearchPressed onCancelSearchPressed) {
    _onCancelSearchPressed = onCancelSearchPressed;
  }

  void addOnTextChangeSearchAction(OnTextChangeSearchAction onTextChangeSearchAction) {
    _onTextChangeSearchAction = onTextChangeSearchAction;
  }

  void addOnClearTextSearchAction(OnClearTextSearchAction onClearTextSearchAction) {
    _onClearTextSearchAction = onClearTextSearchAction;
  }

  void addOnSearchTextAction(OnSearchTextAction onSearchTextAction) {
    _onSearchTextAction = onSearchTextAction;
  }

  void setHeightSearchBar(double heightSearchBar) {
    _heightSearchBar = heightSearchBar;
  }

  void addDecoration(Decoration decoration) {
    _decoration = decoration;
  }

  void addPadding(EdgeInsets padding) {
    _padding = padding;
  }

  void setMargin(EdgeInsets margin) {
    _margin = margin;
  }

  void setHintText(String text) {
    _hintText = text;
  }

  void addIconClearText(Widget? icon) {
    _iconClearText = icon;
  }

  Widget build() {
    return Container(
      key: Key('search_app_bar_widget'),
      alignment: Alignment.topCenter,
      height: _heightSearchBar,
      decoration: _decoration,
      padding: _padding ?? EdgeInsets.symmetric(vertical: 8),
      margin: _margin,
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasBackButton) _buildBackButton(),
            if (hasSearchButton) _buildSearchButton(),
            Expanded(child: _buildSearchInputForm()),
            if (suggestionSearch?.isNotEmpty == true || (_searchQuery != null && _searchQuery!.value.isNotEmpty))
              _buildClearTextSearchButton(),
          ]
        )
      )
    );
  }

 Widget _buildBackButton() {
   return Material(
     shape: CircleBorder(),
     color: Colors.transparent,
     child: Padding(
       padding: EdgeInsets.only(left: 8),
       child: IconButton(
         splashRadius: 20,
         color: AppColor.appColor,
         icon: SvgPicture.asset(_imagePaths.icBack, color: AppColor.appColor, fit: BoxFit.fill),
         onPressed: () {
           _searchInputController?.clear();
           if (_onCancelSearchPressed != null) {
             _onCancelSearchPressed!();
           }
         }
       )));
 }

 Widget _buildClearTextSearchButton() {
   return Material(
       shape: CircleBorder(),
     color: Colors.transparent,
     child: IconButton(
         splashRadius: 20,
         padding: EdgeInsets.zero,
         icon: _iconClearText ?? SvgPicture.asset(_imagePaths.icComposerClose, fit: BoxFit.fill),
         onPressed: () {
           _searchInputController?.clear();
           _onClearTextSearchAction?.call();
         }
      )
   );
 }

  Widget _buildSearchInputForm() {
    return (TextFieldBuilder()
        ..key(Key('search_input_form'))
        ..textInputAction(TextInputAction.done)
        ..onChange((value) => _onTextChangeSearchAction?.call(value))
        ..onSubmitted((value) => _onSearchTextAction?.call(value))
        ..cursorColor(AppColor.colorTextButton)
        ..autoFocus(true)
        ..addFocusNode(_searchFocusNode)
        ..textStyle(TextStyle(color: AppColor.colorNameEmail, fontSize: 17))
        ..textDecoration(InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 7),
            hintText: _hintText,
            hintStyle: TextStyle(color: AppColor.colorHintSearchBar, fontSize: 17.0),
            labelStyle: TextStyle(color: AppColor.colorHintSearchBar, fontSize: 17.0)))
        ..addController(_searchInputController))
      .build();
  }

 Widget _buildSearchButton() {
   return Material(
       shape: CircleBorder(),
       color: Colors.transparent,
       child: IconButton(
           splashRadius: 20,
           icon: SvgPicture.asset(_imagePaths.icSearchBar, width: 18, height: 18, fit: BoxFit.fill),
           onPressed: () => _onSearchTextAction?.call(_searchInputController?.text ?? '')
       )
   );
 }
}