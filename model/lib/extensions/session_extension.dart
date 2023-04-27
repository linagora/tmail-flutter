
import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/capability/empty_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/error_type_handler/account_exception.dart';
import 'package:model/model.dart';
import 'package:uri/uri.dart';

extension SessionExtension on Session {

  String getDownloadUrl({String? jmapUrl}) {
    final downloadUrlValid = jmapUrl != null
      ? downloadUrl.toQualifiedUrl(baseUrl: Uri.parse(jmapUrl))
      : downloadUrl;
    log('SessionExtension::getDownloadUrl():downloadUrlValid: $downloadUrlValid');
    var baseUrl = '${downloadUrlValid.origin}${downloadUrlValid.path}?${downloadUrlValid.query}';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    log('SessionExtension::getDownloadUrl(): $baseUrl');
    final downloadUrlDecode = Uri.decodeFull(baseUrl);
    log('SessionExtension::getDownloadUrl(): DECODE $downloadUrlDecode');
    return downloadUrlDecode;
  }

  Uri getUploadUri(AccountId accountId, {String? jmapUrl}) {
    final uploadUrlValid = jmapUrl != null
      ? uploadUrl.toQualifiedUrl(baseUrl: Uri.parse(jmapUrl))
      : uploadUrl;
    log('SessionExtension::getUploadUri():downloadUrlValid: $uploadUrlValid');
    final baseUrl = '${uploadUrlValid.origin}${uploadUrlValid.path}';
    final uploadUriTemplate = UriTemplate(Uri.decodeFull(baseUrl));
    final uploadUri = uploadUriTemplate.expand({
      'accountId' : accountId.id.value
    });
    log('SessionExtension::getUploadUri(): uploadUri: $uploadUri');
    return Uri.parse(uploadUri);
  }

  T getCapabilityProperties<T extends CapabilityProperties>(
    AccountId accountId,
    CapabilityIdentifier identifier
  ) {
    var capability = accounts[accountId]!.accountCapabilities[identifier];
    if (capability is EmptyCapability) {
      capability = capabilities[identifier] as T;
    }
    return (capability as T);
  }

  JmapAccount get personalAccount {
    if (accounts.isNotEmpty) {
      final listPersonalAccount = accounts.entries
        .map((entry) => entry.value.toJmapAccount(entry.key))
        .where((jmapAccount) => jmapAccount.isPersonal)
        .toList();

      if (listPersonalAccount.isNotEmpty) {
        return listPersonalAccount.first;
      }
    }
    throw NotFoundPersonalAccountException();
  }
}