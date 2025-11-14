abstract class ReactionsRepository {
  Future<void> storeRecentReactions(List<String> recentReactions);

  Future<List<String>> getRecentReactions();
}
