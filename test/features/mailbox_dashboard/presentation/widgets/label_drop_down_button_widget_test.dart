import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/label_drop_down_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

final _imagePaths = ImagePaths();
final _labelA = Label(id: Id('label-a'), displayName: 'Label A');
final _labelB = Label(id: Id('label-b'), displayName: 'Label B');

Widget _makeTestable(Widget child) {
  return GetMaterialApp(
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: LocalizationService.supportedLocales,
    locale: LocalizationService.defaultLocale,
    home: Scaffold(body: child),
  );
}

bool _hasSvgWithAsset(WidgetTester tester, String assetName) {
  return tester.widgetList<SvgPicture>(find.byType(SvgPicture)).any(
    (svg) =>
        svg.bytesLoader is SvgAssetLoader &&
        (svg.bytesLoader as SvgAssetLoader).assetName == assetName,
  );
}

LabelDropDownButton _buildDropDown({Label? labelSelected}) {
  return LabelDropDownButton(
    imagePaths: _imagePaths,
    labels: [_labelA, _labelB],
    labelSelected: labelSelected,
    onSelectLabelsActions: (_) {},
  );
}

Future<void> _openDropDown(WidgetTester tester, {Label? labelSelected}) async {
  await tester.pumpWidget(_makeTestable(_buildDropDown(labelSelected: labelSelected)));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(LabelDropDownButton));
  await tester.pumpAndSettle();
}

void main() {
  group('LabelDropDownButton - with a label selected', () {
    testWidgets('selected item shows icChecked icon', (tester) async {
      await _openDropDown(tester, labelSelected: _labelA);

      expect(
        _hasSvgWithAsset(tester, _imagePaths.icChecked),
        isTrue,
        reason: 'Selected item must show icChecked (right-side check icon)',
      );
    });

    testWidgets('only one check icon shown', (tester) async {
      await _openDropDown(tester, labelSelected: _labelA);

      final checkedIcons = tester
          .widgetList<SvgPicture>(find.byType(SvgPicture))
          .where(
            (svg) =>
                svg.bytesLoader is SvgAssetLoader &&
                (svg.bytesLoader as SvgAssetLoader).assetName ==
                    _imagePaths.icChecked,
          )
          .length;

      expect(
        checkedIcons,
        equals(1),
        reason: 'Only the selected item should show icChecked',
      );
    });

    testWidgets('no left-side checkbox icons shown', (tester) async {
      await _openDropDown(tester, labelSelected: _labelA);

      expect(
        _hasSvgWithAsset(tester, _imagePaths.icCheckboxSelected),
        isFalse,
        reason: 'Old left-side checkbox icon must not appear',
      );
      expect(
        _hasSvgWithAsset(tester, _imagePaths.icCheckboxUnselected),
        isFalse,
        reason: 'Old left-side unselected checkbox must not appear',
      );
    });
  });

  group('LabelDropDownButton - with no label selected', () {
    testWidgets('All Labels item shows icChecked', (tester) async {
      await _openDropDown(tester, labelSelected: null);

      final checkedIconFinder = find.byWidgetPredicate(
        (widget) =>
            widget is SvgPicture &&
            widget.bytesLoader is SvgAssetLoader &&
            (widget.bytesLoader as SvgAssetLoader).assetName ==
                _imagePaths.icChecked,
      );

      // Collect Row ancestors of the "All labels" text and the checked icon.
      // The intersection is non-empty iff the icon lives in the same row.
      final rowsOfText = tester
          .widgetList(
            find.ancestor(
              of: find.text('All labels'),
              matching: find.byType(Row),
            ),
          )
          .toSet();

      final rowsOfIcon = tester
          .widgetList(
            find.ancestor(
              of: checkedIconFinder,
              matching: find.byType(Row),
            ),
          )
          .toSet();

      expect(
        rowsOfText.intersection(rowsOfIcon).isNotEmpty,
        isTrue,
        reason: 'icChecked must appear in the same row as the "All labels" menu item',
      );
    });
  });
}
