import 'package:core/presentation/extensions/composer_attachment_extension_registry.dart';
import 'package:core/presentation/extensions/composer_attachment_plugin.dart';
import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu_overlay_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_attachment_extension_registry_provider.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/mobile_responsive_app_bar_composer_widget.dart';

import '../../../../../fixtures/widget_fixtures.dart';

const _insertImage = 'Insert image';
const _formatting = 'Formatting options';
const _fakePlugin = 'Fake plugin 1';

class _FakePlugin implements ComposerAttachmentPlugin {
  final int index;
  final ValueNotifier<bool> available;

  _FakePlugin(this.index, this.available);

  @override
  Listenable get availability => available;

  @override
  bool get isAvailable => available.value;

  @override
  Widget buildToolbarButton(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    ComposerToolbarButtonStyle style = const ComposerToolbarButtonStyle(),
  }) => SizedBox(
    key: ValueKey('fake-plugin-button-$index'),
    width: 44,
    height: 40,
  );

  @override
  Widget buildContextMenuTile(
    BuildContext context, {
    required ImagePaths imagePaths,
    String? composerId,
    VoidCallback? onDismiss,
  }) => Text('Fake plugin $index');
}

void main() {
  late ProviderContainer container;
  late CustomPopupMenuController menuController;
  late ValueNotifier<bool> secondPluginAvailable;

  setUp(() {
    secondPluginAvailable = ValueNotifier(true);
    container = ProviderContainer(
      overrides: [
        composerAttachmentExtensionRegistryProvider.overrideWith(
          (ref) => ComposerAttachmentExtensionRegistry([
            _FakePlugin(1, ValueNotifier(true)),
            _FakePlugin(2, secondPluginAvailable),
          ]),
        ),
      ],
    );
    menuController = CustomPopupMenuController();
  });

  tearDown(() {
    container.dispose();
    menuController.dispose();
    secondPluginAvailable.dispose();
  });

  Future<void> pumpBar(
    WidgetTester tester,
    double width, {
    bool isCodeViewEnabled = false,
  }) {
    return WidgetFixtures.pumpResponsiveWidget(
      tester,
      WidgetFixtures.makeTestableWidget(
        providerContainer: container,
        child: MobileResponsiveAppBarComposerWidget(
          imagePaths: ImagePaths(),
          isCodeViewEnabled: isCodeViewEnabled,
          isFormattingOptionsEnabled: false,
          isSendButtonEnabled: true,
          hasRequestReadReceipt: false,
          isMarkAsImportant: false,
          isEmailChanged: false,
          menuMoreOptionController: menuController,
          openRichToolbarAction: () {},
          onCloseViewAction: () {},
          attachFileAction: () {},
          insertImageAction: () {},
          sendMessageAction: () {},
          toggleCodeViewAction: () {},
          toggleRequestReadReceiptAction: () {},
          printDraftAction: () {},
          saveToDraftsAction: () {},
          saveToTemplateAction: () {},
          deleteComposerAction: () {},
          toggleMarkAsImportantAction: () {},
          composerId: 'composer-1',
        ),
      ),
      logicalSize: Size(width, 640),
    );
  }

  testWidgets(
    'Should move the last actions into the More menu on a 320 px screen',
    (tester) async {
      addTearDown(() => WidgetFixtures.resetResponsive(tester));

      await pumpBar(tester, 320);

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const Key(UiKeys.closeComposerButton)),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey(UiKeys.sendEmailButton)),
        findsOneWidget,
      );
      expect(find.byType(PopupMenuOverlayWidget), findsOneWidget);
      expect(
        find.byKey(const Key(UiKeys.composerMoreButton)),
        findsOneWidget,
      );
      for (final key in [
        const Key(UiKeys.closeComposerButton),
        const ValueKey(UiKeys.sendEmailButton),
        const Key(UiKeys.composerMoreButton),
      ]) {
        final rect = tester.getRect(find.byKey(key));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(320));
      }
      expect(find.byTooltip(_insertImage), findsNothing);
      expect(
        find.byKey(const ValueKey('fake-plugin-button-1')),
        findsOneWidget,
      );

      await tester.tap(find.byType(PopupMenuOverlayWidget));
      await tester.pumpAndSettle();

      expect(find.text(_insertImage), findsOneWidget);
    },
  );

  testWidgets('Should keep every action in the bar on a wide screen', (
    tester,
  ) async {
    addTearDown(() => WidgetFixtures.resetResponsive(tester));

    await pumpBar(tester, 1024);

    expect(tester.takeException(), isNull);
    expect(find.byTooltip(_insertImage), findsOneWidget);

    await tester.tap(find.byType(PopupMenuOverlayWidget));
    await tester.pumpAndSettle();

      expect(find.byKey(const Key(UiKeys.saveDraftPopupItem)), findsOneWidget);
      expect(find.text(_insertImage), findsNothing);
      expect(find.byType(Divider), findsNothing);
  });

  testWidgets('Should put a collapsed plugin tile in the More menu', (
    tester,
  ) async {
    addTearDown(() => WidgetFixtures.resetResponsive(tester));

    await pumpBar(tester, 200);

    expect(tester.takeException(), isNull);
    expect(find.byTooltip(_formatting), findsOneWidget);
    expect(find.byKey(const ValueKey('fake-plugin-button-1')), findsNothing);

    await tester.tap(find.byType(PopupMenuOverlayWidget));
    await tester.pumpAndSettle();

    expect(find.text(_fakePlugin), findsOneWidget);
    expect(find.byKey(const Key(UiKeys.saveDraftPopupItem)), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets(
    'Should omit insert image from the bar and the menu in code view',
    (tester) async {
      addTearDown(() => WidgetFixtures.resetResponsive(tester));

      await pumpBar(tester, 1024, isCodeViewEnabled: true);

      expect(tester.takeException(), isNull);
      expect(find.byTooltip(_insertImage), findsNothing);

      await tester.tap(find.byType(PopupMenuOverlayWidget));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key(UiKeys.saveDraftPopupItem)), findsOneWidget);
      expect(find.text(_insertImage), findsNothing);
    },
  );

  testWidgets('Should give no bar slot to an unavailable plugin', (
    tester,
  ) async {
    addTearDown(() => WidgetFixtures.resetResponsive(tester));
    secondPluginAvailable.value = false;

    await pumpBar(tester, 1024);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('fake-plugin-button-2')), findsNothing);
    expect(find.byTooltip(_insertImage), findsOneWidget);

    secondPluginAvailable.value = true;
    await tester.pump();

    expect(find.byKey(const ValueKey('fake-plugin-button-2')), findsOneWidget);
  });

  testWidgets('Should leave an unavailable plugin out of the More menu', (
    tester,
  ) async {
    addTearDown(() => WidgetFixtures.resetResponsive(tester));
    secondPluginAvailable.value = false;

    await pumpBar(tester, 200);
    await tester.tap(find.byType(PopupMenuOverlayWidget));
    await tester.pumpAndSettle();

    expect(find.text(_fakePlugin), findsOneWidget);
    expect(find.text('Fake plugin 2'), findsNothing);
  });
}
