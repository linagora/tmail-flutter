import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:core/domain/exceptions/web_session_exception.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource/identity_creator_data_source.dart';
import 'package:tmail_ui_user/features/identity_creator/data/model/identity_cache_model.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/model/identity_cache.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:universal_html/html.dart';

class LocalIdentityCreatorDataSourceImpl implements IdentityCreatorDataSource {
  LocalIdentityCreatorDataSourceImpl(this._exceptionThrower);

  final ExceptionThrower _exceptionThrower;

  static const sessionStorageKeyword = 'identityCreatorSessionStorage';

  @override
  Future<void> saveIdentityCacheOnWeb(
    AccountId accountId,
    UserName userName,
    {required IdentityCache identityCache}
  ) async {
    return Future.sync(() {
      final cacheKey = _generateTupleKey(accountId, userName);
      Map<String, String> entries = {
        cacheKey: jsonEncode(IdentityCacheModel.fromDomain(identityCache).toJson())
      };
      window.sessionStorage.addAll(entries);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
    
  @override
  Future<IdentityCache> getIdentityCacheOnWeb(
    AccountId accountId,
    UserName userName
  ) async {
    return Future.sync(() {
      final cacheKey = _generateTupleKey(accountId, userName);
      final result = window.sessionStorage.entries.firstWhereOrNull(
        (entry) => entry.key == cacheKey);
      if (result != null) {
        return IdentityCacheModel.fromJson(jsonDecode(result.value));
      } else {
        throw NotFoundInWebSessionException();
      }
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> removeIdentityCacheOnWeb() async {
    return Future.sync(() {
      window.sessionStorage.removeWhere(
        (key, value) => key.startsWith(LocalIdentityCreatorDataSourceImpl.sessionStorageKeyword));
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  String _generateTupleKey(AccountId accountId, UserName userName) {
    return TupleKey(
      LocalIdentityCreatorDataSourceImpl.sessionStorageKeyword,
      accountId.asString,
      userName.value
    ).toString();
  }
}