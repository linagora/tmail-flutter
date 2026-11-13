
import 'package:jmap_dart_client/jmap/identities/identity.dart';

extension ListIdentitiesExtension on List<Identity> {

  List<Identity> toListMayDeleted() => where((identity) => identity.mayDelete == true).toList();

  /// Composer From: editable identities, or with [keepServerDefaults] the whole list when none is editable.
  List<Identity> forComposerFromPicker({required bool keepServerDefaults}) {
    final deletable = toListMayDeleted();
    return deletable.isEmpty && keepServerDefaults ? this : deletable;
  }
}