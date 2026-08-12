import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Result of `OpfsFetchDownload.openDownload`: a locked reader plus the
/// declared content-length (-1 when the header is absent/unparseable, the
/// same unknown-total sentinel Dio's `onReceiveProgress` uses).
class FetchDownloadHandle {
  final web.ReadableStreamDefaultReader reader;
  final int contentLength;

  const FetchDownloadHandle({required this.reader, required this.contentLength});
}

/// Reading a drive document off the network one chunk at a time. No OPFS in
/// it — the stager pairs this with an `OpfsStore` to decide where the bytes
/// land.
abstract interface class DriveDownloadSource {
  Future<FetchDownloadHandle> openDownload(Uri url, {Future<void>? cancelSignal});

  Future<Uint8List?> readChunk(web.ReadableStreamDefaultReader reader);

  Future<void> cancelReader(web.ReadableStreamDefaultReader reader);

  void releaseReaderLock(web.ReadableStreamDefaultReader reader);
}
