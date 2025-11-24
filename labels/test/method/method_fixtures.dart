import 'package:dio/dio.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';

Dio createDio() {
  final dio = Dio(BaseOptions(method: 'POST'))
    ..options.baseUrl = 'http://domain.com/jmap';
  return dio;
}

JmapRequestBuilder createBuilder(Dio dio) {
  return JmapRequestBuilder(
    HttpClient(dio),
    ProcessingInvocation(),
  );
}

Map<String, String> createJMAPHeader() {
  return {"accept": "application/json;jmapVersion=rfc-8621"};
}
