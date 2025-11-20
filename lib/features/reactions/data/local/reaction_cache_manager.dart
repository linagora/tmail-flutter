import 'package:shared_preferences/shared_preferences.dart';

class ReactionsCacheManager {
  static const keyRecentReactions = 'RECENT_REACTIONS';

  final SharedPreferences _sharedPreferences;

  ReactionsCacheManager(this._sharedPreferences);

  Future<void> storeRecentReactions(List<String> recentReactions) async {
    await _sharedPreferences.setStringList(keyRecentReactions, recentReactions);
  }

  List<String>? getRecentReactions() {
    return _sharedPreferences.getStringList(keyRecentReactions);
  }
}
