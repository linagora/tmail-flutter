import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/drive_oversize_upload_dialog_presenter.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/drive_oversize_upload_dialog_view.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_oversize_transfer_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/providers/drive_oversize_transfer_notifier.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../../fixtures/widget_fixtures.dart';
import 'drive_oversize_upload_dialog_presenter_test.mocks.dart';

// The indeterminate bar animates forever, so pumpAndSettle can't be used:
// a route transition gets a frame to start, one past its end, one to finalize.
const _routeTransition = Duration(milliseconds: 400);

Future<void> _settleRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(_routeTransition);
  await tester.pump();
}

final _dialogView = find.byType(DriveOversizeUploadDialogView);

Future<void> _pumpHost(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    providerContainer: container,
    child: const SizedBox.shrink(),
  ));
  // AppLocalizationsDelegate resolves asynchronously.
  await tester.pump();
  await tester.pump();
}

Future<void> _showDialog(WidgetTester tester, ProviderContainer container) async {
  DriveOversizeUploadDialogPresenter.show(container);
  await _settleRoute(tester);
}

@GenerateNiceMocks([MockSpec<MailboxDashBoardController>()])
void main() {
  late ProviderContainer container;

  setUp(() {
    Get.testMode = true;
    final dashboard = MockMailboxDashBoardController();
    when(dashboard.onStart).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(dashboard.onDelete).thenReturn(InternalFinalCallback<void>(callback: () {}));
    Get.put<MailboxDashBoardController>(dashboard);
    container = ProviderContainer();
    container.read(driveOversizeTransferProvider.notifier).start([
      DriveOversizeTransferState(
        taskId: const UploadTaskId('a'),
        fileName: 'a.bin',
        fileSize: 1000,
        cancelToken: CancelToken(),
      ),
    ]);
  });

  tearDown(() {
    Get.reset();
    container.dispose();
  });

  group('DriveOversizeUploadDialogPresenter::', () {
    testWidgets('show opens the dialog named for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpHost(tester, container);

      await _showDialog(tester, container);

      expect(_dialogView, findsOneWidget);
      final appLocalizations = AppLocalizations.of(tester.element(_dialogView));
      expect(
        tester.getSemantics(find.byType(LinagoraFileTransferSurface)),
        containsSemantics(
          label: appLocalizations.attachingFileTitle,
          scopesRoute: true,
          namesRoute: true,
        ),
      );
      semantics.dispose();
    });

    for (final layoutCase in [
      (isWeb: true, layout: LinagoraFileTransferLayout.wide),
      (isWeb: false, layout: LinagoraFileTransferLayout.compact),
    ]) {
      testWidgets('show uses the ${layoutCase.layout.name} layout when isWeb is ${layoutCase.isWeb}', (tester) async {
        PlatformInfo.isTestingForWeb = layoutCase.isWeb;
        addTearDown(() => PlatformInfo.isTestingForWeb = false);
        await _pumpHost(tester, container);

        await _showDialog(tester, container);

        final surface = tester.widget<LinagoraFileTransferSurface>(find.byType(LinagoraFileTransferSurface));
        final view = tester.widget<DriveOversizeUploadDialogView>(_dialogView);
        expect(surface.layout, equals(layoutCase.layout));
        expect(view.isWebLayout, equals(layoutCase.isWeb));
      });
    }

    testWidgets('a tap on the barrier does not close the dialog', (tester) async {
      await _pumpHost(tester, container);
      await _showDialog(tester, container);

      await tester.tapAt(const Offset(4, 4));
      await _settleRoute(tester);

      expect(_dialogView, findsOneWidget);
    });

    testWidgets('a system back does not close the dialog', (tester) async {
      await _pumpHost(tester, container);
      await _showDialog(tester, container);

      await tester.binding.handlePopRoute();
      await _settleRoute(tester);

      expect(_dialogView, findsOneWidget);
    });

    testWidgets('close dismisses the open dialog', (tester) async {
      await _pumpHost(tester, container);
      await _showDialog(tester, container);

      DriveOversizeUploadDialogPresenter.close();
      await _settleRoute(tester);

      expect(_dialogView, findsNothing);
    });

    testWidgets('close with no dialog open leaves the current page in place', (tester) async {
      await _pumpHost(tester, container);
      Get.to(() => const Scaffold(body: Text('second page')));
      await _settleRoute(tester);

      DriveOversizeUploadDialogPresenter.close();
      await _settleRoute(tester);

      expect(find.text('second page'), findsOneWidget);
    });
  });
}
