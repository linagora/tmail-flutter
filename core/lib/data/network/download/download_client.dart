
import 'dart:convert';
import 'dart:io';

import 'package:core/data/network/dio_client.dart';
import 'package:core/data/utils/compress_file_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DownloadClient {

  final DioClient _dioClient;
  final CompressFileUtils _compressFileUtils;

  DownloadClient(this._dioClient, this._compressFileUtils);

  Future<ResponseBody> downloadFile(
      String url,
      String basicAuth,
      CancelToken? cancelToken,
  ) async {
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.authorizationHeader] = basicAuth;
    headerParam[HttpHeaders.acceptHeader] = DioClient.jmapHeader;

    final responseBody = await _dioClient.get(
      url,
      options: Options(headers: headerParam, responseType: ResponseType.stream),
      cancelToken: cancelToken);

    return (responseBody as ResponseBody);
  }

  Future<String?> downloadImageAsBase64(
      String url,
      String cid,
      String fileExtension,
      String fileName,
      String mimeType,
      {
        String? filePath,
        double? maxWidth,
        bool? compress,
      }
  ) async {
    try {
      Uint8List? bytesData;
      if (filePath == null || filePath.isEmpty) {
        log('DownloadClient::downloadImageAsBase64(): bytesData is NULL');
        bytesData = await _dioClient.get(url, options: Options(responseType: ResponseType.bytes));
      } else {
        bytesData = await File(filePath).readAsBytes();
      }

      if (bytesData == null) {
        return null;
      }

      final imageType = mimeType == 'application/octet-stream'
        ? 'image/$fileExtension'
        : mimeType;

      if (PlatformInfo.isWeb) {
        final base64Uri = encodeToBase64Uri({
          'bytesData': bytesData,
          'mimeType': imageType,
          'cid': cid,
          'fileName': fileName,
          'maxWidth': maxWidth
        });

        return base64Uri;
      } else {
        if (compress == true) {
          final bytesDataCompressed = await _compressFileUtils.compressBytesDataImage(
              bytesData,
              maxWidth: maxWidth?.toInt());

          final base64Uri = await compute(encodeToBase64Uri, {
            'bytesData': bytesDataCompressed,
            'mimeType': imageType,
            'cid': cid,
            'fileName': fileName,
            'maxWidth': maxWidth
          });

          return base64Uri;
        }  else {
          final base64Uri = await compute(encodeToBase64Uri, {
            'bytesData': bytesData,
            'mimeType': imageType,
            'cid': cid,
            'fileName': fileName,
            'maxWidth': maxWidth
          });

          return base64Uri;
        }
      }
    } catch (e) {
      log('DownloadClient::downloadImageAsBase64(): ERROR: $e');
      return null;
    }
  }

  static String encodeToBase64Uri(Map<String, dynamic> entryParam) {
    var bytesData = entryParam['bytesData'];
    var mimeType = entryParam['mimeType'];
    final cid = entryParam['cid'];
    var fileName = entryParam['fileName'];
    var maxWidth = entryParam['maxWidth'] != null
      ? '${entryParam['maxWidth']}px'
      : '100%';
    final base64Data = base64Encode(bytesData);
    if (fileName.contains('.')) {
      fileName = fileName.split('.').first;
    }
    mimeType = HtmlUtils.validateHtmlImageResourceMimeType(mimeType);
    final base64Uri = '<img src="${HtmlUtils.convertBase64ToImageResourceData(base64Data: base64Data, mimeType: mimeType)}" alt="$fileName" style="max-width: $maxWidth;" data-mimetype="$mimeType" id="cid:$cid" />';
    return base64Uri;
  }
}