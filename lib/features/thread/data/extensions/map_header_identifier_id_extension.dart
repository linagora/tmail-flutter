
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';

extension MapHeaderIdentifierExtension on Map<IndividualHeaderIdentifier, String?> {

  Map<String, String?> toMapString() => Map.fromIterables(keys.map((identifier) => identifier.value), values);
}