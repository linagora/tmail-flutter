import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';

class LocalEmailDraftHelper {
  LocalEmailDraftHelper._();

  static String generateDraftLocalId({
    required String composerId,
    required AccountId accountId,
    required UserName userName,
  }) {
    return TupleKey(
      composerId,
      accountId.asString,
      userName.value,
    ).encodeKey;
  }
}