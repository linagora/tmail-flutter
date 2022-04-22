
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSelectedSuggestion = Function(String);

class SuggestionBoxWidget {

  OnSelectedSuggestion? _onSelectedSuggestion;

  final BuildContext _context;
  final ImagePaths _imagePaths;

  double? _suggestionHeight;
  double? _elevation;
  final List<String> _listData;

  SuggestionBoxWidget(
    this._context,
    this._imagePaths,
    this._listData,
  );

  void setSuggestionHeight(double suggestionHeight) {
    _suggestionHeight = suggestionHeight;
  }

  void setElevation(double elevation) {
    _elevation = elevation;
  }

  void addOnSelectedSuggestion(OnSelectedSuggestion onSelectedSuggestion) {
    _onSelectedSuggestion = onSelectedSuggestion;
  }

  Widget build() {
    return Material(
      elevation: _elevation ?? 3,
      color: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: _suggestionHeight ?? 60,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _listData.length,
          itemBuilder: (BuildContext context, int index) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            onTap: () {
              if (_onSelectedSuggestion != null) {
                _onSelectedSuggestion!(_listData[index]);
              }},
            leading: IconButton(
              color: AppColor.baseTextColor,
              icon: SvgPicture.asset(_imagePaths.icSearch, color: AppColor.baseTextColor, fit: BoxFit.fill),
              onPressed: () {
                if (_onSelectedSuggestion != null) {
                  _onSelectedSuggestion!(_listData[index]);
                }
              }),
            title: Transform(
              transform: Matrix4.translationValues(-12.0, 0.0, 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(_context).prefix_suggestion_search} ',
                    style: const TextStyle(fontSize: 15, color: AppColor.baseTextColor),
                  ),
                  Expanded(child: Text(
                    '"${_listData[index]}"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, color: AppColor.colorNameEmail),
                  ))
                ],
              )
            )
          ),
        ),
      ),
    );
  }
}