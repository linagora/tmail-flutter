import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/view_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/view_attachment_for_web_interactor.dart';

import 'view_attachment_for_web_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<DownloadAttachmentForWebInteractor>(),
  MockSpec<Failure>(),
  MockSpec<Success>(),
])
void main() {
  final testDownloadAttachmentForWebInteractor =
      MockDownloadAttachmentForWebInteractor();
  final viewAttachmentForWebInteractor =
      ViewAttachmentForWebInteractor(testDownloadAttachmentForWebInteractor);

  final testDownloadTaskId = DownloadTaskId('123');
  final testAttachment = Attachment();
  final testAccountId = AccountId(Id('id'));
  final testException = TimeoutException('321');
  const testBaseDownloadUrl = 'base_download_url';
  final testReceiveController = StreamController<Either<Failure, Success>>();
  final testFailure = MockFailure();
  final testSuccess = MockSuccess();
  final testBytes = Uint8List(12);

  group('View attachment for web interactor', () {
    test(
      'should yield ViewAttachmentForWebFailure '
      'when downloadAttachmentForWebInteractor yield DownloadAttachmentForWebFailure',
      () {
        // arrange
        when(testDownloadAttachmentForWebInteractor.execute(
          testDownloadTaskId,
          testAttachment,
          testAccountId,
          testBaseDownloadUrl,
          testReceiveController,
        )).thenAnswer(
          (_) => Stream.value(
            Left(
              DownloadAttachmentForWebFailure(
                attachment: testAttachment,
                taskId: testDownloadTaskId,
                exception: testException,
              ),
            ),
          ),
        );

        // assert
        expect(
          viewAttachmentForWebInteractor.execute(
            testDownloadTaskId,
            testAttachment,
            testAccountId,
            testBaseDownloadUrl,
            testReceiveController,
          ),
          emitsInOrder([
            Left(
              ViewAttachmentForWebFailure(
                attachment: testAttachment,
                taskId: testDownloadTaskId,
                exception: testException,
              ),
            )
          ]),
        );
      },
    );

    test(
      'should yield Failure '
      'when downloadAttachmentForWebInteractor doesn\'t yield DownloadAttachmentForWebFailure',
      () {
        // arrange
        when(testDownloadAttachmentForWebInteractor.execute(
          testDownloadTaskId,
          testAttachment,
          testAccountId,
          testBaseDownloadUrl,
          testReceiveController,
        )).thenAnswer((_) => Stream.value(Left(testFailure)));

        // assert
        expect(
          viewAttachmentForWebInteractor.execute(
            testDownloadTaskId,
            testAttachment,
            testAccountId,
            testBaseDownloadUrl,
            testReceiveController,
          ),
          emitsInOrder([Left(testFailure)]),
        );
      },
    );

    test(
      'should yield StartViewAttachmentForWeb '
      'when downloadAttachmentForWebInteractor yield StartDownloadAttachmentForWeb',
      () {
        // arrange
        when(testDownloadAttachmentForWebInteractor.execute(
          testDownloadTaskId,
          testAttachment,
          testAccountId,
          testBaseDownloadUrl,
          testReceiveController,
        )).thenAnswer((_) => Stream.value(
              Right(StartDownloadAttachmentForWeb(
                testDownloadTaskId,
                testAttachment,
              )),
            ));

        // assert
        expect(
          viewAttachmentForWebInteractor.execute(
            testDownloadTaskId,
            testAttachment,
            testAccountId,
            testBaseDownloadUrl,
            testReceiveController,
          ),
          emitsInOrder([
            Right(StartViewAttachmentForWeb(
              testDownloadTaskId,
              testAttachment,
            ))
          ]),
        );
      },
    );

    test(
      'should yield ViewingAttachmentForWeb '
      'when downloadAttachmentForWebInteractor yield DownloadingAttachmentForWeb',
      () {
        // arrange
        when(testDownloadAttachmentForWebInteractor.execute(
          testDownloadTaskId,
          testAttachment,
          testAccountId,
          testBaseDownloadUrl,
          testReceiveController,
        )).thenAnswer(
          (_) => Stream.fromIterable([
            Right(DownloadingAttachmentForWeb(testDownloadTaskId, testAttachment, 0.5, 1, 2)),
            Right(DownloadingAttachmentForWeb(testDownloadTaskId, testAttachment, 1, 1, 2)),
            Right(DownloadingAttachmentForWeb(testDownloadTaskId, testAttachment, 1, 2, 2)),
          ]),
        );

        // assert
        expect(
          viewAttachmentForWebInteractor.execute(
            testDownloadTaskId,
            testAttachment,
            testAccountId,
            testBaseDownloadUrl,
            testReceiveController,
          ),
          emitsInOrder([
            Right(ViewingAttachmentForWeb(testDownloadTaskId, testAttachment, 0.5, 1, 2)),
            Right(ViewingAttachmentForWeb(testDownloadTaskId, testAttachment, 1, 1, 2)),
            Right(ViewingAttachmentForWeb(testDownloadTaskId, testAttachment, 1, 2, 2)),
          ]),
        );
      },
    );

    test(
      'should yield ViewAttachmentForWebSuccess '
      'when downloadAttachmentForWebInteractor yield DownloadAttachmentForWebSuccess',
      () {
        // arrange
        when(testDownloadAttachmentForWebInteractor.execute(
          testDownloadTaskId,
          testAttachment,
          testAccountId,
          testBaseDownloadUrl,
          testReceiveController,
        )).thenAnswer((_) => Stream.value(
              Right(DownloadAttachmentForWebSuccess(
                testDownloadTaskId,
                testAttachment,
                testBytes,
              )),
            ));

        // assert
        expect(
          viewAttachmentForWebInteractor.execute(
            testDownloadTaskId,
            testAttachment,
            testAccountId,
            testBaseDownloadUrl,
            testReceiveController,
          ),
          emitsInOrder([
            Right(ViewAttachmentForWebSuccess(
              testDownloadTaskId,
              testAttachment,
              testBytes,
            )),
          ]),
        );
      },
    );

    test(
      'should yield Success '
      'when downloadAttachmentForWebInteractor yield state doesn\'t match any of the above',
      () {
        // arrange
        when(testDownloadAttachmentForWebInteractor.execute(
          testDownloadTaskId,
          testAttachment,
          testAccountId,
          testBaseDownloadUrl,
          testReceiveController,
        )).thenAnswer((_) => Stream.value(Right(testSuccess)));

        // assert
        expect(
          viewAttachmentForWebInteractor.execute(
            testDownloadTaskId,
            testAttachment,
            testAccountId,
            testBaseDownloadUrl,
            testReceiveController,
          ),
          emitsInOrder([Right(testSuccess)]),
        );
      },
    );
  });
}
