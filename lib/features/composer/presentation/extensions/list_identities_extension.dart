
import 'package:jmap_dart_client/jmap/identities/identity.dart';

extension ListIdentitiesExtension on List<Identity> {

  List<Identity> toListMayDeleted() => where((identity) => identity.mayDelete == true).toList();

  /// Composer From: prefer editable identities. Fall back to server defaults
  /// when a mailbox (often delegated) only has `mayDelete: false` rows.
  List<Identity> forComposerFromPicker() {
    final deletable = toListMayDeleted();
    return deletable.isNotEmpty ? deletable : this;
  }
}