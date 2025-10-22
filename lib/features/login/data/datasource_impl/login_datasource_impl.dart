import 'package:tmail_ui_user/features/login/data/datasource/login_datasource.dart';
import 'package:tmail_ui_user/features/login/data/network/dns_service.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class LoginDataSourceImpl implements LoginDataSource {
  
  final DNSService _dnsService;
  final ExceptionThrower _exceptionThrower;

  LoginDataSourceImpl(
    this._dnsService,
    this._exceptionThrower
  );

  @override
  Future<String> dnsLookupToGetJmapUrl(String emailAddress) {
    return Future.sync(() async {
      return await _dnsService.getJmapUrl(emailAddress);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
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