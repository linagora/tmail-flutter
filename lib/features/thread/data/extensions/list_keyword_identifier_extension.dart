import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';

extension ListKeywordIdentifierExtension on List<KeyWordIdentifier> {
  List<String> get keywordListString =>
      map((identifier) => identifier.value).toList();
}
