abstract class ReactionsDatasource {
  Future<void> storeRecentReactions(List<String> recentReactions);

  Future<List<String>> getRecentReactions();
}
