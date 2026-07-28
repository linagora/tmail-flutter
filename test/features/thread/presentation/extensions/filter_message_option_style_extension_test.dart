import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/filter_message_option_style_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  final imagePaths = ImagePaths();
  final appLocalizations = AppLocalizations();

  const nonAllOptions = [
    FilterMessageOption.unread,
    FilterMessageOption.attachments,
    FilterMessageOption.starred,
  ];

  /// Pumps a localized app and hands a [BuildContext] with
  /// [AppLocalizations] available to [body].
  Future<void> withLocalizedContext(
    WidgetTester tester,
    void Function(BuildContext context) body,
  ) async {
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      locale: LocalizationService.defaultLocale,
      home: Scaffold(body: SizedBox()),
    ));
    await tester.pumpAndSettle();
    body(tester.element(find.byType(SizedBox)));
  }

  group('getIcon / getIconColor: all vs the rest', () {
    test('all uses the advanced-filter icon and its own colour', () {
      expect(FilterMessageOption.all.getIcon(imagePaths),
          imagePaths.icFilterAdvanced);
      expect(FilterMessageOption.all.getIconColor(),
          AppColor.colorFilterMessageIcon);
    });

    test('non-all options share the selected icon and primary colour', () {
      for (final option in nonAllOptions) {
        expect(option.getIcon(imagePaths), imagePaths.icSelectedSB);
        expect(option.getIconColor(), AppColor.primaryColor);
      }
    });
  });

  group('per-option icons', () {
    test('toast and context-menu icons map per option', () {
      final expectedIcons = {
        FilterMessageOption.all: (
          toast: imagePaths.icFilterMessageAll,
          menu: '',
        ),
        FilterMessageOption.unread: (
          toast: imagePaths.icUnreadToast,
          menu: imagePaths.icUnread,
        ),
        FilterMessageOption.attachments: (
          toast: imagePaths.icFilterMessageAttachments,
          menu: imagePaths.icAttachment,
        ),
        FilterMessageOption.starred: (
          toast: imagePaths.icStar,
          menu: imagePaths.icUnStar,
        ),
      };

      for (final entry in expectedIcons.entries) {
        expect(entry.key.getIconToast(imagePaths), entry.value.toast,
            reason: '${entry.key} toast icon');
        expect(entry.key.getContextMenuIcon(imagePaths), entry.value.menu,
            reason: '${entry.key} context-menu icon');
      }
    });
  });

  group('getName', () {
    test('all has no name; others map to their label', () {
      final expectedNames = {
        FilterMessageOption.all: '',
        FilterMessageOption.unread: appLocalizations.unread,
        FilterMessageOption.attachments: appLocalizations.with_attachments,
        FilterMessageOption.starred: appLocalizations.starred,
      };

      for (final entry in expectedNames.entries) {
        expect(entry.key.getName(appLocalizations), entry.value,
            reason: '${entry.key} name');
      }
    });
  });

  group('getTitle', () {
    testWidgets('maps every option to its localized title', (tester) async {
      await withLocalizedContext(tester, (context) {
        final expectedTitles = {
          FilterMessageOption.all: appLocalizations.filter_messages,
          FilterMessageOption.unread: appLocalizations.with_unread,
          FilterMessageOption.attachments: appLocalizations.with_attachments,
          FilterMessageOption.starred: appLocalizations.with_starred,
        };

        for (final entry in expectedTitles.entries) {
          expect(entry.key.getTitle(context), entry.value,
              reason: '${entry.key} title');
        }
      });
    });
  });

  group('getMessageToast', () {
    testWidgets(
        'all announces the disabled filter; others quote their name',
        (tester) async {
      await withLocalizedContext(tester, (context) {
        expect(FilterMessageOption.all.getMessageToast(context),
            appLocalizations.disable_filter_message_toast);

        for (final option in nonAllOptions) {
          expect(
              option.getMessageToast(context),
              appLocalizations
                  .filter_message_toast(option.getName(appLocalizations)),
              reason: '$option toast message');
        }
      });
    });
  });

  group('getBackgroundColor', () {
    test('selection toggles the background for every option', () {
      for (final option in FilterMessageOption.values) {
        expect(option.getBackgroundColor(isSelected: true),
            AppColor.primaryColor.withValues(alpha: 0.06),
            reason: '$option selected background');
        expect(option.getBackgroundColor(),
            AppColor.colorFilterMessageButton.withValues(alpha: 0.6),
            reason: '$option unselected background');
      }
    });
  });

  group('getTextStyle', () {
    test('all uses the neutral title colour; others the primary colour', () {
      expect(FilterMessageOption.all.getTextStyle().color,
          AppColor.colorFilterMessageTitle);

      for (final option in nonAllOptions) {
        expect(option.getTextStyle().color, AppColor.primaryColor,
            reason: '$option text colour');
      }
    });
  });
}
