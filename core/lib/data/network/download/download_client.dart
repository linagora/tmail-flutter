
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';

class DownloadClient {

  final DioClient _dioClient;

  DownloadClient(this._dioClient);

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

  Future<String?> downloadImageAsBase64(String url) async {
    try {
      final response = await _dioClient.get(
          url,
          options: Options(responseType: ResponseType.bytes));
      return base64Encode(response);
    } catch (e) {
      return url;
    }
  }
}