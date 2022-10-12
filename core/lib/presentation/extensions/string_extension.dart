
extension StringExtension on String {

  String get firstLetterToUpperCase {
    final listWord = split(' ');
    if (listWord.length > 1) {
      final regexLetter = RegExp("([A-Za-z])");
      final firstLetterOfFirstWord = regexLetter.firstMatch(listWord[0].trim())?.group(0);
      final firstLetterOfSecondWord = regexLetter.firstMatch(listWord[1].trim())?.group(0);

      if (firstLetterOfFirstWord != null && firstLetterOfSecondWord != null) {
        return '${firstLetterOfFirstWord.toUpperCase()}${firstLetterOfSecondWord.toUpperCase()}';
      } else if (firstLetterOfFirstWord != null && firstLetterOfSecondWord == null) {
        return '${firstLetterOfFirstWord.toUpperCase()}${firstLetterOfFirstWord.toUpperCase()}';
      } else if (firstLetterOfFirstWord == null && firstLetterOfSecondWord != null) {
        return '${firstLetterOfSecondWord.toUpperCase()}${firstLetterOfSecondWord.toUpperCase()}';
      } else {
        return '';
      }
    } else {
      final regexLetter = RegExp("([A-Za-z])");
      final firstLetter = regexLetter.firstMatch(trim())?.group(0);
      return firstLetter != null ? '${firstLetter.toUpperCase()}${firstLetter.toUpperCase()}' : '';
    }
  }
}