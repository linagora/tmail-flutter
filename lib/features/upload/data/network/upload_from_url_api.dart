import 'package:core/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:model/upload/upload_response.dart';
import 'package:tmail_ui_user/features/upload/data/extensions/upload_from_url_request_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';

class UploadFromUrlApi {
  final DioClient _dioClient;

  const UploadFromUrlApi(this._dioClient);

  Future<UploadResponse> uploadFromUrl(UploadFromUrlRequest request) async {
    // Empty body: BE reads the source URL/mime type from headers (see uploadHeaders).
    final responseJson = await _dioClient.post(
      request.uploadUri.toString(),
      options: Options(headers: request.uploadHeaders),
      cancelToken: request.cancelToken,
    );
    return UploadResponse.fromJson(responseJson);
  }
}
