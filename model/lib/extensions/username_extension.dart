
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';

extension UsernameExtension on UserName {
  String get firstCharacter => value.firstLetterToUpperCase.toUpperCase();
}