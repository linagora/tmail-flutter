
import 'dart:convert';

import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';

class ImageTransformer extends DomTransformer {

  const ImageTransformer();

  @override
  Future<void> process(
      Document document,
      String message,
      {
        Map<String, String>? mapUrlDownloadCID,
        DioClient? dioClient
      }
  ) async {
    final compressFileUtils = CompressFileUtils();
    final imageElements = document.querySelectorAll('img[src^="cid:"]');
    log('ImageTransformer::process(): imageElements: ${imageElements.length}');
    await Future.wait(imageElements.map((imageElement) async {
      imageElement.attributes['style'] = 'display: inline;max-width: 100%;height: auto;';
      final src = imageElement.attributes['src'];
      log('ImageTransformer::process(): src: $src');
      final cid = src?.replaceFirst('cid:', '').trim();
      final urlDownloadCid = mapUrlDownloadCID?[cid];
      log('ImageTransformer::process(): urlDownloadCid: $urlDownloadCid');
      if (urlDownloadCid?.isNotEmpty == true && dioClient != null) {
        final imgBase64Uri = await loadAsyncNetworkImageToBase64(
            dioClient,
            compressFileUtils,
            urlDownloadCid!);
        if (imgBase64Uri.isNotEmpty) {
          imageElement.attributes['src'] = imgBase64Uri;
        }
      }
    }));
  }

  Future<String> loadAsyncNetworkImageToBase64(
      DioClient dioClient,
      CompressFileUtils compressFileUtils,
      String imageUrl
  ) async {
    try {
      var responseData = await dioClient.get(
          imageUrl,
          options: Options(responseType: ResponseType.bytes));

      if (responseData != null) {
        if (BuildUtils.isWeb) {
          return encodeToBase64Uri(responseData);
        } else {
          final bytesCompressed = await compressFileUtils.compressBytesDataImage(responseData);
          final base64Uri = await compute(encodeToBase64Uri, bytesCompressed);
          return base64Uri;
        }
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  static String encodeToBase64Uri(dynamic bytesData) {
    final base64Data = base64Encode(bytesData);
    if (!base64Data.endsWith('==')) {
      base64Data.append('==');
    }
    final base64Uri = 'data:image/jpeg;base64,$base64Data';
    return base64Uri;
  }
}