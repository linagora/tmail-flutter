import 'package:tmail_ui_user/features/login/data/datasource/login_datasource.dart';
import 'package:tmail_ui_user/features/login/data/network/dns_lookup/dns_lookup_manager.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';
import 'package:tmail_ui_user/features/login/domain/model/dns_lookup_result.dart';

class LoginDataSourceImpl implements LoginDataSource {
  
  final DnsLookupManager _dnsLookupManager;
  final ExceptionThrower _exceptionThrower;

  LoginDataSourceImpl(
    this._dnsLookupManager,
    this._exceptionThrower
  );

  @override
  Future<DnsLookupResult> dnsLookupToGetJmapUrl(String emailAddress) {
    return Future.sync(() async {
      return await _dnsLookupManager.lookupJmapTarget(emailAddress);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<RecentLoginUrl>> getAllRecentLoginUrlLatest({int? limit, String? pattern}) {
    throw UnimplementedError();
  }

  @override
  Future<List<RecentLoginUsername>> getAllRecentLoginUsernamesLatest({int? limit, String? pattern}) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveLoginUrl(RecentLoginUrl baseUrl) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveLoginUsername(RecentLoginUsername username) {
    throw UnimplementedError();
  }
}