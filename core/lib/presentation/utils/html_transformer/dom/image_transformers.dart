
import 'dart:convert';

import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';

class ImageTransformer extends DomTransformer {

  const ImageTransformer();

  @override
  Future<void> process(
      Document document,
      String message,
      Map<String, String>? mapUrlDownloadCID,
      DioClient dioClient
  ) async {
    final imageElements = document.getElementsByTagName('img');

    await Future.wait(imageElements.map((imageElement) async {
      imageElement.attributes['style'] = 'display: inline;max-width: 100%;height: auto;';
      final src = imageElement.attributes['src'];
      if (src != null
          && src.isNotEmpty
          && src.startsWith('cid:')
          && mapUrlDownloadCID != null
      ) {
        final cid = src.replaceFirst('cid:', '').trim();
        final cidUrlDownload = mapUrlDownloadCID[cid];
        if (cidUrlDownload != null && cidUrlDownload.isNotEmpty) {
          final imgBase64 = await loadAsyncNetworkImageToBase64(dioClient, cidUrlDownload);
          if (imgBase64 != null && imgBase64.isNotEmpty) {
            imageElement.attributes['src'] = 'data:image/jpeg;base64,$imgBase64';
          }
        }
      }
    }));
  }


  Future<String?> loadAsyncNetworkImageToBase64(DioClient dioClient, String imageUrl) async {
    try {
      final response = await dioClient.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes));
      return base64Encode(response);
    } catch (e) {
      return imageUrl;
    }
  }
}