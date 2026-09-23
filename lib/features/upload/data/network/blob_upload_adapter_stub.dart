import 'package:dio/dio.dart';

/// Non-web platforms already stream an upload straight to the socket, so
/// there is nothing here to override.
void installBlobUploadAdapter(Dio dio) {}
