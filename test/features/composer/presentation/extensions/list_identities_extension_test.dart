import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_identities_extension.dart';

Identity _identity({
  required String id,
  required bool mayDelete,
  String email = 'user@example.com',
}) {
  return Identity(
    id: IdentityId(Id(id)),
    name: id,
    email: email,
    sortOrder: UnsignedInt(0),
    mayDelete: mayDelete,
  );
}

void main() {
  group('forComposerFromPicker', () {
    for (final keepServerDefaults in [true, false]) {
      test('keeps only mayDelete identities when any exist (keep server defaults: $keepServerDefaults)', () {
        final server = _identity(id: 'server', mayDelete: false);
        final editable = _identity(id: 'editable', mayDelete: true);
        expect(
          [server, editable].forComposerFromPicker(keepServerDefaults: keepServerDefaults),
          [editable],
        );
      });

      test('returns empty when the list is empty (keep server defaults: $keepServerDefaults)', () {
        expect(<Identity>[].forComposerFromPicker(keepServerDefaults: keepServerDefaults), isEmpty);
      });
    }

    test('keeps the server defaults when asked and no identity is editable', () {
      final onlyServer = _identity(id: 'server', mayDelete: false);
      expect([onlyServer].forComposerFromPicker(keepServerDefaults: true), [onlyServer]);
    });

    test('SHOULD NOT keep the server defaults unless asked', () {
      final onlyServer = _identity(id: 'server', mayDelete: false);
      expect([onlyServer].forComposerFromPicker(keepServerDefaults: false), isEmpty);
    });
  });
}
