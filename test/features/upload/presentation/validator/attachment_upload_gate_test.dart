import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_size_limit_rule.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_limits.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_size_snapshot.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_upload_gate.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_upload_recovery.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_validation_feedback_impl.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../../fixtures/widget_fixtures.dart';

AttachmentUploadRequest _request({
  int proposedAllAttachmentBytes = 0,
  int proposedRegularAttachmentBytes = 0,
  int? hardLimitBytes,
  List<FileInfo> files = const [],
}) {
  return AttachmentUploadRequest(
    sizes: AttachmentUploadSizeSnapshot(
      currentAllAttachmentBytes: 0,
      proposedAllAttachmentBytes: proposedAllAttachmentBytes,
      currentRegularAttachmentBytes: 0,
      proposedRegularAttachmentBytes: proposedRegularAttachmentBytes,
    ),
    limits: AttachmentUploadLimits(warningLimitBytes: 1000000, hardLimitBytes: hardLimitBytes),
    files: files,
  );
}

const _oversizeFile = FilePlaceholderInfo(fileName: 'big.zip', fileSize: 200);
const _oversizeInlineFile = FilePlaceholderInfo(fileName: 'shot.png', fileSize: 200, isInline: true);

class _StubRecovery implements AttachmentUploadRecovery {
  final Future<bool> Function(AttachmentUploadFailure failure, AttachmentUploadRequest request) onRecover;
  bool called = false;

  _StubRecovery(this.onRecover);

  @override
  Future<bool> recover(AttachmentUploadFailure failure, AttachmentUploadRequest request) {
    called = true;
    return onRecover(failure, request);
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<ImagePaths>(ImagePaths());
    Get.put<ResponsiveUtils>(ResponsiveUtils());
  });

  tearDown(() {
    Get.reset();
  });

  final gate = AttachmentUploadGate(AttachmentUploadValidator([const AttachmentSizeLimitRule()]));

  group('AttachmentUploadGate.permits', () {
    testWidgets('should return true directly when validation passes', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();

      final context = tester.element(find.byType(SizedBox));

      final allowed = await gate.permits(
        request: _request(proposedAllAttachmentBytes: 10, hardLimitBytes: 1000),
        feedbackFactory: () => AttachmentValidationFeedbackImpl(context));

      expect(allowed, isTrue);
    });

    testWidgets('should present the failure dialog and return false when rejected', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();

      final context = tester.element(find.byType(SizedBox));
      final appLocalizations = AppLocalizations.of(context);

      final future = gate.permits(
        request: _request(proposedAllAttachmentBytes: 200, hardLimitBytes: 100),
        feedbackFactory: () => AttachmentValidationFeedbackImpl(context));
      await tester.pump();

      expect(find.byKey(const Key('confirm_dialog_action')), findsOneWidget);
      expect(
        find.text(appLocalizations
            .message_dialog_upload_attachments_exceeds_maximum_size(filesize(100, 0))),
        findsOneWidget);

      await tester.tap(find.text(appLocalizations.got_it));
      await tester.pumpAndSettle();

      expect(await future, isFalse);
    });

    testWidgets('should return true after the user confirms the warning', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();

      final context = tester.element(find.byType(SizedBox));

      final future = gate.permits(
        request: _request(proposedRegularAttachmentBytes: 20000000),
        feedbackFactory: () => AttachmentValidationFeedbackImpl(context));
      await tester.pump();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(await future, isTrue);
    });

    testWidgets('should return false when the user cancels the warning', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();

      final context = tester.element(find.byType(SizedBox));

      final future = gate.permits(
        request: _request(proposedRegularAttachmentBytes: 20000000),
        feedbackFactory: () => AttachmentValidationFeedbackImpl(context));
      await tester.pump();

      final closeButton = find.byWidgetPredicate((widget) =>
        widget is TMailButtonWidget && widget.icon == ImagePaths().icCloseDialog);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(await future, isFalse);
    });
  });

  group('AttachmentUploadGate.permits with recovery', () {
    testWidgets('no builder shows the failure dialog', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();
      final context = tester.element(find.byType(SizedBox));

      final future = gate.permits(
        request: _request(
          proposedAllAttachmentBytes: 200, hardLimitBytes: 100, files: [_oversizeFile]),
        feedbackFactory: () => AttachmentValidationFeedbackImpl(context),
      );
      await tester.pump();

      expect(find.byKey(const Key('confirm_dialog_action')), findsOneWidget);
      await tester.tap(find.text(AppLocalizations.of(context).got_it));
      await tester.pumpAndSettle();
      expect(await future, isFalse);
    });

    testWidgets('recovery returning true skips the dialog and returns false', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();
      final context = tester.element(find.byType(SizedBox));
      final recovery = _StubRecovery((_, __) async => true);

      final allowed = await gate.permits(
        request: _request(
          proposedAllAttachmentBytes: 200, hardLimitBytes: 100, files: [_oversizeFile]),
        feedbackFactory: () => AttachmentValidationFeedbackImpl(context),
        recoveryFactory: () => recovery,
      );

      expect(recovery.called, isTrue);
      expect(allowed, isFalse);
      expect(find.byKey(const Key('confirm_dialog_action')), findsNothing);
    });

    testWidgets('recovery returning false falls back to the dialog', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();
      final context = tester.element(find.byType(SizedBox));
      final recovery = _StubRecovery((_, __) async => false);

      final future = gate.permits(
        request: _request(
          proposedAllAttachmentBytes: 200, hardLimitBytes: 100, files: [_oversizeFile]),
        feedbackFactory: () => AttachmentValidationFeedbackImpl(context),
        recoveryFactory: () => recovery,
      );
      await tester.pump();

      expect(find.byKey(const Key('confirm_dialog_action')), findsOneWidget);
      await tester.tap(find.text(AppLocalizations.of(context).got_it));
      await tester.pumpAndSettle();
      expect(await future, isFalse);
    });

    testWidgets('recovery throwing falls back to the dialog', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();
      final context = tester.element(find.byType(SizedBox));
      final recovery = _StubRecovery((_, __) async => throw Exception('declined'));

      final future = gate.permits(
        request: _request(
          proposedAllAttachmentBytes: 200, hardLimitBytes: 100, files: [_oversizeFile]),
        feedbackFactory: () => AttachmentValidationFeedbackImpl(context),
        recoveryFactory: () => recovery,
      );
      await tester.pump();

      expect(find.byKey(const Key('confirm_dialog_action')), findsOneWidget);
      await tester.tap(find.text(AppLocalizations.of(context).got_it));
      await tester.pumpAndSettle();
      expect(await future, isFalse);
    });

    testWidgets('inline-only files never build a recovery', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();
      final context = tester.element(find.byType(SizedBox));
      var builderCalled = false;

      final future = gate.permits(
        request: _request(
          proposedAllAttachmentBytes: 200, hardLimitBytes: 100, files: [_oversizeInlineFile]),
        feedbackFactory: () => AttachmentValidationFeedbackImpl(context),
        recoveryFactory: () {
          builderCalled = true;
          return _StubRecovery((_, __) async => true);
        },
      );
      await tester.pump();

      expect(builderCalled, isFalse);
      expect(find.byKey(const Key('confirm_dialog_action')), findsOneWidget);
      await tester.tap(find.text(AppLocalizations.of(context).got_it));
      await tester.pumpAndSettle();
      expect(await future, isFalse);
    });
  });
}
