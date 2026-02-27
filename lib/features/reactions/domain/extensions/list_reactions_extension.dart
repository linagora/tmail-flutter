extension ListReactionsExtension on List<String> {
  static const int maxRecentReactionsSize = 12;

  List<String> combineRecentReactions(String emojiId) {
    final result = List<String>.from(this);

    result.removeWhere((id) => id == emojiId);
    result.insert(0, emojiId);

    if (result.length > maxRecentReactionsSize) {
      result.length = maxRecentReactionsSize;
    }

    return result;
  }
}
