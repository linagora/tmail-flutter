import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/file_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_request_extra.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';

import 'file_uploader_blob_extra_test.mocks.dart';

/// A `FileBlobInfo.sourceUrl` is the marker the web blob adapter looks for.
/// `FileUploader` itself never touches a browser API — it only has to hand
/// the marker to dio and stop building a byte body when one is present. That
/// plumbing is what this file checks; the adapter's actual `xhr.send(blob)`
/// needs a real browser and is verified manually (see the ADR-0111 plan).
@GenerateNiceMocks([MockSpec<DioClient>()])
void main() {
  const uploadJsonResponse = {
    'accountId': 'account-id',
    'blobId': 'blob-id',
    'type': 'application/pdf',
    'size': 42,
  };

  late MockDioClient dioClient;
  late FileUploader uploader;

  setUp(() {
    dioClient = MockDioClient();
    when(dioClient.getHeaders()).thenReturn(<String, dynamic>{});
    when(dioClient.post(
      any,
      data: anyNamed('data'),
      options: anyNamed('options'),
      cancelToken: anyNamed('cancelToken'),
      onSendProgress: anyNamed('onSendProgress'),
    )).thenAnswer((_) async => jsonEncode(uploadJsonResponse));
    uploader = FileUploader(dioClient, FileUtils());
  });

  // Mockito's `verify` consumes the recorded call, so both the body and the
  // extra have to come out of one capture, not two separate verifications.
  (dynamic data, Map<String, dynamic> extra) capturePostCall() {
    final captured = verify(dioClient.post(
      any,
      data: captureAnyNamed('data'),
      options: captureAnyNamed('options'),
      cancelToken: anyNamed('cancelToken'),
      onSendProgress: anyNamed('onSendProgress'),
    )).captured;
    return (captured[0], (captured[1] as Options).extra!);
  }

  test('a FileBlobInfo sends no body and carries the URL in extra', () async {
    final fileInfo = FileBlobInfo(
      fileName: 'attachment.pdf',
      fileSize: 42,
      sourceUrl: 'blob:https://example.com/deadbeef-0000',
      openRead: ([start, end]) => const Stream<List<int>>.empty(),
    );

    await uploader.uploadAttachment(
      const UploadTaskId('upload-1'),
      fileInfo,
      Uri.parse('http://localhost/upload/account-id'),
    );

    final (data, extra) = capturePostCall();
    expect(data, isNull);

    final uploadExtra = extra[UploadRequestExtra.uploadAttachmentKey] as Map;
    expect(
      uploadExtra[UploadRequestExtra.sourceUrlKey],
      'blob:https://example.com/deadbeef-0000',
    );
  });

  test('a FileBytesInfo still sends its bytes as a stream', () async {
    final fileInfo = FileBytesInfo(
      fileName: 'attachment.pdf',
      fileSize: 4,
      bytes: Uint8List.fromList([1, 2, 3, 4]),
    );

    await uploader.uploadAttachment(
      const UploadTaskId('upload-2'),
      fileInfo,
      Uri.parse('http://localhost/upload/account-id'),
    );

    final (data, extra) = capturePostCall();
    expect(data, isA<Stream<List<int>>>());

    final uploadExtra = extra[UploadRequestExtra.uploadAttachmentKey] as Map;
    expect(uploadExtra.containsKey(UploadRequestExtra.sourceUrlKey), isFalse);
  });
}
