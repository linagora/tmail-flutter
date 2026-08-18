import 'package:model/upload/upload_response.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/upload_from_url_datasource.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_from_url_api.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

class UploadFromUrlDataSourceImpl implements UploadFromUrlDataSource {
  const UploadFromUrlDataSourceImpl(this._uploadFromUrlApi, this._exceptionThrower);

  final UploadFromUrlApi _uploadFromUrlApi;
  final ExceptionThrower _exceptionThrower;

  @override
  Future<UploadResponse> uploadFromUrl(UploadFromUrlRequest request) =>
      Future.sync(() => _uploadFromUrlApi.uploadFromUrl(request))
        .catchError(_exceptionThrower.throwException);
}
