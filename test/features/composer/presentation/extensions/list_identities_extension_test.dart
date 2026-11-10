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
    test('keeps only mayDelete identities when any exist', () {
      final server = _identity(id: 'server', mayDelete: false);
      final editable = _identity(id: 'editable', mayDelete: true);
      expect([server, editable].forComposerFromPicker(), [editable]);
    });

    test('keeps the full list when every identity is a server default', () {
      final onlyServer = _identity(id: 'server', mayDelete: false);
      expect([onlyServer].forComposerFromPicker(), [onlyServer]);
    });

    test('returns empty when the list is empty', () {
      expect(<Identity>[].forComposerFromPicker(), isEmpty);
    });
  });
}
