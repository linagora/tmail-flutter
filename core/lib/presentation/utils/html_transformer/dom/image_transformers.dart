
import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/data/utils/compress_file_utils.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';

class ImageTransformer extends DomTransformer {

  const ImageTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final imageElements = document.querySelectorAll('img');

      if (imageElements.isEmpty) return;

      await Future.wait(imageElements.map((imageElement) async {
        final src = imageElement.attributes['src'];

        if (src == null) return;

        final id = imageElement.attributes['id'] ?? '';
        final mimeType = imageElement.attributes['data-mimetype'];
        if (src.startsWith('cid:') && mapUrlDownloadCID != null) {
          final imageBase64 = await _convertCidToBase64Image(
            dioClient: dioClient,
            mapUrlDownloadCID: mapUrlDownloadCID,
            imageSource: src,
            mimeType: mimeType,
          );
          imageElement.attributes['src'] = imageBase64 ?? src;

          if (!id.startsWith('cid:')) {
            imageElement.attributes['id'] = src;
          }
        } else if (src.startsWith('https://') || src.startsWith('http://')) {
          if (!imageElement.attributes.containsKey('loading')) {
            imageElement.attributes['loading'] = 'lazy';
          }
        }
      }));
    } catch (e) {
      logError('$runtimeType::process:Exception = $e');
    }
  }

  Future<String?> _convertCidToBase64Image({
    required DioClient dioClient,
    required Map<String, String> mapUrlDownloadCID,
    required String imageSource,
    required String? mimeType,
  }) async {
    final cid = imageSource.replaceFirst('cid:', '').trim();
    final urlDownloadCid = mapUrlDownloadCID[cid];

    if (urlDownloadCid == null || urlDownloadCid.isEmpty) return null;

    final compressFileUtils = CompressFileUtils();
    final imgBase64Uri = await loadAsyncNetworkImageToBase64(
      dioClient,
      compressFileUtils,
      urlDownloadCid,
      mimeType,
    );

    if (imgBase64Uri.isEmpty) return null;

    return imgBase64Uri;
  }

  Future<String> loadAsyncNetworkImageToBase64(
      DioClient dioClient,
      CompressFileUtils compressFileUtils,
      String imageUrl,
      String? mimeType,
  ) async {
    try {
      var responseData = await dioClient.get(
          imageUrl,
          options: Options(responseType: ResponseType.bytes));

      if (responseData != null) {
        if (PlatformInfo.isWeb) {
          return encodeToBase64Uri({
            'bytesData': responseData,
            'mimeType': mimeType,
          });
        } else {
          final bytesCompressed = await compressFileUtils.compressBytesDataImage(responseData);
          final base64Uri = await compute(encodeToBase64Uri, {
            'bytesData': bytesCompressed,
            'mimeType': mimeType,
          });
          return base64Uri;
        }
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  static String encodeToBase64Uri(Map<String, dynamic> entryParam) {
    final base64Data = base64Encode(entryParam['bytesData']);
    if (!base64Data.endsWith('==')) {
      base64Data.append('==');
    }
    final mimeType = entryParam['mimeType'] ?? 'image/jpeg';
    return 'data:$mimeType;base64,$base64Data';
  }
}