
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
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
  final EdgeInsetsGeometry? margin;
  final String? hintText;
  final Color? searchIconColor;
  final double? searchIconSize;
  final TextStyle? inputHintTextStyle;
  final TextStyle? inputTextStyle;
  final bool? autoFocus;
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
    this.searchIconColor,
    this.searchIconSize,
    this.inputHintTextStyle,
    this.inputTextStyle,
    this.autoFocus,
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
          if (hasSearchButton)
            TMailButtonWidget.fromIcon(
              icon: imagePaths.icSearchBar,
              iconColor: searchIconColor,
              iconSize: searchIconSize,
              backgroundColor: Colors.transparent,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              onTapActionCallback: () =>
                onSearchTextAction?.call(searchInputController?.text ?? ''),
            ),
          Expanded(child: _buildSearchInputForm(context)),
          if (suggestionSearch?.isNotEmpty == true ||
              (searchQuery != null && searchQuery!.value.isNotEmpty))
            TMailButtonWidget.fromIcon(
              icon: imagePaths.icClearTextSearch,
              backgroundColor: Colors.transparent,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              onTapActionCallback: () {
                searchInputController?.clear();
                onClearTextSearchAction?.call();
              },
            ),
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

  Widget _buildSearchInputForm(BuildContext context) {
    return TextFieldBuilder(
      key: const Key('search_input_form'),
      textInputAction: TextInputAction.done,
      onTextChange: onTextChangeSearchAction,
      onTextSubmitted: onSearchTextAction,
      cursorColor: AppColor.colorTextButton,
      maxLines: 1,
      textDirection: DirectionUtils.getDirectionByLanguage(context),
      autoFocus: autoFocus ?? true,
      focusNode: searchFocusNode,
      textStyle: inputTextStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
        color: AppColor.colorNameEmail,
        fontSize: 17
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: hintText,
        hintStyle: inputHintTextStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
          color: AppColor.colorHintSearchBar,
          fontSize: 17.0
        ),
        labelStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
          color: AppColor.colorHintSearchBar,
          fontSize: 17.0,
        ),
      ),
      controller: searchInputController,
    );
  }
}