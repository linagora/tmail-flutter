import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';

extension MapKeywordsExtension on Map<KeyWordIdentifier, bool>? {
  Map<String, bool> toMapString() => Map.fromIterables(
        this?.keys.map((keyword) => keyword.value) ?? {},
        this?.values ?? [],
      );

  List<KeyWordIdentifier> get enabledKeywords =>
      this?.entries.where((e) => e.value).map((e) => e.key).toList() ?? [];

  Map<KeyWordIdentifier, bool> withKeyword(KeyWordIdentifier keyword) {
    return Map<KeyWordIdentifier, bool>.from(this ?? {})..[keyword] = true;
  }

  Map<KeyWordIdentifier, bool> withoutKeyword(KeyWordIdentifier keyword) {
    return Map<KeyWordIdentifier, bool>.from(this ?? {})..remove(keyword);
  }
}
