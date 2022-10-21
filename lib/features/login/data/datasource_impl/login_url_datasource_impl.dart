import 'package:tmail_ui_user/features/caching/recent_login_url_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_url_datasource.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_url_cache.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';

class LoginUrlDataSourceImpl implements LoginUrlDataSource {
  
  final RecentLoginUrlCacheClient _recentLoginUrlCacheClient;
  
  LoginUrlDataSourceImpl(this._recentLoginUrlCacheClient);
  
  @override
  Future<void> saveLoginUrl(RecentLoginUrl recentLoginUrl) {
    return Future.sync(() async {
      if (await _recentLoginUrlCacheClient.isExistItem(recentLoginUrl.url)) {
        await _recentLoginUrlCacheClient.updateItem(
            recentLoginUrl.url,
            recentLoginUrl.toRecentLoginUrlCache());
      } else {
        await _recentLoginUrlCacheClient.insertItem(
            recentLoginUrl.url,
            recentLoginUrl.toRecentLoginUrlCache());
      }
    }).catchError((error) {
      throw error;
    });
  }
}