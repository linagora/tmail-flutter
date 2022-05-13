import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/thread/data/model/recent_search_hive_cache.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_filter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSelectedRecentSeacrh = Function(String);
typedef OnTappedFilter = Function(SearchFilter);

class SuggestionBoxWidget {
  OnSelectedRecentSeacrh? _onSelectedRecentSearch;
  OnTappedFilter? _onTappedFilter;

  final ImagePaths _imagePaths;
  final BuildContext _context;

  final List<RecentSearchHiveCache> _listData;

  SuggestionBoxWidget(
    this._context,
    this._imagePaths,
    this._listData,
  );

  void addOnTappedFilter(OnTappedFilter onTappedFilter) {
    _onTappedFilter = onTappedFilter;
  }

  void addOnSelectedRecentSearch(
      OnSelectedRecentSeacrh onSelectedRecentSearch) {
    _onSelectedRecentSearch = onSelectedRecentSearch;
  }

  Widget suggestionFilterItem(
      String title, String iconPath, SearchFilter filterType) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: () {
          _onTappedFilter?.call(filterType);
        },
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
                      fontSize: 13,
                      color: AppColor.colorTextButtonHeaderThread),
                ),
              ],
            ),
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
              offset: const Offset(0, 0),
            ),
          ],
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          )),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SizedBox(
            height: (_listData.length * 48) + 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    suggestionFilterItem(
                        AppLocalizations.of(_context).has_attachment,
                        _imagePaths.icAttachmentsFilter,
                        SearchFilter.HAS_ATTACHMENT),
                    suggestionFilterItem(
                        AppLocalizations.of(_context).last_seven_days,
                        _imagePaths.icCalendarFilter,
                        SearchFilter.LAST_SEVEN_DAYS),
                    suggestionFilterItem(
                        AppLocalizations.of(_context).from_me,
                        _imagePaths.icProfileFilter,
                        SearchFilter.FROM_ME),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  AppLocalizations.of(_context).recent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColor.colorTextButtonHeaderThread),
                ),
                const SizedBox(
                  height: 8,
                ),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _listData.map((e) {
                          return recentSearchItem(e);
                        }).toList())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget recentSearchItem(RecentSearchHiveCache data) {
    return InkWell(
      onTap: () {
        if (_onSelectedRecentSearch != null) {
          _onSelectedRecentSearch!(data.value.toString());
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          height: 32,
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
                data.value.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
