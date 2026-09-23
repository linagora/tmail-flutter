import 'dart:io';
import 'dart:typed_data';

import 'package:core/utils/platform_info.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_request_extra.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/upload_exception.dart';

/// How a picked file's bytes reach a request — resolves [FileInfo]'s source
/// precedence once, so every consumer reads the same decision.
sealed class UploadBody {
  const UploadBody();

  /// Body for `dio.post(data:)`; null when the adapter sends the source itself.
  Object? get requestData;

  /// Extra entries the web blob adapter and the 401 replay key on.
  Map<String, dynamic> get requestExtra;

  /// The `Options.extra` shape the blob adapter and the 401 replay key on.
  Map<String, dynamic> get dioExtra =>
      <String, dynamic>{UploadRequestExtra.uploadAttachmentKey: requestExtra};

  /// Opens a fresh stream, bounded by [start]/[end], for the charset head probe.
  Stream<List<int>> open([int? start, int? end]);

  factory UploadBody.of(FileInfo fileInfo) {
    final dartOpen = _dartOpen(fileInfo);
    final sourceUrl = fileInfo.sourceUrl;
    if (sourceUrl != null) {
      return HandleUploadBody(sourceUrl, dartOpen);
    }
    if (dartOpen != null) {
      return StreamUploadBody(dartOpen);
    }
    throw const MissingAttachmentSourceException();
  }

  /// Web has no `dart:io` file system.
  static bool _hasLocalFilePath(FileInfo fileInfo) =>
      !PlatformInfo.isWeb && fileInfo.filePath?.isNotEmpty == true;

  static Stream<List<int>> Function([int?, int?])? _dartOpen(FileInfo fileInfo) {
    final openRead = fileInfo.openRead;
    if (openRead != null) return openRead;
    if (_hasLocalFilePath(fileInfo)) {
      return ([start, end]) => File(fileInfo.filePath!).openRead(start, end);
    }
    final bytes = fileInfo.bytes;
    if (bytes != null) {
      return ([start, end]) => BodyBytesStream.fromBytes(_slice(bytes, start, end));
    }
    return null;
  }

  static Uint8List _slice(Uint8List bytes, int? start, int? end) {
    if (start == null && end == null) return bytes;
    return bytes.sublist(start ?? 0, (end ?? bytes.length).clamp(0, bytes.length));
  }
}

/// Mobile file, dropped file, retained bytes, inline image — read by dio itself.
final class StreamUploadBody extends UploadBody {
  final Stream<List<int>> Function([int?, int?]) _open;

  const StreamUploadBody(this._open);

  @override
  Object? get requestData => _open();

  @override
  Map<String, dynamic> get requestExtra => <String, dynamic>{
    // Factory: a 401 replay opens a fresh body instead of reusing a drained one.
    UploadRequestExtra.openReadKey: () => _open(),
  };

  @override
  Stream<List<int>> open([int? start, int? end]) => _open(start, end);
}

/// Web's `blob:` handle — sent verbatim by the adapter, nothing buffered here.
final class HandleUploadBody extends UploadBody {
  final String sourceUrl;
  final Stream<List<int>> Function([int?, int?])? _open;

  const HandleUploadBody(this.sourceUrl, this._open);

  @override
  Object? get requestData => null;

  @override
  Map<String, dynamic> get requestExtra => <String, dynamic>{
    // Lets the blob adapter re-resolve the source on replay and recognise this request.
    UploadRequestExtra.sourceUrlKey: sourceUrl,
    if (_open != null) UploadRequestExtra.openReadKey: () => _open(),
  };

  @override
  Stream<List<int>> open([int? start, int? end]) {
    final open = _open;
    if (open == null) throw const MissingAttachmentSourceException();
    return open(start, end);
  }
}
