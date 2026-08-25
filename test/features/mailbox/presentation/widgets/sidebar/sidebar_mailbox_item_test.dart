import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_label_item.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_mailbox_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

final _imagePaths = ImagePaths();
final _folderIconsByRole = <Role, String>{
  PresentationMailbox.roleInbox: _imagePaths.icMailboxInbox,
  PresentationMailbox.roleFavorite: _imagePaths.icMailboxFavorite,
  PresentationMailbox.roleActionRequired: _imagePaths.icMailboxActionRequired,
  PresentationMailbox.roleDrafts: _imagePaths.icMailboxDrafts,
  PresentationMailbox.roleOutbox: _imagePaths.icMailboxOutbox,
  PresentationMailbox.roleArchive: _imagePaths.icMailboxArchived,
  PresentationMailbox.roleSent: _imagePaths.icMailboxSent,
  PresentationMailbox.roleTrash: _imagePaths.icMailboxTrash,
  PresentationMailbox.roleSpam: _imagePaths.icMailboxSpam,
  PresentationMailbox.roleJunk: _imagePaths.icMailboxSpam,
  PresentationMailbox.roleTemplates: _imagePaths.icMailboxTemplate,
};

void main() {
  setUpAll(() async {
    await _loadTwakeInterFonts();
  });

  group('SidebarMailboxItem', () {
    _testMapsMailboxDataToRow();
    _testInsetsNestedMailboxBackgroundAndReservesExpandControl();
    _testMapsMailboxRolesToTheNewFolderIcons();
    _testBundlesEveryMappedFolderIcon();
    _testTintsFolderIconsForTheSidebarTheme();
    _testHidesBadgesForTrashAndSpam();
    _testMapsExpandToggleToMailboxAction();
    _testUsesReleaseDropTargetForDesktopWeb();
    _testKeepsActionRequiredMailboxOutOfDropTargets();
    _testForwardsMailboxContextMenuAnchor();
    _testForwardsMailboxLongPressOnMobile();
    _testKeepsDotsTriggerActiveUntilMenuCloses();
    _testUsesConfirmPopoverForClean();
    _testCleanPopoverUsesPrimaryConfirmInDarkRtl();
  });

  group('SidebarLabelItem', () {
    _testOpensLabelAndForwardsContextMenuAnchor();
    _testHidesMenuForProtectedReadOnlyLabel();
    _testKeepsMaterialTapFeedbackForMobileLabels();
    _testForwardsLabelLongPressOnMobile();
  });
}

void _testMapsMailboxRolesToTheNewFolderIcons() {
  test('maps mailbox roles and custom folders to the new folder icons', () {
    for (final entry in _folderIconsByRole.entries) {
      final mailbox = _mailboxNode(
        id: entry.key.value,
        role: entry.key,
      ).item;

      expect(mailbox.getMailboxIcon(_imagePaths), entry.value);
    }

    expect(
      _mailboxNode(id: 'custom-folder').item.getMailboxIcon(_imagePaths),
      _imagePaths.icFolderMailbox,
    );
  });
}

void _testBundlesEveryMappedFolderIcon() {
  testWidgets('bundles every mapped folder icon as an SVG asset', (tester) async {
    final iconPaths = {
      ..._folderIconsByRole.values,
      _imagePaths.icFolderMailbox,
    };

    for (final iconPath in iconPaths) {
      final svg = await rootBundle.loadString(iconPath);
      expect(svg, contains('<svg'));
    }
  });
}

void _testTintsFolderIconsForTheSidebarTheme() {
  testWidgets('tints folder icons for active and inactive states in each theme',
      (tester) async {
    for (final brightness in Brightness.values) {
      final sidebarStyle = brightness == Brightness.dark
          ? LinagoraSidebarStyle.dark()
          : LinagoraSidebarStyle.light();

      for (final isActive in [false, true]) {
        final mailboxNode = _mailboxNode(
          id: 'inbox-${brightness.index}-${isActive ? 1 : 0}',
          role: PresentationMailbox.roleInbox,
        );

        await _pump(
          tester,
          LinagoraSidebarTheme(
            data: sidebarStyle,
            child: SidebarMailboxItem(
              mailboxNode: mailboxNode,
              imagePaths: _imagePaths,
              isWebDesktop: false,
              mailboxNodeSelected: isActive ? mailboxNode.item : null,
            ),
          ),
          brightness: brightness,
        );

        final icon = tester.widget<SvgPicture>(find.byType(SvgPicture));
        expect(icon.width, 16);
        expect(icon.height, 16);
        expect(
          icon.colorFilter,
          ColorFilter.mode(
            isActive ? sidebarStyle.activeForeground : sidebarStyle.foreground,
            BlendMode.srcIn,
          ),
        );
      }
    }
  });
}

void _testHidesBadgesForTrashAndSpam() {
  testWidgets('does not map Trash or Spam counts to sidebar badges', (tester) async {
    for (final mailbox in [
      _mailboxNode(
        id: 'trash',
        name: 'Trash',
        role: PresentationMailbox.roleTrash,
        totalEmails: 9,
      ),
      _mailboxNode(
        id: 'spam',
        name: 'Spam',
        role: PresentationMailbox.roleSpam,
        totalEmails: 10,
      ),
    ]) {
      await _pump(
        tester,
        SidebarMailboxItem(
          mailboxNode: mailbox,
          imagePaths: _imagePaths,
          isWebDesktop: false,
        ),
      );

      final row = tester.widget<LinagoraSidebarItem>(
        find.byType(LinagoraSidebarItem),
      );
      expect(row.badgeLabel, isNull);
    }
  });
}

void _testMapsMailboxDataToRow() {
  testWidgets('maps mailbox data to the generic sidebar row', (tester) async {
    final mailboxNode = _mailboxNode(id: 'inbox', unreadEmails: 12);

    await _pump(
      tester,
      SidebarMailboxItem(
        mailboxNode: mailboxNode,
        imagePaths: _imagePaths,
        isWebDesktop: false,
        mailboxNodeSelected: mailboxNode.item,
      ),
    );

    final row = tester.widget<LinagoraSidebarItem>(
      find.byType(LinagoraSidebarItem),
    );

    expect(row.badgeLabel, '12');
    expect(row.active, isTrue);
  });
}

void _testInsetsNestedMailboxBackgroundAndReservesExpandControl() {
  testWidgets(
      'insets a nested mailbox background and preserves its expand control on hover',
      (tester) async {
    PlatformInfo.isTestingForWeb = true;
    addTearDown(() {
      PlatformInfo.isTestingForWeb = false;
    });
    final previousTargetPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    try {
      const folderName = 'A folder name that must overflow before the expand control';
      final mailboxNode = _mailboxNode(
        id: 'nested-folder',
        name: folderName,
        children: [_mailboxNode(id: 'nested-child')],
      );

      await _pump(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 236,
            child: LinagoraSidebarIndent(
              indent: 24,
              child: SidebarMailboxItem(
                mailboxNode: mailboxNode,
                imagePaths: _imagePaths,
                isWebDesktop: true,
                mailboxNodeSelected: mailboxNode.item,
                onExpandFolderActionClick: (_) {},
                onMenuActionClick: (_, __) async {},
              ),
            ),
          ),
        ),
      );

      final itemFinder = find.byType(LinagoraSidebarItem);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(itemFinder));
      await tester.pump();

      final style = LinagoraSidebarStyle.light();
      final backgroundFinder = find.descendant(
        of: itemFinder,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Material && widget.color == style.selectedBackground,
        ),
      );
      final backgroundRect = tester.getRect(backgroundFinder);
      final labelFinder = find.text(folderName);
      final labelRect = tester.getRect(labelFinder);
      final expandControlRect = tester.getRect(
        find.byType(LinagoraSidebarControl),
      );

      expect(backgroundRect.left, 24);
      expect(backgroundRect.right, 236);
      expect(find.byType(LinagoraSidebarMenuAction), findsOneWidget);
      expect(
        tester.renderObject<RenderParagraph>(labelFinder).didExceedMaxLines,
        isTrue,
      );
      expect(labelRect.right, lessThanOrEqualTo(expandControlRect.left));
    } finally {
      debugDefaultTargetPlatformOverride = previousTargetPlatform;
    }
  });
}

void _testMapsExpandToggleToMailboxAction() {
  testWidgets('maps the generic expand toggle to a mailbox action', (tester) async {
    MailboxNode? expandedMailbox;
    final mailboxNode = _mailboxNode(
      id: 'parent',
      children: [_mailboxNode(id: 'child')],
    );

    await _pump(
      tester,
      SidebarMailboxItem(
        mailboxNode: mailboxNode,
        imagePaths: _imagePaths,
        isWebDesktop: false,
        onExpandFolderActionClick: (mailboxNode) => expandedMailbox = mailboxNode,
      ),
    );

    await tester.tap(find.byType(LinagoraSidebarControl));
    await tester.pump();

    expect(expandedMailbox, same(mailboxNode));
    expect(
      tester.widget<LinagoraSidebarItem>(
        find.byType(LinagoraSidebarItem),
      ).scrollIntoViewOnExpand,
      isTrue,
    );
  });
}

void _testUsesReleaseDropTargetForDesktopWeb() {
  testWidgets('wraps a drop-eligible mailbox in the release drop target',
      (tester) async {
    List<PresentationEmail>? droppedEmails;
    final mailboxNode = _mailboxNode(id: 'destination');

    await _pump(
      tester,
      SidebarMailboxItem(
        mailboxNode: mailboxNode,
        imagePaths: _imagePaths,
        isWebDesktop: true,
        onDragItemAccepted: (emails, _) => droppedEmails = emails,
      ),
    );

    final dropTarget = tester
        .widget<LinagoraSidebarItemDropTarget<List<PresentationEmail>>>(
      find.byType(LinagoraSidebarItemDropTarget<List<PresentationEmail>>),
    );
    const emails = <PresentationEmail>[];

    dropTarget.onDrop(const LinagoraSidebarItemDropDetails(
      data: emails,
      offset: Offset.zero,
    ));

    expect(droppedEmails, same(emails));
  });
}

void _testKeepsActionRequiredMailboxOutOfDropTargets() {
  testWidgets(
      'keeps Action Required inactive while dragging and out of drop targets',
      (tester) async {
    final mailboxNode = _mailboxNode(
      id: 'action-required',
      role: PresentationMailbox.roleActionRequired,
    );

    await _pump(
      tester,
      SidebarMailboxItem(
        mailboxNode: mailboxNode,
        imagePaths: _imagePaths,
        isWebDesktop: true,
        isDraggingMailbox: true,
        mailboxNodeSelected: mailboxNode.item,
        onDragItemAccepted: (_, __) {},
      ),
    );

    expect(
      find.byType(LinagoraSidebarItemDropTarget<List<PresentationEmail>>),
      findsNothing,
    );
    expect(
      tester.widget<LinagoraSidebarItem>(
        find.byType(LinagoraSidebarItem),
      ).active,
      isFalse,
    );
  });
}

void _testForwardsMailboxContextMenuAnchor() {
  testWidgets('forwards the overflow menu anchor to the mailbox callback',
      (tester) async {
    PlatformInfo.isTestingForWeb = true;
    addTearDown(() => PlatformInfo.isTestingForWeb = false);

    final mailboxNode = _mailboxNode(id: 'folder');
    MailboxNode? menuMailbox;
    RelativeRect? menuPosition;

    await _pump(
      tester,
      SidebarMailboxItem(
        mailboxNode: mailboxNode,
        imagePaths: _imagePaths,
        isWebDesktop: true,
        onMenuActionClick: (position, mailbox) async {
          menuMailbox = mailbox;
          menuPosition = position;
        },
      ),
    );

    final row = tester.widget<LinagoraSidebarItem>(
      find.byType(LinagoraSidebarItem),
    );
    final actions = row.hoverTrailing! as LinagoraSidebarItemActions;
    final menuAction = actions.actions.single.child
        as LinagoraSidebarMenuAction;

    await menuAction.onPressed(const LinagoraSidebarActionDetails(
      globalBounds: Rect.fromLTWH(10, 20, 30, 40),
      anchor: RelativeRect.fromLTRB(10, 20, 60, 40),
      overlayBounds: Rect.fromLTWH(10, 20, 30, 40),
      overlaySize: Size(100, 200),
    ));

    expect(menuMailbox, same(mailboxNode));
    expect(menuPosition, const RelativeRect.fromLTRB(10, 60, 90, 140));
  });
}

void _testForwardsMailboxLongPressOnMobile() {
  testWidgets('forwards a mobile long press to the mailbox callback',
      (tester) async {
    final mailboxNode = _mailboxNode(id: 'folder');
    MailboxNode? longPressedMailbox;

    await _longPressMobileSidebarItem(
      tester,
      SidebarMailboxItem(
        mailboxNode: mailboxNode,
        imagePaths: _imagePaths,
        isWebDesktop: false,
        onLongPressMailboxNodeAction: (mailbox) => longPressedMailbox = mailbox,
      ),
    );

    expect(longPressedMailbox, same(mailboxNode));
  });
}

void _testKeepsDotsTriggerActiveUntilMenuCloses() {
  testWidgets('keeps only the dots trigger active until its menu Future ends',
      (tester) async {
    final menuCompletion = Completer<void>();
    RelativeRect? menuPosition;

    await _pump(
      tester,
      _mailboxItemActions(
        mailboxNode: _mailboxNode(id: 'folder'),
        onMenuActionClick: (position, _) {
          menuPosition = position;
          return menuCompletion.future;
        },
      ),
    );

    await tester.tap(find.byType(LinagoraSidebarMenuAction));
    await tester.pump();

    var activeAction = tester.widget<LinagoraSidebarItemAction>(
      find.byType(LinagoraSidebarItemAction).last,
    );
    expect(activeAction.active, isTrue);
    expect(menuPosition, isNotNull);

    menuCompletion.complete();
    await tester.pump();

    activeAction = tester.widget<LinagoraSidebarItemAction>(
      find.byType(LinagoraSidebarItemAction).last,
    );
    expect(activeAction.active, isFalse);
  });
}

void _testUsesConfirmPopoverForClean() {
  testWidgets('uses the generic confirmation popover for Clean', (tester) async {
    var emptyMailboxCalls = 0;

    await _pump(
      tester,
      _mailboxItemActions(
        mailboxNode: _mailboxNode(id: 'folder', name: 'Project'),
        actions: const {_MailboxAction.clean},
        onEmptyMailboxActionCallback: (_) => emptyMailboxCalls++,
      ),
    );

    final cleanTextStyle = (tester
            .widget<RichText>(
              find.descendant(
                of: find.byType(LinagoraSidebarPopoverAction),
                matching: find.byType(RichText),
              ),
            )
            .text as TextSpan)
        .style!;
    final sidebarStyle = LinagoraSidebarStyle.light();
    expect(cleanTextStyle.fontSize, sidebarStyle.badgeTextStyle.fontSize);
    expect(cleanTextStyle.height, sidebarStyle.badgeTextStyle.height);
    expect(cleanTextStyle.fontWeight, sidebarStyle.badgeTextStyle.fontWeight);
    expect(
      cleanTextStyle.letterSpacing,
      sidebarStyle.badgeTextStyle.letterSpacing,
    );
    expect(
      cleanTextStyle.color,
      sidebarStyle.trailingForeground,
    );

    await tester.tap(find.text('Clean').first);
    await tester.pump();

    final popover = tester.widget<LinagoraSidebarConfirmPopover>(
      find.byType(LinagoraSidebarConfirmPopover),
    );
    const popoverStyle = LinagoraSidebarConfirmPopoverStyle();
    expect(popover.width, popoverStyle.width);
    expect(
      popover.confirmButtonVariant,
      LinagoraSidebarConfirmButtonVariant.primary,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.close)).size,
      popoverStyle.closeIconSize,
    );
    expect(
      tester.widget<LinagoraSidebarItemAction>(
        find.byType(LinagoraSidebarItemAction).first,
      ).active,
      isTrue,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(emptyMailboxCalls, 0);

    await tester.tap(find.text('Clean').first);
    await tester.pump();
    await tester.tap(find.text('Clean').last);
    await tester.pump();

    expect(emptyMailboxCalls, 1);
  });
}

void _testCleanPopoverUsesPrimaryConfirmInDarkRtl() {
  testWidgets('keeps Clear folder primary in dark RTL mode', (tester) async {
    await _pump(
      tester,
      _mailboxItemActions(
        mailboxNode: _mailboxNode(id: 'trash', name: 'Trash'),
        actions: const {_MailboxAction.clean},
      ),
      brightness: Brightness.dark,
      textDirection: TextDirection.rtl,
    );

    await tester.tap(find.text('Clean').first);
    await tester.pump();

    final confirmButton = tester.widget<LinagoraButton>(
      find.ancestor(
        of: find.text('Clean').last,
        matching: find.byType(LinagoraButton),
      ),
    );
    expect(
      confirmButton.style?.backgroundColor?.resolve({}),
      LinagoraSidebarStyle.dark().activeForeground,
    );

    final shape = tester.widget<ClipPath>(
      find.byWidgetPredicate(
        (widget) =>
            widget is ClipPath &&
            widget.clipper is LinagoraSidebarPopoverShape,
      ),
    ).clipper as LinagoraSidebarPopoverShape;
    expect(shape.arrowSide, LinagoraSidebarPopoverArrowSide.end);
  });
}

void _testHidesMenuForProtectedReadOnlyLabel() {
  testWidgets('does not expose a menu for a protected read-only label',
      (tester) async {
    await _pump(
      tester,
      SidebarLabelItem(
        label: Label(
          id: Id('label'),
          displayName: 'Read only',
          readOnly: true,
        ),
        imagePaths: _imagePaths,
        shouldAskReadOnly: true,
        onOpenLabelCallback: (_) {},
        onOpenContextMenu: (_, __) async {},
      ),
    );

    final row = tester.widget<LinagoraSidebarItem>(
      find.byType(LinagoraSidebarItem),
    );

    expect(row.hoverTrailing, isNull);
  });
}

void _testOpensLabelAndForwardsContextMenuAnchor() {
  testWidgets('opens a writable label and forwards its context menu anchor',
      (tester) async {
    final previousTargetPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    final label = Label(
      id: Id('label'),
      displayName: 'Projects',
    );
    Label? openedLabel;
    Label? menuLabel;
    RelativeRect? menuPosition;

    await _pump(
      tester,
      SidebarLabelItem(
        label: label,
        imagePaths: _imagePaths,
        onOpenLabelCallback: (label) => openedLabel = label,
        onOpenContextMenu: (label, position) async {
          menuLabel = label;
          menuPosition = position;
        },
      ),
    );
    debugDefaultTargetPlatformOverride = previousTargetPlatform;

    await tester.tap(find.byType(LinagoraSidebarItem));
    await tester.pump();

    expect(openedLabel, same(label));

    final row = tester.widget<LinagoraSidebarItem>(
      find.byType(LinagoraSidebarItem),
    );
    final actions = row.hoverTrailing! as LinagoraSidebarItemActions;
    final menuAction = actions.actions.single.child
        as LinagoraSidebarMenuAction;

    await menuAction.onPressed(const LinagoraSidebarActionDetails(
      globalBounds: Rect.fromLTWH(10, 20, 30, 40),
      anchor: RelativeRect.fromLTRB(10, 20, 60, 40),
      overlayBounds: Rect.fromLTWH(10, 20, 30, 40),
      overlaySize: Size(100, 200),
    ));

    expect(menuLabel, same(label));
    expect(menuPosition, const RelativeRect.fromLTRB(10, 60, 90, 140));
  });
}

void _testKeepsMaterialTapFeedbackForMobileLabels() {
  testWidgets('keeps material tap feedback for mobile labels', (tester) async {
    final previousTargetPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await _pump(
      tester,
      SidebarLabelItem(
        label: Label(id: Id('label'), displayName: 'Projects'),
        imagePaths: _imagePaths,
        onOpenLabelCallback: (_) {},
        onOpenContextMenu: (_, __) async {},
      ),
    );
    debugDefaultTargetPlatformOverride = previousTargetPlatform;

    final row = tester.widget<LinagoraSidebarItem>(
      find.byType(LinagoraSidebarItem),
    );
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));

    expect(row.hoverTrailing, isNull);
    expect(inkWell.splashColor, isNull);
    expect(inkWell.highlightColor, isNull);
  });
}

void _testForwardsLabelLongPressOnMobile() {
  testWidgets('forwards a mobile long press for writable labels',
      (tester) async {
    final label = Label(id: Id('label'), displayName: 'Projects');
    Label? longPressedLabel;

    await _longPressMobileSidebarItem(
      tester,
      SidebarLabelItem(
        label: label,
        imagePaths: _imagePaths,
        onOpenLabelCallback: (_) {},
        onLongPressLabelItemAction: (label) => longPressedLabel = label,
      ),
    );

    expect(longPressedLabel, same(label));
  });
}

Future<void> _longPressMobileSidebarItem(
  WidgetTester tester,
  Widget child,
) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  addTearDown(() => debugDefaultTargetPlatformOverride = null);

  await _pump(tester, child);
  debugDefaultTargetPlatformOverride = null;

  await tester.longPress(find.byWidgetPredicate(
    (widget) => widget is GestureDetector && widget.onLongPress != null,
  ));
}

Future<void> _loadTwakeInterFonts() async {
  final fontLoader = FontLoader('packages/linagora_design_flutter/TwakeInter')
    ..addFont(rootBundle.load(
      'packages/linagora_design_flutter/assets/fonts/TwakeInter-Regular.ttf',
    ))
    ..addFont(rootBundle.load(
      'packages/linagora_design_flutter/assets/fonts/TwakeInter-Medium.ttf',
    ))
    ..addFont(rootBundle.load(
      'packages/linagora_design_flutter/assets/fonts/TwakeInter-SemiBold.ttf',
    ));
  await fontLoader.load();
}

MailboxNode _mailboxNode({
  required String id,
  String name = 'Folder',
  int unreadEmails = 0,
  int totalEmails = 0,
  Role? role,
  List<MailboxNode>? children,
}) {
  return MailboxNode(
    PresentationMailbox(
      MailboxId(Id(id)),
      name: MailboxName(name),
      role: role,
      totalEmails: TotalEmails(UnsignedInt(totalEmails)),
      unreadEmails: UnreadEmails(UnsignedInt(unreadEmails)),
    ),
    childrenItems: children,
    expandMode: ExpandMode.COLLAPSE,
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
}) async {
  await tester.pumpWidget(GetMaterialApp(
    theme: ThemeData(brightness: brightness),
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: LocalizationService.supportedLocales,
    home: Directionality(
      textDirection: textDirection,
      child: Scaffold(body: child),
    ),
  ));
  await tester.pump();
}

/// The row actions a test asks the mailbox row to reveal.
enum _MailboxAction { clean, more }

Widget _mailboxItemActions({
  required MailboxNode mailboxNode,
  Set<_MailboxAction> actions = const {_MailboxAction.clean, _MailboxAction.more},
  OnEmptyMailboxActionCallback? onEmptyMailboxActionCallback,
  OnClickOpenMenuMailboxNodeAction? onMenuActionClick,
}) {
  return Builder(builder: (context) => LinagoraSidebarItemActions(
    actions: buildSidebarMailboxItemActions(
      context,
      mailboxNode: mailboxNode,
      imagePaths: _imagePaths,
      showCleanAction: actions.contains(_MailboxAction.clean),
      showMoreAction: actions.contains(_MailboxAction.more),
      onEmptyMailboxActionCallback: onEmptyMailboxActionCallback,
      onMenuActionClick: onMenuActionClick,
    ),
  ));
}
