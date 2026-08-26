import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/concurrency_gate.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_transfer_runner.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';
import 'package:tmail_ui_user/features/upload/domain/state/upload_drive_document_from_url_state.dart';
import 'package:workplace/domain/entity/drive_document.dart';

class _StubFailure extends FeatureFailure {
  _StubFailure() : super(exception: Exception('failed'));
}

void main() {
  final accountId = AccountId(Id('account-1'));
  final uploadUri = Uri.parse('https://mail.example.com/upload-from-url/account-1');
  int taskCounter = 0;

  DriveDocument doc({String? downloadLink, String? name, int? size, String? mimeType}) => DriveDocument(
        id: 'doc-${taskCounter++}',
        name: name ?? 'file.pdf',
        size: size ?? 100,
        mimeType: mimeType ?? 'application/pdf',
        downloadLink: downloadLink == null ? null : Uri.parse(downloadLink),
      );

  DriveAttachmentTransferRunner makeRunner({
    required UploadFromUrlCall uploadFromUrl,
    ConcurrencyGate? gate,
    int maxConcurrent = 3,
  }) =>
      DriveAttachmentTransferRunner(
        uploadFromUrl: uploadFromUrl,
        gate: gate ?? ConcurrencyGate(maxConcurrent),
      );

  // Shared by the resolved-outcome tests below; only the uploadFromUrl
  // stub and the expected callback counts differ between them.
  Future<void> expectResolvedCallbackCounts({
    required UploadFromUrlCall uploadFromUrl,
    required int expectedSuccessCalls,
    required int expectedFailureCalls,
  }) async {
    var successCalls = 0;
    var failureCalls = 0;
    final runner = makeRunner(uploadFromUrl: uploadFromUrl);

    await runner.transfer((
      docs: [doc(downloadLink: 'https://drive.example.com/1')],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) {},
      onSuccess: (_, __) => successCalls++,
      onFailure: (_) => failureCalls++,
    ));

    expect(successCalls, expectedSuccessCalls);
    expect(failureCalls, expectedFailureCalls);
  }

  // Shared by the invalid-downloadLink tests: neither shape may reach the gateway.
  Future<void> expectNoUploadForDownloadLink(String? downloadLink) async {
    var uploadCalls = 0;
    UploadTaskId? failedTaskId;
    final runner = makeRunner(uploadFromUrl: (request) async {
      uploadCalls++;
      return Left(_StubFailure());
    });

    await runner.transfer((
      docs: [doc(downloadLink: downloadLink)],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) {},
      onSuccess: (_, __) {},
      onFailure: (taskId) => failedTaskId = taskId,
    ));

    expect(uploadCalls, 0);
    expect(failedTaskId, isNotNull);
  }

  setUp(() => taskCounter = 0);

  test('Should report a not-started outcome and call nothing for an empty batch', () async {
    var uploadCalls = 0;
    final runner = makeRunner(uploadFromUrl: (request) async {
      uploadCalls++;
      return Left(_StubFailure());
    });

    final result = await runner.transfer((
      docs: const [],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) {},
      onSuccess: (_, __) {},
      onFailure: (_) {},
    ));

    expect(result, DriveAttachmentTransferRunner.notStartedOutcome);
    expect(uploadCalls, 0);
  });

  test('Should report placeholders before any success/failure callback fires', () async {
    final events = <String>[];
    final runner = makeRunner(uploadFromUrl: (request) async {
      return Right(UploadDriveDocumentFromUrlSuccess(
        Attachment(name: request.name),
      ));
    });

    await runner.transfer((
      docs: [doc(downloadLink: 'https://drive.example.com/1')],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (placeholders) => events.add('placeholders:${placeholders.length}'),
      onSuccess: (_, __) => events.add('success'),
      onFailure: (_) => events.add('failure'),
    ));

    expect(events, ['placeholders:1', 'success']);
  });

  test('Should resolve failure for a doc with a null downloadLink without calling uploadFromUrl', () async {
    await expectNoUploadForDownloadLink(null);
  });

  test('Should resolve failure for a doc with an empty downloadLink without calling uploadFromUrl', () async {
    await expectNoUploadForDownloadLink('');
  });

  test('Should not call uploadFromUrl for a task cancelled while waiting in the queue', () async {
    final uploadedNames = <String>[];
    final failedTaskIds = <UploadTaskId>[];
    final firstUploadBlocker = Completer<void>();
    final runner = makeRunner(
      maxConcurrent: 1,
      uploadFromUrl: (request) async {
        uploadedNames.add(request.name);
        if (uploadedNames.length == 1) await firstUploadBlocker.future;
        return Right(UploadDriveDocumentFromUrlSuccess(Attachment(name: request.name)));
      },
    );

    final future = runner.transfer((
      docs: [
        doc(downloadLink: 'https://drive.example.com/1', name: 'first.pdf'),
        doc(downloadLink: 'https://drive.example.com/2', name: 'queued.pdf'),
      ],
      accountId: accountId,
      uploadUri: uploadUri,
      // The queued chip is deleted while the first upload still holds the worker.
      onPlaceholdersReady: (placeholders) => placeholders.last.cancelToken?.cancel(),
      onSuccess: (_, __) {},
      onFailure: failedTaskIds.add,
    ));

    await Future<void>.delayed(Duration.zero);
    firstUploadBlocker.complete();
    await future;

    expect(uploadedNames, ['first.pdf']);
    expect(failedTaskIds, isEmpty);
  });

  test('Should never run more than maxConcurrent uploads at once', () async {
    var inFlight = 0;
    var maxInFlight = 0;
    final completers = <Completer<void>>[];
    final runner = makeRunner(
      maxConcurrent: 2,
      uploadFromUrl: (request) async {
        inFlight++;
        maxInFlight = maxInFlight < inFlight ? inFlight : maxInFlight;
        final completer = Completer<void>();
        completers.add(completer);
        await completer.future;
        inFlight--;
        return Right(UploadDriveDocumentFromUrlSuccess(Attachment(name: request.name)));
      },
    );

    final docs = List.generate(5, (_) => doc(downloadLink: 'https://drive.example.com/x'));
    final future = runner.transfer((
      docs: docs,
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) {},
      onSuccess: (_, __) {},
      onFailure: (_) {},
    ));

    // Let the first wave of workers spawn and block on their completers.
    await Future<void>.delayed(Duration.zero);
    expect(maxInFlight, lessThanOrEqualTo(2));

    while (completers.any((c) => !c.isCompleted)) {
      completers.firstWhere((c) => !c.isCompleted).complete();
      await Future<void>.delayed(Duration.zero);
    }
    await future;

    expect(maxInFlight, lessThanOrEqualTo(2));
  });

  test('Should call uploadFromUrl and onSuccess exactly once per doc in a 5-doc batch', () async {
    var uploadCalls = 0;
    var successCalls = 0;
    final runner = makeRunner(
      maxConcurrent: 2,
      uploadFromUrl: (request) async {
        uploadCalls++;
        return Right(UploadDriveDocumentFromUrlSuccess(Attachment(name: request.name)));
      },
    );

    final docs = List.generate(5, (_) => doc(downloadLink: 'https://drive.example.com/x'));
    await runner.transfer((
      docs: docs,
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) {},
      onSuccess: (_, __) => successCalls++,
      onFailure: (_) {},
    ));

    expect(uploadCalls, 5);
    expect(successCalls, 5);
  });

  test('Should fold an upload failure into onFailure for the matching task', () async {
    final failedTaskIds = <UploadTaskId>[];
    final runner = makeRunner(uploadFromUrl: (request) async => Left(_StubFailure()));

    await runner.transfer((
      docs: [doc(downloadLink: 'https://drive.example.com/1')],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) {},
      onSuccess: (_, __) {},
      onFailure: failedTaskIds.add,
    ));

    expect(failedTaskIds, hasLength(1));
  });

  test('Should not mask an onSuccess throw as a second onFailure call', () async {
    var failureCalls = 0;
    final runner = makeRunner(uploadFromUrl: (request) async {
      return Right(UploadDriveDocumentFromUrlSuccess(Attachment(name: request.name)));
    });

    final result = await runner.transfer((
      docs: [doc(downloadLink: 'https://drive.example.com/1')],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) {},
      onSuccess: (_, __) => throw StateError('onSuccess blew up'),
      onFailure: (_) => failureCalls++,
    ));

    expect(failureCalls, 0);
    expect(result, (started: true, succeeded: 1, failed: 0));
  });

  test('Should resolve failure when uploadFromUrl throws', () async {
    await expectResolvedCallbackCounts(
      uploadFromUrl: (request) async => throw DioException(
        requestOptions: RequestOptions(path: '/'),
      ),
      expectedSuccessCalls: 0,
      expectedFailureCalls: 1,
    );
  });

  test('Should resolve failure when the success payload is not UploadDriveDocumentFromUrlSuccess', () async {
    await expectResolvedCallbackCounts(
      uploadFromUrl: (request) async => Right(UIState.idle),
      expectedSuccessCalls: 0,
      expectedFailureCalls: 1,
    );
  });

  test('Should resolve neither success nor failure when the transfer was cancelled', () async {
    await expectResolvedCallbackCounts(
      uploadFromUrl: (request) async => Left(UploadDriveDocumentFromUrlCancelled()),
      expectedSuccessCalls: 0,
      expectedFailureCalls: 0,
    );
  });

  test('Should forward the request payload to uploadFromUrl unchanged', () async {
    UploadFromUrlRequest? capturedRequest;
    final runner = makeRunner(uploadFromUrl: (request) async {
      capturedRequest = request;
      return Right(UploadDriveDocumentFromUrlSuccess(Attachment(name: request.name)));
    });

    await runner.transfer((
      docs: [doc(
        downloadLink: 'https://drive.example.com/1',
        name: 'report.pdf',
        mimeType: 'application/pdf',
      )],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) {},
      onSuccess: (_, __) {},
      onFailure: (_) {},
    ));

    expect(capturedRequest, isNotNull);
    expect(capturedRequest!.accountId, accountId);
    expect(capturedRequest!.uploadUri, uploadUri);
    expect(capturedRequest!.attachmentUrl, Uri.parse('https://drive.example.com/1'));
    expect(capturedRequest!.name, 'report.pdf');
    expect(capturedRequest!.mimeType, 'application/pdf');
    expect(capturedRequest!.cancelToken, isNotNull);
  });

  test('Should mint a unique placeholder per doc carrying its own metadata', () async {
    final placeholderDocs = [
      doc(downloadLink: 'https://drive.example.com/1', name: 'a.pdf', size: 10),
      doc(downloadLink: 'https://drive.example.com/2', name: 'b.pdf', size: 20),
    ];
    final runner = makeRunner(uploadFromUrl: (request) async {
      return Right(UploadDriveDocumentFromUrlSuccess(Attachment(name: request.name)));
    });

    late final List<dynamic> placeholders;
    await runner.transfer((
      docs: placeholderDocs,
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (received) => placeholders = received,
      onSuccess: (_, __) {},
      onFailure: (_) {},
    ));

    expect(placeholders, hasLength(2));
    expect(placeholders[0].taskId, isNot(placeholders[1].taskId));
    expect(placeholders[0].fileName, 'a.pdf');
    expect(placeholders[0].fileSize, 10);
    expect(placeholders[0].cancelToken, isNotNull);
    expect(placeholders[1].fileName, 'b.pdf');
    expect(placeholders[1].fileSize, 20);
    expect(placeholders[1].cancelToken, isNotNull);
  });

  test('Should route each taskId to the right callback in a mixed batch', () async {
    final successDoc = doc(downloadLink: 'https://drive.example.com/ok');
    final failDoc = doc(downloadLink: 'https://drive.example.com/fail');
    final nullLinkDoc = doc();

    final runner = makeRunner(uploadFromUrl: (request) async {
      if (request.attachmentUrl.toString().endsWith('/ok')) {
        return Right(UploadDriveDocumentFromUrlSuccess(Attachment(name: request.name)));
      }
      return Left(_StubFailure());
    });

    late final List<dynamic> placeholders;
    final succeededTaskIds = <UploadTaskId>[];
    final failedTaskIds = <UploadTaskId>[];

    final result = await runner.transfer((
      docs: [successDoc, failDoc, nullLinkDoc],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (received) => placeholders = received,
      onSuccess: (taskId, _) => succeededTaskIds.add(taskId),
      onFailure: failedTaskIds.add,
    ));

    final successTaskId = placeholders[0].taskId as UploadTaskId;
    final failTaskId = placeholders[1].taskId as UploadTaskId;
    final nullLinkTaskId = placeholders[2].taskId as UploadTaskId;

    expect(succeededTaskIds, [successTaskId]);
    expect(failedTaskIds, containsAll([failTaskId, nullLinkTaskId]));
    expect(failedTaskIds, hasLength(2));
    expect(result, (started: true, succeeded: 1, failed: 2));
  });

  test('Should report a started outcome with every task failed', () async {
    final runner = makeRunner(uploadFromUrl: (request) async => Left(_StubFailure()));

    final result = await runner.transfer((
      docs: [doc(downloadLink: 'https://drive.example.com/1')],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) {},
      onSuccess: (_, __) {},
      onFailure: (_) {},
    ));

    expect(result, (started: true, succeeded: 0, failed: 1));
  });

  test('Should keep two batches sharing one gate under the global limit', () async {
    var inFlight = 0;
    var maxInFlight = 0;
    final blockers = <Completer<void>>[];
    final gate = ConcurrencyGate(3);
    DriveAttachmentTransferRunner batchRunner() => makeRunner(
          gate: gate,
          uploadFromUrl: (request) async {
            inFlight++;
            maxInFlight = maxInFlight < inFlight ? inFlight : maxInFlight;
            final blocker = Completer<void>();
            blockers.add(blocker);
            await blocker.future;
            inFlight--;
            return Right(UploadDriveDocumentFromUrlSuccess(Attachment(name: request.name)));
          },
        );

    DriveTransferRequest batch() => (
          docs: List.generate(4, (_) => doc(downloadLink: 'https://drive.example.com/x')),
          accountId: accountId,
          uploadUri: uploadUri,
          onPlaceholdersReady: (_) {},
          onSuccess: (_, __) {},
          onFailure: (_) {},
        );

    // Second picker result arrives while the first batch is still transferring.
    final firstBatch = batchRunner().transfer(batch());
    final secondBatch = batchRunner().transfer(batch());

    await Future<void>.delayed(Duration.zero);
    expect(inFlight, 3);

    for (var released = 0; released < 8; released++) {
      final pending = blockers.where((blocker) => !blocker.isCompleted).toList();
      expect(pending, isNotEmpty);
      pending.first.complete();
      await Future<void>.delayed(Duration.zero);
      expect(inFlight, lessThanOrEqualTo(3));
    }
    await Future.wait([firstBatch, secondBatch]);

    expect(maxInFlight, 3);
    expect(blockers, hasLength(8));
  });

  test('Should not start the batch when onPlaceholdersReady throws', () async {
    var uploadCalls = 0;
    final runner = makeRunner(uploadFromUrl: (request) async {
      uploadCalls++;
      return Right(UploadDriveDocumentFromUrlSuccess(Attachment(name: request.name)));
    });

    final result = await runner.transfer((
      docs: [doc(downloadLink: 'https://drive.example.com/1')],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) => throw StateError('chips unavailable'),
      onSuccess: (_, __) {},
      onFailure: (_) {},
    ));

    expect(result, DriveAttachmentTransferRunner.notStartedOutcome);
    expect(uploadCalls, 0);
  });

  test('Should keep resolving siblings and reporting the outcome when onSuccess throws', () async {
    final succeededNames = <String>[];
    final runner = makeRunner(uploadFromUrl: (request) async {
      return Right(UploadDriveDocumentFromUrlSuccess(Attachment(name: request.name)));
    });

    final result = await runner.transfer((
      docs: [
        doc(downloadLink: 'https://drive.example.com/1', name: 'first.pdf'),
        doc(downloadLink: 'https://drive.example.com/2', name: 'second.pdf'),
      ],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) {},
      onSuccess: (_, attachment) {
        succeededNames.add(attachment.name ?? '');
        if (succeededNames.length == 1) throw StateError('chip update failed');
      },
      onFailure: (_) {},
    ));

    expect(succeededNames, ['first.pdf', 'second.pdf']);
    expect(result, (started: true, succeeded: 2, failed: 0));
  });

  test('Should keep resolving siblings when onFailure throws', () async {
    final failedTaskIds = <UploadTaskId>[];
    final runner = makeRunner(uploadFromUrl: (request) async => Left(_StubFailure()));

    final result = await runner.transfer((
      docs: [
        doc(downloadLink: 'https://drive.example.com/1'),
        doc(downloadLink: 'https://drive.example.com/2'),
      ],
      accountId: accountId,
      uploadUri: uploadUri,
      onPlaceholdersReady: (_) {},
      onSuccess: (_, __) {},
      onFailure: (taskId) {
        failedTaskIds.add(taskId);
        if (failedTaskIds.length == 1) throw StateError('chip removal failed');
      },
    ));

    expect(failedTaskIds, hasLength(2));
    expect(result, (started: true, succeeded: 0, failed: 2));
  });
}
