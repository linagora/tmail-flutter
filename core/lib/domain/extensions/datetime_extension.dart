
extension DateTimeExtension on DateTime {

  bool isToday() {
    final now = DateTime.now();
    return now.day == this.day && now.month == this.month && now.year == this.year;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return yesterday.day == this.day && yesterday.month == this.month && yesterday.year == this.year;
  }

  bool isThisYear() {
    final now = DateTime.now();
    return now.year == this.year;
  }
}

extension DateTimeNullableExtension on DateTime? {

  String toPattern() {
    if (this != null) {
      if (this!.isToday()) {
        return 'h:mm a';
      } else if (this!.isYesterday()) {
        return 'EEE';
      } else if (this!.isThisYear()) {
        return 'MMMd';
      } else {
        return 'yMMMd';
      }
    }
    return 'yMMMd';
  }
}
