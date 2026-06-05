import 'package:collection/collection.dart';
import 'package:core/domain/extensions/list_datetime_extension.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
// Conditional import resolves to the correct runtime EmailTileBuilder type:
//   mobile → email_tile_builder.dart (StatelessWidget)
//   web    → email_tile_web_builder.dart (StatefulWidget)
// This matches thread_view.dart's own conditional import so find.byType works
// on both platforms without any platform check in callers.
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import '../extensions/patrol_finder_extension.dart';

class SearchRobot extends CoreRobot {
  SearchRobot(super.$);

  Future<void> enterQueryString(String queryString) async {
    final finder = $(#search_email_text_field).$(TextField);
    final isTextFieldFocused = finder
      .which<TextField>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterTextWithoutTapAction(queryString);
  }

  Future<void> scrollToEndListSearchFilter() async {
    await $.scrollUntilVisible(
      finder: $(#mobile_sortBy_search_filter_button),
      view: $(#search_filter_list_view),
      scrollDirection: AxisDirection.right,
      delta: 300,
    );
  }

  Future<void> openSortOrderBottomDialog() => openSortOrderMenu();

  Future<void> openSortOrderMenu() async {
    await $(#mobile_sortBy_search_filter_button).tap();
  }

  Future<void> selectSortOrder(String sortOrderName) async {
    await $(find.text(sortOrderName)).tap();
    await $.pump(const Duration(seconds: 2));
  }

  // Mobile: in-page suggestion ListView carries the #suggestion_search_list_view key.
  // Web overrides this — suggestions live in a PointerInterceptor overlay with no key.
  Future<void> expectSuggestionListVisible() async {
    await $.waitUntilVisible($(#suggestion_search_list_view));
  }

  // Mobile: sortBy opens a bottom sheet keyed #sort_filter_context_menu.
  // Web overrides this — sortBy opens a showMenu popup that has no container key.
  Future<void> expectSortOrderMenuVisible() async {
    await $.waitUntilVisible($(#sort_filter_context_menu));
  }

  Future<void> enterKeyword(String keyword) async {
    final finder = $(SearchEmailView).$(TextFieldBuilder);
    final isTextFieldFocused = finder
      .which<TextFieldBuilder>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterTextWithoutTapAction(keyword);
  }

  Future<void> tapOnShowAllResultsText() async {
    await $.waitUntilVisible($(AppLocalizations().showingResultsFor));
    await $(AppLocalizations().showingResultsFor).tap();
  }

  Future<void> scrollToDateTimeButtonFilter() async {
    await $.scrollUntilVisible(
      finder: $(#mobile_dateTime_search_filter_button),
      view: $(#search_filter_list_view),
      scrollDirection: AxisDirection.right,
      delta: 100,
    );
  }

  Future<void> openDateTimeBottomDialog() async {
    await $(#mobile_dateTime_search_filter_button).tap();
  }

  Future<void> selectDateTime(String dateTimeType) async {
    await $(find.text(dateTimeType)).tap();
    await $.pump(const Duration(seconds: 2));
  }

  Future<void> openEmailWithSubject(String subject) async {
    final email = $(EmailTileBuilder)
      .which<EmailTileBuilder>((view) => view.presentationEmail.subject == subject);
    await $.waitUntilVisible(email);
    await email.tap();
    await $.pump(const Duration(seconds: 2));
  }

  Future<void> tapBackButton() async {
    await $(#search_email_back_button).tap();
  }

  Future<void> selectAttachmentFilter() async {
    await $.scrollUntilVisible(
      finder: $(#mobile_hasAttachment_search_filter_button),
      view: $(#search_filter_list_view),
      scrollDirection: AxisDirection.right,
      delta: 50,
    );
    await $(#mobile_hasAttachment_search_filter_button).tap();
  }

  Future<void> openLabelListModal() async {
    await $(#mobile_labels_search_filter_button).tap();
  }

  // ─── Email list assertions ────────────────────────────────────────────────
  // The conditional import above ensures EmailTileBuilder resolves to the correct
  // runtime type on each platform, so find.byType and widgetList work correctly
  // on both mobile and web without any override in the platform subclasses.

  Future<void> expectEmailListCount(int count) async {
    expect(find.byType(EmailTileBuilder), findsNWidgets(count));
  }

  Future<void> expectEmailListSortedBySenderAscending(List<String> listUsername) async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    for (int i = 0; i < listUsername.length; i++) {
      final sender = tiles.elementAt(i).presentationEmail.firstEmailAddressInFrom;
      expect(sender, equals('${listUsername[i].toLowerCase()}@example.com'));
    }
  }

  Future<void> expectEmailListSortedBySenderDescending(List<String> listUsername) async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    final reversed = listUsername.reversed.toList();
    for (int i = 0; i < reversed.length; i++) {
      final sender = tiles.elementAt(i).presentationEmail.firstEmailAddressInFrom;
      expect(sender, equals('${reversed[i].toLowerCase()}@example.com'));
    }
  }

  Future<void> expectEmailListSortedBySubjectAscending(List<String> listUsername) async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    for (int i = 0; i < listUsername.length; i++) {
      expect(tiles.elementAt(i).presentationEmail.subject, equals('${listUsername[i]} send Bob'));
    }
  }

  Future<void> expectEmailListSortedBySubjectDescending(List<String> listUsername) async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    final reversed = listUsername.reversed.toList();
    for (int i = 0; i < reversed.length; i++) {
      expect(tiles.elementAt(i).presentationEmail.subject, equals('${reversed[i]} send Bob'));
    }
  }

  Future<void> expectEmailListSortedByMostRecent() async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    final dates = tiles
      .map((t) => t.presentationEmail.receivedAt?.value)
      .nonNulls
      .toList();
    expect(dates.isSortedByMostRecent(), isTrue);
  }

  Future<void> expectEmailListSortedByOldest() async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    final dates = tiles
      .map((t) => t.presentationEmail.receivedAt?.value)
      .nonNulls
      .toList();
    expect(dates.isSortedByOldestFirst(), isTrue);
  }

  Future<void> expectEmailListSortedBySizeAscending() async {
    final sizes = _collectSizes();
    expect(_isSortedAscending(sizes), isTrue);
  }

  Future<void> expectEmailListSortedBySizeDescending() async {
    final sizes = _collectSizes();
    expect(_isSortedAscending(sizes), isFalse);
  }

  List<UnsignedInt> _collectSizes() {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    return tiles
      .mapIndexed((i, _) => tiles.elementAt(i).presentationEmail.size)
      .nonNulls
      .toList();
  }

  bool _isSortedAscending(List<UnsignedInt> list) {
    for (int i = 0; i < list.length - 1; i++) {
      if (list[i].value > list[i + 1].value) return false;
    }
    return true;
  }
}
