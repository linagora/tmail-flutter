import 'package:core/utils/app_logger.dart';

extension StringExtension on String {

  String get firstLetterToUpperCase {
    try {
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
        final listMatch = regexLetter.allMatches(trim()).toList();
        if (listMatch.length > 1) {
          final firstLetter = listMatch[0].group(0);
          final secondLetter = listMatch[1].group(0);
          return firstLetter != null && secondLetter != null
              ? '${firstLetter.toUpperCase()}${secondLetter.toUpperCase()}'
              : '';
        } else {
          final firstLetter = substring(0, length > 1 ? 2 : 1);
          return firstLetter.toUpperCase();
        }
      }
    } catch (e) {
      logError('StringExtension::firstLetterToUpperCase(): $e');
      return '';
    }
  }

  String get firstCharacterToUpperCase => isNotEmpty ? this[0].toUpperCase() : '';
}