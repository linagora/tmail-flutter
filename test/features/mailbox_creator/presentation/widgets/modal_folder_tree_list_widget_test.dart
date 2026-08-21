import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_icon_widget.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/widgets/modal_folder_tree_list_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  testWidgets('uses the mailbox neutral color for Personal folders',
      (tester) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    final imagePaths = ImagePaths();

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      home: Scaffold(
        body: ModalFolderTreeListWidget(
          defaultTree: MailboxTree(MailboxNode.root()),
          personalTree: MailboxTree(MailboxNode.root()),
          imagePaths: imagePaths,
          listScrollController: scrollController,
          onSelectFolderAction: (_) {},
          onToggleFolderAction: (_, __) {},
        ),
      ),
    ));
    await tester.pump();

    expect(
      tester.widget<SvgPicture>(find.descendant(
        of: find.byType(MailboxIconWidget),
        matching: find.byType(SvgPicture),
      )).colorFilter,
      const ColorFilter.mode(AppColor.gray424244, BlendMode.srcIn),
    );
  });
}
