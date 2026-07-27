import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:core/utils/build_utils.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';

/// Streams a drive document into a temp file on disk (mobile/desktop).
/// Mirrors the pause/resume/cancel technique used in
/// `core`'s `DownloadManager.downloadFile`, against [WorkplaceDio.instance]
/// instead of the main app's authenticated Dio client — the public
/// `downloadLink` must never carry the session's auth header.
class IoDriveFileStager implements DriveFileStager {
  IoDriveFileStager({
    Dio? dio,
    Future<Directory> Function()? getTemporaryDirectory,
  })  : _dio = dio ?? WorkplaceDio.instance,
        _getTemporaryDirectory =
            getTemporaryDirectory ?? path_provider.getTemporaryDirectory;

  final Dio _dio;
  final Future<Directory> Function() _getTemporaryDirectory;

  @override
  Future<StagedDriveFile> stage({
    required DriveDocument doc,
    required void Function(int received, int total) onDownloadProgress,
    required CancelToken cancelToken,
  }) async {
    final downloadLink = doc.downloadLink;
    if (downloadLink == null) {
      throw DriveDownloadNullAttachmentException();
    }
    if (BuildUtils.isReleaseMode && !downloadLink.isScheme('https')) {
      throw DriveDownloadInsecureLinkException();
    }

    final response = await _dio.getUri<ResponseBody>(
      downloadLink,
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: driveTransferReceiveTimeout,
      ),
      cancelToken: cancelToken,
    );

    final responseBody = response.data!;
    final total = _resolveTotalSize(responseBody, doc);

    final directory = await _getTemporaryDirectory();
    // Generated, not derived from `doc.id`/`doc.name` — those are
    // server-supplied and must never be interpolated into a filesystem path.
    final file = File('${directory.path}/${_generateTempFileName()}');

    int received;
    try {
      received = await _streamToFile(_StreamToFileRequest(
        responseBody: responseBody,
        file: file,
        total: total,
        cancelToken: cancelToken,
        onDownloadProgress: onDownloadProgress,
      ));
    } catch (error) {
      // Covers both a failed `file.open()` and a failed/cancelled transfer —
      // either way nothing partially written should survive.
      await _deleteIfExists(file);
      rethrow;
    }

    return FileBackedStagedFile(
      filePath: file.path,
      deleteFile: (path) => _deleteIfExists(File(path)),
      fileName: doc.name,
      fileSize: received,
      mimeType: doc.mimeType,
    );
  }

  int _resolveTotalSize(ResponseBody responseBody, DriveDocument doc) {
    final contentLengthHeader = responseBody.headers['content-length'];
    final contentLength =
        (contentLengthHeader != null && contentLengthHeader.isNotEmpty)
            ? int.tryParse(contentLengthHeader.first)
            : null;
    return (contentLength != null && contentLength > 0)
        ? contentLength
        : doc.size;
  }

  String _generateTempFileName() {
    final random = Random();
    final suffix =
        List.generate(8, (_) => random.nextInt(16).toRadixString(16)).join();
    return 'drive_${DateTime.now().microsecondsSinceEpoch}_$suffix';
  }

  // `takeWhile` stops the subscription from consuming further chunks the
  // moment `cancelToken` flips, without waiting on Dio's own teardown of
  // the underlying HTTP stream to reach this listener. `cancelToken.whenCancel`
  // below is what actually unblocks `completer` if the stream itself never
  // emits another event (or closes) after cancellation.
  Future<int> _streamToFile(_StreamToFileRequest request) async {
    final responseBody = request.responseBody;
    final file = request.file;
    final total = request.total;
    final cancelToken = request.cancelToken;
    final onDownloadProgress = request.onDownloadProgress;

    // FileMode.write creates the file if it doesn't exist yet — no separate
    // createSync step needed, and a failure here surfaces before any bytes
    // are written.
    var randomAccessFile = await file.open(mode: FileMode.write);
    final completer = Completer<int>();
    var received = 0;
    // Guards against `onError`/`onDone`/`whenCancel` all racing to settle the
    // same subscription, which would otherwise close the already-closed
    // `RandomAccessFile` twice or complete the `completer` more than once.
    var settled = false;
    late StreamSubscription<List<int>> subscription;

    Future<void> closeQuietly() async {
      try {
        await randomAccessFile.close();
      } catch (_) {
        // Best-effort close: cleanup/completion below must still run even if
        // the underlying handle is already invalid.
      }
    }

    Future<void> abortWith(Object error) async {
      if (settled) return;
      settled = true;
      await closeQuietly();
      await _deleteIfExists(file);
      if (!completer.isCompleted) completer.completeError(error);
    }

    Future<void> finish() async {
      if (settled) return;
      settled = true;
      await closeQuietly();
      if (!completer.isCompleted) completer.complete(received);
    }

    unawaited(cancelToken.whenCancel.then(
      (_) => abortWith(cancelToken.cancelError ??
          StateError('IoDriveFileStager: transfer cancelled')),
    ));

    subscription = responseBody.stream
        .takeWhile((_) => !cancelToken.isCancelled)
        .listen(
      (chunk) {
        subscription.pause();
        randomAccessFile.writeFrom(chunk).then((updated) {
          randomAccessFile = updated;
          received += chunk.length;
          onDownloadProgress(received, total);
          subscription.resume();
        }).catchError((Object error) async {
          await subscription.cancel();
          await abortWith(error);
        });
      },
      onDone: () async {
        if (cancelToken.isCancelled) {
          await abortWith(cancelToken.cancelError ??
              StateError('IoDriveFileStager: transfer cancelled'));
        } else {
          await finish();
        }
      },
      onError: (Object error) async => abortWith(error),
    );

    return completer.future;
  }
}

Future<void> _deleteIfExists(File file) async {
  if (await file.exists()) await file.delete();
}

/// Bundles `_streamToFile`'s parameters to keep its argument count low.
class _StreamToFileRequest {
  final ResponseBody responseBody;
  final File file;
  final int total;
  final CancelToken cancelToken;
  final void Function(int received, int total) onDownloadProgress;

  const _StreamToFileRequest({
    required this.responseBody,
    required this.file,
    required this.total,
    required this.cancelToken,
    required this.onDownloadProgress,
  });
}

/// IO strategy: `FileUploader` handles the upload leg, so there's no
/// OPFS-only uploader.
class IoDriveTransferStrategy implements DriveTransferStrategy {
  @override
  final DriveFileStager stager;

  @override
  OpfsDriveFileUploader? get opfsUploader => null;

  IoDriveTransferStrategy({DriveFileStager? stager})
      : stager = stager ?? IoDriveFileStager();
}
