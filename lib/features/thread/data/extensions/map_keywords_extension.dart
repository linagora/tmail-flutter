
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';

extension MapKeywordsExtension on Map<KeyWordIdentifier, bool> {

  Map<String, bool> toMapString() => Map.fromIterables(keys.map((keyword) => keyword.value), values);

  List<KeyWordIdentifier> get enabledKeywords =>
      entries.where((e) => e.value).map((e) => e.key).toList();
}