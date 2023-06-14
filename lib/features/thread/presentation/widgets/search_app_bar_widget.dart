
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

typedef OnCancelSearchPressed = Function();
typedef OnClearTextSearchAction = Function();
typedef OnTextChangeSearchAction = Function(String);
typedef OnSearchTextAction = Function(String);

class SearchAppBarWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final SearchQuery? searchQuery;
  final TextEditingController? searchInputController;
  final FocusNode? searchFocusNode;
  final List<String>? suggestionSearch;
  final bool hasBackButton;
  final bool hasSearchButton;
  final double? heightSearchBar;
  final Decoration? decoration;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final String? hintText;
  final Widget? iconClearText;
  final OnCancelSearchPressed? onCancelSearchPressed;
  final OnTextChangeSearchAction? onTextChangeSearchAction;
  final OnClearTextSearchAction? onClearTextSearchAction;
  final OnSearchTextAction? onSearchTextAction;

  const SearchAppBarWidget({
    super.key,
    required this.imagePaths,
    required this.hasBackButton,
    required this.hasSearchButton,
    this.searchQuery,
    this.searchInputController,
    this.searchFocusNode,
    this.suggestionSearch,
    this.heightSearchBar,
    this.decoration,
    this.padding,
    this.margin,
    this.hintText,
    this.iconClearText,
    this.onCancelSearchPressed,
    this.onTextChangeSearchAction,
    this.onClearTextSearchAction,
    this.onSearchTextAction
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key ?? const Key('search_app_bar_widget'),
      height: heightSearchBar,
      decoration: decoration,
      padding: padding ?? EdgeInsets.zero,
      margin: margin,
      child: Row(
        children: [
          if (hasBackButton) _buildBackButton(),
          if (hasSearchButton) _buildSearchButton(),
          Expanded(child: _buildSearchInputForm(context)),
          if (suggestionSearch?.isNotEmpty == true || (searchQuery != null && searchQuery!.value.isNotEmpty))
            _buildClearTextSearchButton(),
        ]
      )
    );
  }

 Widget _buildBackButton() {
   return buildIconWeb(
     icon: SvgPicture.asset(
       imagePaths.icBack,
       colorFilter: AppColor.colorTextButton.asFilter(),
       fit: BoxFit.fill),
     onTap: () {
       searchInputController?.clear();
       if (onCancelSearchPressed != null) {
         onCancelSearchPressed!();
       }
     });
 }

 Widget _buildClearTextSearchButton() {
    return buildIconWeb(
      icon: iconClearText ?? SvgPicture.asset(imagePaths.icComposerClose, width: 18, height: 18, fit: BoxFit.fill),
      onTap: () {
        searchInputController?.clear();
        onClearTextSearchAction?.call();
      });
 }

  Widget _buildSearchInputForm(BuildContext context) {
    return TextFieldBuilder(
      key: const Key('search_input_form'),
      textInputAction: TextInputAction.done,
      onTextChange: onTextChangeSearchAction,
      onTextSubmitted: onSearchTextAction,
      cursorColor: AppColor.colorTextButton,
      textDirection: DirectionUtils.getDirectionByLanguage(context),
      autoFocus: true,
      focusNode: searchFocusNode,
      textStyle: const TextStyle(color: AppColor.colorNameEmail, fontSize: 17),
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColor.colorHintSearchBar, fontSize: 17.0),
        labelStyle: const TextStyle(color: AppColor.colorHintSearchBar, fontSize: 17.0)),
      controller: searchInputController,
    );
  }

 Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: buildIconWeb(
        minSize: 40,
        iconPadding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          imagePaths.icSearchBar,
          fit: BoxFit.fill
        ),
        onTap: () => onSearchTextAction?.call(searchInputController?.text ?? '')
      ),
    );
 }
}