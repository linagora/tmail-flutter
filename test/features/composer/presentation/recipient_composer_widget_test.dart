import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_tag_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/language_code_constants.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  group('recipient_composer_widget test', () {
    final imagePaths = ImagePaths();
    final keyEmailTagEditor = GlobalKey<TagsEditorState>();
    const prefix = PrefixEmailAddress.to;

    Widget makeTestableWidget({required Widget child}) {
      return GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        home: Scaffold(body: child),
      );
    }

    testWidgets('RecipientComposerWidget renders correctly', (tester) async {
      final listEmailAddress = <EmailAddress>[];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final recipientComposerWidgetFinder = find.byType(RecipientComposerWidget);

      expect(recipientComposerWidgetFinder, findsOneWidget);
    });

    testWidgets('RecipientComposerWidget renders list email address correctly', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress(null, 'test1@example.com'),
        EmailAddress(null, 'test2@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      expect(find.byType(RecipientTagItemWidget), findsNWidgets(2));
      expect(find.text('test1@example.com'), findsOneWidget);
      expect(find.text('test2@example.com'), findsOneWidget);
    });

    testWidgets('RecipientTagItemWidget should have a `maxWidth` equal to the RecipientComposerWidget\'s `maxWidth`', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress('test1', 'test1@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final recipientTagItemWidgetFinder = find.byKey(Key('recipient_tag_item_${prefix.name}_0'));

      final Container recipientTagItemWidget = tester.widget(recipientTagItemWidgetFinder);

      expect(recipientTagItemWidgetFinder, findsOneWidget);
      expect(recipientTagItemWidget.constraints!.maxWidth, 360);
    });

    testWidgets('WHEN EmailAddress has address is not empty AND display name is not empty\n'
        'RecipientTagItemWidget should have all the components (AvatarIcon, Label, DeleteIcon)', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress('test1', 'test1@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final recipientTagItemWidgetFinder = find.byKey(Key('recipient_tag_item_${prefix.name}_0'));
      final labelRecipientTagItemWidgetFinder = find.byKey(Key('label_recipient_tag_item_${prefix.name}_0'));
      final deleteIconRecipientTagItemWidgetFinder = find.byKey(Key('delete_icon_recipient_tag_item_${prefix.name}_0'));
      final avatarIconRecipientTagItemWidgetFinder = find.byKey(Key('avatar_icon_recipient_tag_item_${prefix.name}_0'));

      final Size recipientTagItemWidgetSize = tester.getSize(recipientTagItemWidgetFinder);
      final Size labelRecipientTagItemWidgetSize = tester.getSize(labelRecipientTagItemWidgetFinder);
      final Size deleteIconRecipientTagItemWidgetSize = tester.getSize(deleteIconRecipientTagItemWidgetFinder);
      final Size avatarIconRecipientTagItemWidgetSize = tester.getSize(avatarIconRecipientTagItemWidgetFinder);

      log('recipient_composer_widget_test::main: TagSize = $recipientTagItemWidgetSize | LabelTagSize = $labelRecipientTagItemWidgetSize | DeleteIconTagSize = $deleteIconRecipientTagItemWidgetSize | AvatarIconTagSize = $avatarIconRecipientTagItemWidgetSize');

      expect(labelRecipientTagItemWidgetFinder, findsOneWidget);
      expect(deleteIconRecipientTagItemWidgetFinder, findsOneWidget);
      expect(avatarIconRecipientTagItemWidgetFinder, findsOneWidget);

      expect(
        labelRecipientTagItemWidgetSize.width + deleteIconRecipientTagItemWidgetSize.width + avatarIconRecipientTagItemWidgetSize.width,
        lessThan(recipientTagItemWidgetSize.width)
      );
    });

    testWidgets('ToRecipientComponentWidget should have all the components (PrefixLabel, RecipientTagItemWidget)', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress('test1', 'test1@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final prefixRecipientComposerWidgetFinder = find.byKey(Key('prefix_${prefix.name}_recipient_composer_widget'));
      final recipientTagItemWidgetFinder = find.byKey(Key('recipient_tag_item_${prefix.name}_0'));

      final Size prefixRecipientComposerWidgetSize = tester.getSize(prefixRecipientComposerWidgetFinder);
      final Size recipientTagItemWidgetSize = tester.getSize(recipientTagItemWidgetFinder);

      log('recipient_composer_widget_test::main: PrefixLabelSize = $prefixRecipientComposerWidgetSize | TagSize = $recipientTagItemWidgetSize');

      expect(prefixRecipientComposerWidgetFinder, findsOneWidget);
      expect(recipientTagItemWidgetFinder, findsOneWidget);
      expect(
        prefixRecipientComposerWidgetSize.width + recipientTagItemWidgetSize.width,
        lessThan(360)
      );
    });

    testWidgets('WHEN EmailAddress has address is too long AND display name is NULL\n'
        'RecipientTagItemWidget should have all the components (Label, DeleteIcon)', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress(null, 'test123456789123456789@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 392.7,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final recipientTagItemWidgetFinder = find.byKey(Key('recipient_tag_item_${prefix.name}_0'));
      final labelRecipientTagItemWidgetFinder = find.byKey(Key('label_recipient_tag_item_${prefix.name}_0'));
      final deleteIconRecipientTagItemWidgetFinder = find.byKey(Key('delete_icon_recipient_tag_item_${prefix.name}_0'));

      final Size recipientTagItemWidgetSize = tester.getSize(recipientTagItemWidgetFinder);
      final Size labelRecipientTagItemWidgetSize = tester.getSize(labelRecipientTagItemWidgetFinder);
      final Size deleteIconRecipientTagItemWidgetSize = tester.getSize(deleteIconRecipientTagItemWidgetFinder);

      log('recipient_composer_widget_test::main: TagSize = $recipientTagItemWidgetSize | LabelTagSize = $labelRecipientTagItemWidgetSize | DeleteIconTagSize = $deleteIconRecipientTagItemWidgetSize');

      expect(recipientTagItemWidgetFinder, findsOneWidget);
      expect(labelRecipientTagItemWidgetFinder, findsOneWidget);
      expect(deleteIconRecipientTagItemWidgetFinder, findsOneWidget);

      expect(
          labelRecipientTagItemWidgetSize.width + deleteIconRecipientTagItemWidgetSize.width,
          lessThan(recipientTagItemWidgetSize.width)
      );
    });

    testWidgets('WHEN EmailAddress has address is too long AND display name is too long\n'
        'RecipientTagItemWidget should have all the components (AvatarIcon, Label, DeleteIcon)', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress('test12345678912345678909123456789', 'test1234567891234567895678909123456789@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 392.7,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final recipientTagItemWidgetFinder = find.byKey(Key('recipient_tag_item_${prefix.name}_0'));
      final labelRecipientTagItemWidgetFinder = find.byKey(Key('label_recipient_tag_item_${prefix.name}_0'));
      final deleteIconRecipientTagItemWidgetFinder = find.byKey(Key('delete_icon_recipient_tag_item_${prefix.name}_0'));
      final avatarIconRecipientTagItemWidgetFinder = find.byKey(Key('avatar_icon_recipient_tag_item_${prefix.name}_0'));

      final Size recipientTagItemWidgetSize = tester.getSize(recipientTagItemWidgetFinder);
      final Size labelRecipientTagItemWidgetSize = tester.getSize(labelRecipientTagItemWidgetFinder);
      final Size deleteIconRecipientTagItemWidgetSize = tester.getSize(deleteIconRecipientTagItemWidgetFinder);
      final Size avatarIconRecipientTagItemWidgetSize = tester.getSize(avatarIconRecipientTagItemWidgetFinder);

      log('recipient_composer_widget_test::main: TagSize = $recipientTagItemWidgetSize | LabelTagSize = $labelRecipientTagItemWidgetSize | DeleteIconTagSize = $deleteIconRecipientTagItemWidgetSize | AvatarIconTagSize = $avatarIconRecipientTagItemWidgetSize');

      expect(labelRecipientTagItemWidgetFinder, findsOneWidget);
      expect(deleteIconRecipientTagItemWidgetFinder, findsOneWidget);
      expect(avatarIconRecipientTagItemWidgetFinder, findsOneWidget);

      expect(
        labelRecipientTagItemWidgetSize.width + deleteIconRecipientTagItemWidgetSize.width + avatarIconRecipientTagItemWidgetSize.width,
        lessThan(recipientTagItemWidgetSize.width)
      );
    });

    testWidgets('WHEN To has multiple recipients AND expandMode is COLLAPSE\n'
        'RecipientTagItemWidget should have all the components (AvatarIcon, Label, DeleteIcon, CounterTag)', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress('test1', 'test1@example.com'),
        EmailAddress('test2', 'test2@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          expandMode: ExpandMode.COLLAPSE,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final prefixRecipientComposerWidgetFinder = find.byKey(Key('prefix_${prefix.name}_recipient_composer_widget'));
      final recipientTagItemWidgetFinder = find.byKey(Key('recipient_tag_item_${prefix.name}_0'));

      final Size prefixRecipientComposerWidgetSize = tester.getSize(prefixRecipientComposerWidgetFinder);
      final Size recipientTagItemWidgetSize = tester.getSize(recipientTagItemWidgetFinder);

      log('recipient_composer_widget_test::main: PrefixLabelSize = $prefixRecipientComposerWidgetSize | TagSize = $recipientTagItemWidgetSize');

      expect(prefixRecipientComposerWidgetFinder, findsOneWidget);
      expect(recipientTagItemWidgetFinder, findsOneWidget);
      expect(
        prefixRecipientComposerWidgetSize.width + recipientTagItemWidgetSize.width,
        lessThan(360)
      );

      final labelRecipientTagItemWidgetFinder = find.byKey(Key('label_recipient_tag_item_${prefix.name}_0'));
      final deleteIconRecipientTagItemWidgetFinder = find.byKey(Key('delete_icon_recipient_tag_item_${prefix.name}_0'));
      final avatarIconRecipientTagItemWidgetFinder = find.byKey(Key('avatar_icon_recipient_tag_item_${prefix.name}_0'));
      final counterRecipientTagItemWidgetFinder = find.byKey(Key('counter_recipient_tag_item_${prefix.name}_0'));

      final Size labelRecipientTagItemWidgetSize = tester.getSize(labelRecipientTagItemWidgetFinder);
      final Size deleteIconRecipientTagItemWidgetSize = tester.getSize(deleteIconRecipientTagItemWidgetFinder);
      final Size avatarIconRecipientTagItemWidgetSize = tester.getSize(avatarIconRecipientTagItemWidgetFinder);
      final Size counterRecipientTagItemWidgetSize = tester.getSize(counterRecipientTagItemWidgetFinder);

      log('recipient_composer_widget_test::main: LabelTagSize = $labelRecipientTagItemWidgetSize | DeleteIconTagSize = $deleteIconRecipientTagItemWidgetSize | AvatarIconTagSize = $avatarIconRecipientTagItemWidgetSize | CounterTagSize = $counterRecipientTagItemWidgetSize');

      expect(labelRecipientTagItemWidgetFinder, findsOneWidget);
      expect(deleteIconRecipientTagItemWidgetFinder, findsOneWidget);
      expect(avatarIconRecipientTagItemWidgetFinder, findsOneWidget);
      expect(counterRecipientTagItemWidgetFinder, findsOneWidget);

      final totalSizeOfAllComponents = labelRecipientTagItemWidgetSize.width +
        deleteIconRecipientTagItemWidgetSize.width +
        avatarIconRecipientTagItemWidgetSize.width;
        counterRecipientTagItemWidgetSize.width;

      expect(
        totalSizeOfAllComponents,
        lessThan(recipientTagItemWidgetSize.width)
      );
    });

    testWidgets('WHEN To has multiple recipients AND expandMode is EXPAND\n'
        'RecipientTagItemWidget should have all the components (AvatarIcon, Label, DeleteIcon)', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress('test1', 'test1@example.com'),
        EmailAddress('test2', 'test2@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          expandMode: ExpandMode.EXPAND,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final prefixRecipientComposerWidgetFinder = find.byKey(Key('prefix_${prefix.name}_recipient_composer_widget'));
      final recipientTagItemWidgetFinder = find.byType(RecipientTagItemWidget);

      expect(prefixRecipientComposerWidgetFinder, findsOneWidget);
      expect(recipientTagItemWidgetFinder, findsNWidgets(2));
    });

    testWidgets('WHEN EmailAddress has address is too long AND display name is NULL\n'
        'RecipientTagItemWidget SHOULD have text that overflows', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress(null, 'test12345678901234567890@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final labelRecipientTagItemWidgetFinder = find.byKey(Key('label_recipient_tag_item_${prefix.name}_0'));

      final labelRecipientTagItemWidget = tester.widget<Text>(labelRecipientTagItemWidgetFinder);
      final labelTagWidth = tester.getSize(labelRecipientTagItemWidgetFinder).width;

      expect(labelRecipientTagItemWidget.overflow, equals(TextOverflow.ellipsis));

      final TextPainter textPainter = TextPainter(
        maxLines: labelRecipientTagItemWidget.maxLines,
        textDirection: labelRecipientTagItemWidget.textDirection ?? TextDirection.ltr,
        text: TextSpan(
          text: labelRecipientTagItemWidget.data,
          style: labelRecipientTagItemWidget.style,
          locale: labelRecipientTagItemWidget.locale
        ),
      );
      textPainter.layout(maxWidth: labelTagWidth);
      bool isExceededTextOverflow = textPainter.didExceedMaxLines;
      log('recipient_composer_widget_test::main: LABEL_TAB_WIDTH = $labelTagWidth | TextPainterWidth = ${textPainter.width} | isExceededTextOverflow = $isExceededTextOverflow');

      expect(isExceededTextOverflow, equals(true));
    });

    testWidgets('WHEN EmailAddress has address short AND display name is NULL\n'
        'RecipientTagItemWidget SHOULD have text display full', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress(null, 'test123@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final labelRecipientTagItemWidgetFinder = find.byKey(Key('label_recipient_tag_item_${prefix.name}_0'));

      final labelRecipientTagItemWidget = tester.widget<Text>(labelRecipientTagItemWidgetFinder);
      final labelTagWidth = tester.getSize(labelRecipientTagItemWidgetFinder).width;

      expect(labelRecipientTagItemWidget.overflow, equals(TextOverflow.ellipsis));

      final TextPainter textPainter = TextPainter(
        maxLines: labelRecipientTagItemWidget.maxLines,
        textDirection: labelRecipientTagItemWidget.textDirection ?? TextDirection.ltr,
        text: TextSpan(
          text: labelRecipientTagItemWidget.data,
          style: labelRecipientTagItemWidget.style,
          locale: labelRecipientTagItemWidget.locale
        ),
      );
      textPainter.layout(maxWidth: labelTagWidth);
      bool isExceededTextOverflow = textPainter.didExceedMaxLines;
      log('recipient_composer_widget_test::main: LABEL_TAB_WIDTH = $labelTagWidth | TextPainterWidth = ${textPainter.width} | isExceededTextOverflow = $isExceededTextOverflow');

      expect(isExceededTextOverflow, equals(false));
    });

    testWidgets('ToRecipientComponentWidget should display prefix To label correctly when the locale is fr-FR', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress('test1', 'test1@example.com'),
      ];

      Get.updateLocale(const Locale(LanguageCodeConstants.french, 'FR'));

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final prefixRecipientComposerWidgetFinder = find.byKey(Key('prefix_${prefix.name}_recipient_composer_widget'));
      final prefixRecipientComposerWidget = tester.widget<Text>(prefixRecipientComposerWidgetFinder);

      log('recipient_composer_widget_test::main: PREFIX_LABEL = ${prefixRecipientComposerWidget.data}');

      expect(prefixRecipientComposerWidget.data, equals('À:'));
    });

    testWidgets('ToRecipientComponentWidget should display prefix To label correctly when the locale is vi-VN', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress('test1', 'test1@example.com'),
      ];

      Get.updateLocale(const Locale(LanguageCodeConstants.vietnamese, 'VN'));

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final prefixRecipientComposerWidgetFinder = find.byKey(Key('prefix_${prefix.name}_recipient_composer_widget'));
      final prefixRecipientComposerWidget = tester.widget<Text>(prefixRecipientComposerWidgetFinder);

      log('recipient_composer_widget_test::main: PREFIX_LABEL = ${prefixRecipientComposerWidget.data}');

      expect(prefixRecipientComposerWidget.data, equals('Đến:'));
    });

    testWidgets('ToRecipientComponentWidget should have all the components (PrefixLabel, RecipientTagItemWidget, ExpandButton) on mobile platform', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final listEmailAddress = <EmailAddress>[
        EmailAddress('test1', 'test1@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          keyTagEditor: keyEmailTagEditor,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final prefixRecipientComposerWidgetFinder = find.byKey(Key('prefix_${prefix.name}_recipient_composer_widget'));
      final recipientTagItemWidgetFinder = find.byKey(Key('recipient_tag_item_${prefix.name}_0'));

      final Size prefixRecipientComposerWidgetSize = tester.getSize(prefixRecipientComposerWidgetFinder);
      final Size recipientTagItemWidgetSize = tester.getSize(recipientTagItemWidgetFinder);

      expect(prefixRecipientComposerWidgetFinder, findsOneWidget);
      expect(recipientTagItemWidgetFinder, findsOneWidget);

      log('recipient_composer_widget_test::main: PrefixLabelSize = $prefixRecipientComposerWidgetSize | TagSize = $recipientTagItemWidgetSize');

      final recipientExpandButtonFinder = find.byKey(Key('prefix_${prefix.name}_recipient_expand_button'));

      final Size recipientExpandButtonSize = tester.getSize(recipientExpandButtonFinder);

      log('recipient_composer_widget_test::main: ExpandButtonSize = $recipientExpandButtonSize');

      expect(recipientExpandButtonFinder, findsOneWidget);

      final totalComponentsSize = prefixRecipientComposerWidgetSize.width
        + recipientTagItemWidgetSize.width
        + recipientExpandButtonSize.width;

      log('recipient_composer_widget_test::main: totalComponentsSize = $totalComponentsSize');

      expect(totalComponentsSize, lessThan(360));

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('ToRecipientComponentWidget should have all the components (PrefixLabel, RecipientTagItemWidget, FromButton, CCButton, BccButton) on web platform', (tester) async {
      final listEmailAddress = <EmailAddress>[
        EmailAddress('test1', 'test1@example.com'),
      ];

      final widget = makeTestableWidget(
        child: RecipientComposerWidget(
          prefix: prefix,
          listEmailAddress: listEmailAddress,
          imagePaths: imagePaths,
          maxWidth: 360,
          keyTagEditor: keyEmailTagEditor,
          isTestingForWeb: true,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final prefixRecipientComposerWidgetFinder = find.byKey(Key('prefix_${prefix.name}_recipient_composer_widget'));
      final recipientTagItemWidgetFinder = find.byKey(Key('recipient_tag_item_${prefix.name}_0'));

      final Size prefixRecipientComposerWidgetSize = tester.getSize(prefixRecipientComposerWidgetFinder);
      final Size recipientTagItemWidgetSize = tester.getSize(recipientTagItemWidgetFinder);

      expect(prefixRecipientComposerWidgetFinder, findsOneWidget);
      expect(recipientTagItemWidgetFinder, findsOneWidget);

      log('recipient_composer_widget_test::main: PrefixLabelSize = $prefixRecipientComposerWidgetSize | TagSize = $recipientTagItemWidgetSize');

      final recipientFromButtonFinder = find.byKey(Key('prefix_${prefix.name}_recipient_from_button'));
      final recipientCcButtonFinder = find.byKey(Key('prefix_${prefix.name}_recipient_cc_button'));
      final recipientBccButtonFinder = find.byKey(Key('prefix_${prefix.name}_recipient_bcc_button'));

      final Size recipientFromButtonSize = tester.getSize(recipientFromButtonFinder);
      final Size recipientCcButtonSize = tester.getSize(recipientCcButtonFinder);
      final Size recipientBccButtonSize = tester.getSize(recipientBccButtonFinder);

      log('recipient_composer_widget_test::main: FromButtonSize = $recipientFromButtonSize | CcButtonSize = $recipientCcButtonSize | BccButtonSize = $recipientBccButtonSize');

      expect(recipientFromButtonFinder, findsOneWidget);
      expect(recipientCcButtonFinder, findsOneWidget);
      expect(recipientBccButtonFinder, findsOneWidget);
    });
  });
}
