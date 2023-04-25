
import 'package:jmap_dart_client/jmap/account_id.dart';

extension AccountIdExtension on AccountId {
  String get asString => id.value;
}