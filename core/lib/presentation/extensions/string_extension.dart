import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';

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

  String get fileExtension {
    int dotIndex = lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == length - 1) {
      return '';
    }
    return substring(dotIndex + 1);
  }

  String get imageMimeType {
    switch (fileExtension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'bmp':
        return 'image/bmp';
      case 'ico':
        return 'image/x-icon';
      case 'tif':
      case 'tiff':
        return 'image/tiff';
      case 'heic':
      case 'heif':
        return 'image/heif';
      case 'avif':
        return 'image/avif';
      default:
        return 'application/octet-stream'; // Unknown type
    }
  }

  List<Color> get gradientColors {
    return AppColor.mapGradientColor[_generateGradientColorIndex()];
  }

  int _generateGradientColorIndex() {
    try {
      if (isNotEmpty && codeUnits.isNotEmpty) {
        return codeUnits.sum % AppColor.mapGradientColor.length;
      } else {
        return 0;
      }
    } catch (e) {
      logError('StringExtension::_generateGradientColorIndex(): $e');
      return 0;
    }
  }
}