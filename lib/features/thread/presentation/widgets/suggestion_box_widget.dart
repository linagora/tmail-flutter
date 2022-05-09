import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSelectedSuggestion = Function(String);
typedef OnSelectedRecentSeacrh = Function(String);

class SuggestionBoxWidget {
  OnSelectedSuggestion? _onSelectedSuggestion;
  OnSelectedRecentSeacrh? _onSelectedRecentSearch;

  final BuildContext _context;
  final ImagePaths _imagePaths;

  double? _elevation;
  final List<String> _listData;

  SuggestionBoxWidget(
    this._context,
    this._imagePaths,
    this._listData,
  );

  void setElevation(double elevation) {
    _elevation = elevation;
  }

  void addOnSelectedSuggestion(OnSelectedSuggestion onSelectedSuggestion) {
    _onSelectedSuggestion = onSelectedSuggestion;
  }

  void addOnSelectedRecentSearch(OnSelectedSuggestion onSelectedRecentSearch) {
    _onSelectedRecentSearch = onSelectedRecentSearch;
  }

  Widget suggestionFilterItem(String title, String iconPath) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Container(
        height: 32,
        decoration: const BoxDecoration(
            color: AppColor.colorBgSearchBar,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                color: AppColor.baseTextColor,
                fit: BoxFit.fill,
                width: 16,
                height: 16,
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, color: AppColor.colorTextButtonHeaderThread),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget build() {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0.5,
              blurRadius: 2,
              offset: const Offset(2, 2),
            ),
          ],
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          )),
      child: SizedBox(
        height: (_listData.length * 40 + 88),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  suggestionFilterItem(
                      'Has attachment', _imagePaths.icAttachmentsFilter),
                  suggestionFilterItem(
                      'Last 7 days', _imagePaths.icCalendarFilter),
                  suggestionFilterItem('From me', _imagePaths.icProfileFilter),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'Recent',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13, color: AppColor.colorTextButtonHeaderThread),
              ),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 12),
                    itemCount: _listData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          if (_onSelectedRecentSearch != null) {
                            _onSelectedRecentSearch!(_listData[index]);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            height: 24,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  _imagePaths.icClockRecentSearch,
                                  color: AppColor.colorDividerMailbox,
                                  fit: BoxFit.fill,
                                  width: 16,
                                  height: 16,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  _listData[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
