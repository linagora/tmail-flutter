import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;
import 'package:workplace/data/model/workplace_type_defs.dart';

/// A raw-XHR upload in flight: [response] resolves with the parsed JSON
/// body, [abort] can be called any time before that to cancel the request.
class XhrUploadHandle {
  final Future<Map<String, dynamic>> response;
  final void Function() abort;

  const XhrUploadHandle({required this.response, required this.abort});
}

/// Bundles [OpfsXhrUpload.uploadFile]'s parameters to keep its argument
/// count low.
class XhrUploadFileRequest {
  final web.File file;
  final Uri uploadUri;
  final String authHeader;
  final String? mimeType;
  final OnFileProcessedProgress onUploadProgress;

  const XhrUploadFileRequest({
    required this.file,
    required this.uploadUri,
    required this.authHeader,
    required this.mimeType,
    required this.onUploadProgress,
  });
}

/// The upload leg. Raw XHR rather than Dio because only XHR can stream an
/// OPFS-backed `File` straight off disk.
mixin OpfsXhrUpload {
  /// POSTs [XhrUploadFileRequest.file] to its `uploadUri`, streaming straight
  /// off disk so it never materializes in the JS heap. Not refresh-and-retry
  /// safe: the auth header is read once, up front.
  ///
  /// Deliberately no `xhr.timeout`: it bounds the *whole* request, so any cap
  /// large enough for a slow multi-hundred-megabyte upload is too large to
  /// catch a stall — it would only kill transfers making progress. Cancelling
  /// is the caller's job, through [XhrUploadHandle.abort].
  ///
  /// Failures come out as [DioException], like `fetchStream`'s.
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    final requestOptions = RequestOptions(path: request.uploadUri.toString());
    final xhr = web.XMLHttpRequest();
    xhr.open('POST', request.uploadUri.toString());
    _applyHeaders(xhr, request);
    final completer = Completer<Map<String, dynamic>>();

    // `total` is 0 when the length is unknown, but the download leg reports an
    // unknown total as -1. Normalized here so one progress consumer doesn't
    // have to know two sentinels — and doesn't divide by zero.
    xhr.upload.onprogress = ((web.ProgressEvent event) {
      request.onUploadProgress(
        event.loaded,
        event.lengthComputable ? event.total : -1,
      );
    }).toJS;

    xhr.onload = ((web.Event _) {
      _completeFromResponse(xhr, completer, requestOptions);
    }).toJS;

    xhr.onerror = ((web.Event _) {
      _completeError(completer, DioException.connectionError(
        requestOptions: requestOptions,
        reason: 'the upload request failed',
      ));
    }).toJS;

    // An abort is only ever this package aborting on the caller's behalf.
    xhr.onabort = ((web.Event _) {
      _completeError(completer, DioException.requestCancelled(
        requestOptions: requestOptions,
        reason: 'the upload was cancelled',
      ));
    }).toJS;

    xhr.send(request.file);

    return XhrUploadHandle(
      response: completer.future,
      abort: () => xhr.abort(),
    );
  }

  void _applyHeaders(web.XMLHttpRequest xhr, XhrUploadFileRequest request) {
    xhr.setRequestHeader('Authorization', request.authHeader);
    // An OPFS-created `File` carries an empty type, so without this the
    // request would go out with no usable content type.
    final mimeType = request.mimeType;
    if (mimeType != null && mimeType.isNotEmpty) {
      xhr.setRequestHeader('Content-Type', mimeType);
    }
  }

  void _completeFromResponse(
    web.XMLHttpRequest xhr,
    Completer<Map<String, dynamic>> completer,
    RequestOptions requestOptions,
  ) {
    if (completer.isCompleted) return;
    if (xhr.status >= 200 && xhr.status < 300) {
      try {
        completer.complete(
            jsonDecode(xhr.responseText) as Map<String, dynamic>);
      } catch (e) {
        // A 2xx with an unparseable body still has to surface as a
        // DioException, per this mixin's documented failure contract.
        completer.completeError(DioException(
          type: DioExceptionType.badResponse,
          requestOptions: requestOptions,
          error: e,
          message: 'the upload response body could not be parsed',
          response: Response<void>(
            requestOptions: requestOptions,
            statusCode: xhr.status,
          ),
        ));
      }
    } else {
      completer.completeError(DioException.badResponse(
        statusCode: xhr.status,
        requestOptions: requestOptions,
        response: Response<void>(
          requestOptions: requestOptions,
          statusCode: xhr.status,
        ),
      ));
    }
  }

  void _completeError(
    Completer<Map<String, dynamic>> completer,
    DioException error,
  ) {
    if (!completer.isCompleted) {
      completer.completeError(error);
    }
  }
}
