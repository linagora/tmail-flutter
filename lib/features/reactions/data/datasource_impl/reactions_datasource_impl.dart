import 'package:tmail_ui_user/features/reactions/data/datasource/reactions_datasource.dart';
import 'package:tmail_ui_user/features/reactions/data/local/reaction_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class ReactionsDatasourceImpl implements ReactionsDatasource {
  final ReactionsCacheManager _reactionCacheManager;
  final ExceptionThrower _exceptionThrower;

  ReactionsDatasourceImpl(this._reactionCacheManager, this._exceptionThrower);

  @override
  Future<List<String>> getRecentReactions() async {
    return Future.sync(() {
      return _reactionCacheManager.getRecentReactions() ?? <String>[];
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> storeRecentReactions(List<String> recentReactions) {
    return Future.sync(() async {
      return await _reactionCacheManager.storeRecentReactions(recentReactions);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}
