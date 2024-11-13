
extension ListDateTimeExtension on List<DateTime> {

  bool isSortedByMostRecent() {
    for (int i = 0; i < length - 1; i++) {
      if (this[i].isBefore(this[i + 1])) {
        return false;
      }
    }
    return true;
  }

  bool isSortedByOldestFirst() {
    for (int i = 0; i < length - 1; i++) {
      if (this[i].isAfter(this[i + 1])) {
        return false;
      }
    }
    return true;
  }
}