
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnNewSearchQuery = Function(String);

class SearchFormWidgetBuilder {

  final _typeAheadController = TextEditingController();
  final BuildContext _context;
  final ImagePaths _imagePaths;

  OnNewSearchQuery? _onNewSearchQuery;

  SearchFormWidgetBuilder(this._context, this._imagePaths);

  SearchFormWidgetBuilder onNewSearchQuery(OnNewSearchQuery onNewSearchQuery) {
    _onNewSearchQuery = onNewSearchQuery;
    return this;
  }

  Widget build() {
    return Container(
      key: const Key('search_folder_form'),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.searchBorderColor),
        color: AppColor.primaryLightColor),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _typeAheadController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: const EdgeInsets.only(left: 0, top: 15, bottom: 15, right: 15),
            hintText: AppLocalizations.of(_context).search_folder,
            hintStyle: const TextStyle(color: AppColor.searchHintTextColor, fontSize: 15.0, fontWeight: FontWeight.w500),
            icon: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: SvgPicture.asset(_imagePaths.icSearch, width: 24, height: 24, fit: BoxFit.fill),
            ))),
        debounceDuration: const Duration(milliseconds: 300),
        suggestionsCallback: (pattern) async {
          if (_onNewSearchQuery != null) {
            _onNewSearchQuery!(pattern);
          }
          return [];
        },
        itemBuilder: (BuildContext context, itemData) => const SizedBox.shrink(),
        onSuggestionSelected: (suggestion) {},
        noItemsFoundBuilder: (context) => const SizedBox(),
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: true,
        hideSuggestionsOnKeyboardHide: true,
      ));
  }
}