import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

/// Transforms messages
class MessageContentTransformer {
  /// The _configuration used for the transformation
  final TransformConfiguration _configuration;
  final DioClient _dioClient;
  final HtmlEscape _htmlEscape;

  MessageContentTransformer(
    this._configuration,
    this._dioClient,
    this._htmlEscape
  );

  Future<void> _transformDocument({
    required Document document,
    Map<String, String>? mapUrlDownloadCID
  }) async {
    await Future.wait([
      ..._configuration.domTransformers.map((domTransformer) async =>
          domTransformer.process(
            document: document,
            dioClient: _dioClient,
            mapUrlDownloadCID: mapUrlDownloadCID,
          )
        )
    ]);
  }

  Future<Document> toDocument({
    required String message,
    Map<String, String>? mapUrlDownloadCID
  }) async {
    final newMessage = _configuration.textTransformers.isNotEmpty
      ? _transformMessage(message)
      : message;

    final document = parse(newMessage);

    if (_configuration.domTransformers.isNotEmpty) {
      await _transformDocument(
        document: document,
        mapUrlDownloadCID: mapUrlDownloadCID,
      );
    }

    return document;
  }

  String _transformMessage(String message) {
    for (var transformer in _configuration.textTransformers) {
      message = transformer.process(message, _htmlEscape);
    }
    return message;
  }

  String toMessage(String message) {
    return _configuration.textTransformers.isNotEmpty
      ? _transformMessage(message)
      : message;
  }
}