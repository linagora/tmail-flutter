
import 'package:core/presentation/extensions/uri_extension.dart';
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
    var baseUrl = '${downloadUrlValid.origin}${downloadUrlValid.path}?${downloadUrlValid.query}';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    final downloadUrlDecode = Uri.decodeFull(baseUrl);
    return downloadUrlDecode;
  }

  Uri getUploadUri(AccountId accountId, {String? jmapUrl}) {
    final uploadUrlValid = jmapUrl != null
      ? uploadUrl.toQualifiedUrl(baseUrl: Uri.parse(jmapUrl))
      : uploadUrl;
    final baseUrl = '${uploadUrlValid.origin}${uploadUrlValid.path}';
    final uploadUriTemplate = UriTemplate(Uri.decodeFull(baseUrl));
    final uploadUri = uploadUriTemplate.expand({
      'accountId' : accountId.id.value
    });
    return Uri.parse(uploadUri);
  }

  T? getCapabilityProperties<T extends CapabilityProperties>(
    AccountId accountId,
    CapabilityIdentifier identifier
  ) {
    var capability = accounts[accountId]?.accountCapabilities[identifier];
    if (capability == null || capability is EmptyCapability) {
      capability = capabilities[identifier];
    }
    if (capability is T) {
      return capability;
    } else {
      return null;
    }
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