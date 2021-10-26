
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCancelSearchPressed = Function();
typedef OnClearTextSearchAction = Function();
typedef OnSuggestionSearchQuery = Function(String);
typedef OnSearchTextAction = Function(String);

class SearchAppBarWidget {
 OnCancelSearchPressed? _onCancelSearchPressed;
 OnSuggestionSearchQuery? _onSuggestionSearchQuery;
 OnClearTextSearchAction? _onClearTextSearchAction;
 OnSearchTextAction? _onSearchTextAction;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final SearchQuery? _searchQuery;
  final TextEditingController? _searchInputController;
  final FocusNode? _searchFocusNode;
  final List<String>? _suggestionSearch;

  double? _heightSearchBar;
  Decoration? _decoration;
  EdgeInsets? _padding;

  SearchAppBarWidget(
    this._context,
    this._imagePaths,
    this._searchQuery,
    this._suggestionSearch,
    this._searchFocusNode,
    this._searchInputController,
  );

  void addOnCancelSearchPressed(OnCancelSearchPressed onCancelSearchPressed) {
    _onCancelSearchPressed = onCancelSearchPressed;
  }

  void addOnSuggestionSearchQuery(OnSuggestionSearchQuery onSuggestionSearchQuery) {
    _onSuggestionSearchQuery = onSuggestionSearchQuery;
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

  Widget build() {
    return Container(
      key: Key('search_app_bar_widget'),
      alignment: Alignment.topCenter,
      height: _heightSearchBar,
      decoration: _decoration,
      padding: _padding ?? EdgeInsets.symmetric(vertical: 8),
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBackButton(),
            Expanded(child: _buildSearchInputForm()),
            if (_suggestionSearch?.isNotEmpty == true || (_searchQuery != null && _searchQuery!.value.isNotEmpty))
              _buildClearTextSearchButton(),
          ]
        )
      )
    );
  }

 Widget _buildBackButton() {
   return Material(
     borderRadius: BorderRadius.circular(12),
     color: Colors.transparent,
     child: Padding(
       padding: EdgeInsets.only(left: 8),
       child: IconButton(
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
     borderRadius: BorderRadius.circular(12),
     color: Colors.transparent,
     child: Padding(
       padding: EdgeInsets.only(right: 8),
       child: IconButton(
         color: AppColor.baseTextColor,
         icon: SvgPicture.asset(_imagePaths.icComposerClose, color: AppColor.baseTextColor, fit: BoxFit.fill),
         onPressed: () {
           _searchInputController?.clear();
           if (_onClearTextSearchAction != null) {
            _onClearTextSearchAction!();
           }
         }
      )));
 }

  Widget _buildSearchInputForm() {
    return (TextFieldBuilder()
        ..key(Key('search_input_form'))
        ..textInputAction(TextInputAction.done)
        ..onChange((value) {
            if (_onSuggestionSearchQuery != null) {
              _onSuggestionSearchQuery!(value);
            }})
        ..onSubmitted((value) {
            if (_onSearchTextAction != null) {
              _onSearchTextAction!(value);
            }})
        ..cursorColor(AppColor.baseTextColor)
        ..autoFocus(true)
        ..addFocusNode(_searchFocusNode)
        ..textStyle(TextStyle(
            color: _searchQuery != null && _searchQuery!.value.isNotEmpty && _suggestionSearch?.isEmpty == true
              ? AppColor.nameUserColor
              : AppColor.baseTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w500))
        ..textDecoration(InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
            hintText: AppLocalizations.of(_context).search_mail,
            hintStyle: TextStyle(
              color: AppColor.baseTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 15.0),
            labelStyle: TextStyle(
              color: AppColor.baseTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 15.0)))
        ..addController(_searchInputController))
      .build();
  }
}