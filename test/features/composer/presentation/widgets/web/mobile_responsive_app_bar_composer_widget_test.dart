import 'package:core/presentation/extensions/composer_attachment_extension_registry.dart';
import 'package:core/presentation/extensions/composer_attachment_plugin.dart';
import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu_overlay_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_attachment_extension_registry_provider.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/mobile_responsive_app_bar_composer_widget.dart';

import '../../../../../fixtures/widget_fixtures.dart';

const _insertImage = 'Insert image';

class _FakePlugin implements ComposerAttachmentPlugin {
  final int index;

  const _FakePlugin(this.index);

  @override
  Widget buildToolbarButton(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    ComposerToolbarButtonStyle style = const ComposerToolbarButtonStyle(),
  }) => SizedBox(key: ValueKey('fake-plugin-button-$index'), width: 44, height: 40);

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

  setUp(() {
    container = ProviderContainer(
      overrides: [
        composerAttachmentExtensionRegistryProvider.overrideWith(
          (ref) => const ComposerAttachmentExtensionRegistry([
            _FakePlugin(1),
            _FakePlugin(2),
          ]),
        ),
      ],
    );
    menuController = CustomPopupMenuController();
  });

  tearDown(() {
    container.dispose();
    menuController.dispose();
  });

  Future<void> pumpBar(WidgetTester tester, double width) {
    return WidgetFixtures.pumpResponsiveWidget(
      tester,
      WidgetFixtures.makeTestableWidget(
        providerContainer: container,
        child: MobileResponsiveAppBarComposerWidget(
          imagePaths: ImagePaths(),
          isCodeViewEnabled: false,
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
        tester.getRect(find.byType(PopupMenuOverlayWidget)).right,
        lessThanOrEqualTo(320),
      );
      expect(find.byTooltip(_insertImage), findsNothing);
      expect(find.byKey(const ValueKey('fake-plugin-button-1')), findsOneWidget);

      await tester.tap(find.byType(PopupMenuOverlayWidget));
      await tester.pumpAndSettle();

      expect(find.text(_insertImage), findsOneWidget);
    },
  );

  testWidgets(
    'Should keep every action in the bar on a wide screen',
    (tester) async {
      addTearDown(() => WidgetFixtures.resetResponsive(tester));

      await pumpBar(tester, 1024);

      expect(tester.takeException(), isNull);
      expect(find.byTooltip(_insertImage), findsOneWidget);

      await tester.tap(find.byType(PopupMenuOverlayWidget));
      await tester.pumpAndSettle();

      expect(find.text(_insertImage), findsNothing);
    },
  );
}
