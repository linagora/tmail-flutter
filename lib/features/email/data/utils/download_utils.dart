import 'package:core/data/constants/constant.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:uri/uri.dart';
import 'package:uuid/uuid.dart';

class DownloadUtils {
  static const String accountIdProperty = 'accountId';
  static const String blobIdProperty = 'blobId';
  static const String nameProperty = 'name';
  static const String typeProperty = 'type';

  final Uuid _uuid;

  DownloadUtils(this._uuid);

  String getDownloadUrl({
    required String baseDownloadUrl,
    required AccountId accountId,
    required Id blobId,
    String? fileName,
    String? mimeType,
  }) {
    final downloadUriTemplate = UriTemplate(baseDownloadUrl);
    final downloadUri = downloadUriTemplate.expand({
      accountIdProperty : accountId.asString,
      blobIdProperty : blobId.value,
      nameProperty : fileName ?? '',
      typeProperty : mimeType ?? '',
    });
    final downloadUriDecoded = Uri.decodeFull(downloadUri);
    log('DownloadUtils::getDownloadUrl: $downloadUriDecoded');
    return downloadUriDecoded;
  }

  String getEMLDownloadUrl({
    required String baseDownloadUrl,
    required AccountId accountId,
    required Id blobId,
    required String subject,
  }) {
    final fileName = createEMLFileName(subject);

    final downloadUrl = getDownloadUrl(
      baseDownloadUrl: baseDownloadUrl,
      accountId: accountId,
      blobId: blobId,
      fileName: fileName,
      mimeType: Constant.octetStreamMimeType
    );
    log('DownloadUtils::getEMLDownloadUrl: $downloadUrl');
    return downloadUrl;
  }

  String createEMLFileName(String subject) {
    return subject.isEmpty ? '${_uuid.v1()}.eml' : '$subject.eml';
  }
}