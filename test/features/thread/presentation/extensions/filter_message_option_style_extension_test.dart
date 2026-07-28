import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/filter_message_option_style_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

void main() {
  final imagePaths = ImagePaths();
  final appLocalizations = AppLocalizations();

  const nonAllOptions = [
    FilterMessageOption.unread,
    FilterMessageOption.attachments,
    FilterMessageOption.starred,
  ];

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
    test('toast and context-menu icons are distinct per option', () {
      expect(FilterMessageOption.starred.getIconToast(imagePaths),
          imagePaths.icStar);
      expect(FilterMessageOption.starred.getContextMenuIcon(imagePaths),
          imagePaths.icUnStar);
      expect(FilterMessageOption.all.getContextMenuIcon(imagePaths), '');
    });
  });

  group('getName', () {
    test('all has no name; others map to their label', () {
      expect(FilterMessageOption.all.getName(appLocalizations), '');
      expect(FilterMessageOption.unread.getName(appLocalizations),
          appLocalizations.unread);
      expect(FilterMessageOption.starred.getName(appLocalizations),
          appLocalizations.starred);
    });
  });
}
