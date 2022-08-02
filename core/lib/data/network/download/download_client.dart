
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/data/network/dio_client.dart';
import 'package:core/data/utils/compress_file_utils.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
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
      {
        Uint8List? bytesData,
        double? maxWidth,
        bool? compress,
      }
  ) async {
    try {
      if (bytesData == null) {
        log('DownloadClient::downloadImageAsBase64(): bytesData is NULL');
        bytesData = await _dioClient.get(url, options: Options(responseType: ResponseType.bytes));
      }

      if (bytesData == null) {
        return null;
      }

      if (BuildUtils.isWeb) {
        final base64Uri = encodeToBase64Uri({
          'bytesData': bytesData,
          'mimeType': 'image/$fileExtension',
          'cid': cid,
          'fileName': fileName
        });

        return base64Uri;
      } else {
        if (compress == true) {
          final bytesDataCompressed = await _compressFileUtils.compressBytesDataImage(
              bytesData,
              maxWidth: maxWidth?.toInt());

          final base64Uri = await compute(encodeToBase64Uri, {
            'bytesData': bytesDataCompressed,
            'mimeType': 'image/$fileExtension',
            'cid': cid,
            'fileName': fileName
          });

          return base64Uri;
        }  else {
          final base64Uri = await compute(encodeToBase64Uri, {
            'bytesData': bytesData,
            'mimeType': 'image/$fileExtension',
            'cid': cid,
            'fileName': fileName
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

    final base64Data = base64Encode(bytesData);
    if (mimeType.endsWith('svg')) {
      mimeType = 'image/svg+xml';
    }
    if (!base64Data.endsWith('==')) {
      base64Data.append('==');
    }
    if (fileName.contains('.')) {
      fileName = fileName.split('.').first;
    }
    final base64Uri = '<img src="data:$mimeType;base64,$base64Data" alt="$fileName" id="cid:$cid" style="max-width: 100%" />';
    return base64Uri;
  }
}