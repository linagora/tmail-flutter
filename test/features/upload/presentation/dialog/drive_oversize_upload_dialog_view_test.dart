import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/drive_oversize_upload_dialog_view.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/drive_oversize_upload_row.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_oversize_transfer_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/providers/drive_oversize_transfer_notifier.dart';
import 'package:tmail_ui_user/features/upload/presentation/styles/drive_oversize_upload_dialog_style.dart';

import '../../../../fixtures/widget_fixtures.dart';
import 'drive_oversize_upload_dialog_view_test.mocks.dart';

@GenerateNiceMocks([MockSpec<MailboxDashBoardController>()])
void main() {
  late MockMailboxDashBoardController dashboard;
  late ProviderContainer container;

  DriveOversizeTransferState makeItem(
    String id, {
    int fileSize = 1000,
    int sentBytes = 0,
    DriveOversizeTransferStatus status = DriveOversizeTransferStatus.waiting,
  }) =>
      DriveOversizeTransferState(
        taskId: UploadTaskId(id),
        fileName: '$id.txt',
        fileSize: fileSize,
        sentBytes: sentBytes,
        status: status,
        cancelToken: CancelToken(),
      );

  Future<void> pumpDialog(
    WidgetTester tester, {
    required List<DriveOversizeTransferState> items,
    bool isWebLayout = true,
  }) async {
    container.read(driveOversizeTransferProvider.notifier).start(items);
    await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
      providerContainer: container,
      child: DriveOversizeUploadDialogView(
        imagePaths: ImagePaths(),
        isWebLayout: isWebLayout,
      ),
    ));
    // AppLocalizationsDelegate resolves asynchronously; the real subtree
    // only appears after that first async gap settles. pumpAndSettle can't
    // be used here — an indeterminate progress bar animates forever.
    await tester.pump();
    await tester.pump();
  }

  setUp(() {
    Get.testMode = true;
    dashboard = MockMailboxDashBoardController();
    when(dashboard.onStart).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(dashboard.onDelete).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(dashboard.maxSizeAttachmentsPerEmail).thenReturn(null);
    Get.put<MailboxDashBoardController>(dashboard);
    container = ProviderContainer();
  });

  tearDown(() {
    Get.reset();
    container.dispose();
  });

  group('DriveOversizeUploadDialogView::', () {
    testWidgets('1 item renders 1 row', (tester) async {
      await pumpDialog(tester, items: [makeItem('a')]);
      expect(find.byType(DriveOversizeUploadRow), findsOneWidget);
    });

    testWidgets('3 items render 3 rows in one ListView', (tester) async {
      await pumpDialog(tester, items: [makeItem('a'), makeItem('b'), makeItem('c')]);
      expect(find.byType(DriveOversizeUploadRow), findsNWidgets(3));
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('a row with no bytes renders LinearProgressIndicator', (tester) async {
      await pumpDialog(tester, items: [makeItem('a', status: DriveOversizeTransferStatus.uploading)]);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(LinearPercentIndicator), findsNothing);
    });

    testWidgets('a row with bytes renders LinearPercentIndicator at the right percent', (tester) async {
      await pumpDialog(tester, items: [
        makeItem('a', sentBytes: 400, status: DriveOversizeTransferStatus.uploading),
      ]);
      final indicator = tester.widget<LinearPercentIndicator>(find.byType(LinearPercentIndicator));
      expect(indicator.percent, closeTo(0.4, 0.001));
    });

    testWidgets('a linked row renders the bar at 1.0', (tester) async {
      await pumpDialog(tester, items: [
        makeItem('a', sentBytes: 1000, status: DriveOversizeTransferStatus.linked),
      ]);
      final indicator = tester.widget<LinearPercentIndicator>(find.byType(LinearPercentIndicator));
      expect(indicator.percent, equals(1.0));
    });

    testWidgets('a progress tick updates that row\'s bar', (tester) async {
      await pumpDialog(tester, items: [
        makeItem('a', sentBytes: 400, status: DriveOversizeTransferStatus.uploading),
        makeItem('b'),
      ]);

      container.read(driveOversizeTransferProvider.notifier)
        .reportProgress(const UploadTaskId('a'), 700, 1000);
      await tester.pump();

      final indicator = tester.widget<LinearPercentIndicator>(find.byType(LinearPercentIndicator));
      expect(indicator.percent, closeTo(0.7, 0.001));
    });

    testWidgets('a settled row renders no close icon button', (tester) async {
      await pumpDialog(tester, items: [makeItem('a', status: DriveOversizeTransferStatus.linked)]);
      final row = tester.widget<DriveOversizeUploadRow>(find.byType(DriveOversizeUploadRow));
      expect(row.item.status.settled, isTrue);
    });

    // Cancel is the only TMailButtonWidget built with visible text (the row
    // and header close buttons use fromIcon, whose text defaults to '').
    Finder cancelButtonIgnorePointer() => find.ancestor(
          of: find.byWidgetPredicate((widget) => widget is TMailButtonWidget && widget.text.isNotEmpty),
          matching: find.byType(IgnorePointer),
        ).first;

    testWidgets('Cancel button is non-interactive once every row is settled', (tester) async {
      await pumpDialog(tester, items: [makeItem('a', status: DriveOversizeTransferStatus.linked)]);
      final ignorePointer = tester.widget<IgnorePointer>(cancelButtonIgnorePointer());
      expect(ignorePointer.ignoring, isTrue);
    });

    testWidgets('Cancel button is interactive while a row is running', (tester) async {
      await pumpDialog(tester, items: [makeItem('a', status: DriveOversizeTransferStatus.uploading)]);
      final ignorePointer = tester.widget<IgnorePointer>(cancelButtonIgnorePointer());
      expect(ignorePointer.ignoring, isFalse);
    });

    testWidgets('tapping a row close button cancels only that row', (tester) async {
      await pumpDialog(tester, items: [makeItem('a'), makeItem('b')]);

      final rowCloseButton = find.descendant(
        of: find.byType(DriveOversizeUploadRow).first,
        matching: find.byType(TMailButtonWidget),
      );
      await tester.tap(rowCloseButton);
      await tester.pump();

      final rows = container.read(driveOversizeTransferProvider);
      expect(rows[0].status, equals(DriveOversizeTransferStatus.cancelled));
      expect(rows[1].status, equals(DriveOversizeTransferStatus.waiting));
    });

    testWidgets('tapping the header close cancels every row', (tester) async {
      await pumpDialog(tester, items: [makeItem('a'), makeItem('b')]);

      final headerClose = find.byWidgetPredicate((widget) =>
          widget is TMailButtonWidget &&
          widget.iconSize == DriveOversizeUploadDialogStyle.headerCloseIconSize);
      await tester.tap(headerClose);
      await tester.pump();

      final rows = container.read(driveOversizeTransferProvider);
      expect(rows.every((row) => row.status == DriveOversizeTransferStatus.cancelled), isTrue);
    });

    testWidgets('isWebLayout true puts the bar inside the row', (tester) async {
      await pumpDialog(tester, items: [makeItem('a')], isWebLayout: true);
      final row = tester.widget<DriveOversizeUploadRow>(find.byType(DriveOversizeUploadRow));
      expect(row.isWebLayout, isTrue);
    });

    testWidgets('isWebLayout false puts the bar on its own line', (tester) async {
      await pumpDialog(tester, items: [makeItem('a')], isWebLayout: false);
      final row = tester.widget<DriveOversizeUploadRow>(find.byType(DriveOversizeUploadRow));
      expect(row.isWebLayout, isFalse);
    });
  });
}
