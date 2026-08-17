import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_enabled_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  bool currentState() => container.read(driveAttachmentEnabledProvider);

  void setEnabled(bool? value) =>
      container.read(driveAttachmentEnabledProvider.notifier).setEnabled(value);

  test(
    'WHEN no ecosystem has been loaded yet\n'
    'THEN drive attachment is enabled',
    () {
      expect(currentState(), isTrue);
    },
  );

  test(
    'WHEN the ecosystem explicitly disables drive attachment\n'
    'THEN it is disabled',
    () {
      setEnabled(false);

      expect(currentState(), isFalse);
    },
  );

  test(
    'WHEN the ecosystem carries no drive attachment config\n'
    'THEN it stays enabled',
    () {
      setEnabled(null);

      expect(currentState(), isTrue);
    },
  );

  test(
    'WHEN the ecosystem is cleared on reload after having disabled drive\n'
    'THEN it returns to enabled',
    () {
      setEnabled(false);
      setEnabled(null);

      expect(currentState(), isTrue);
    },
  );

  test(
    'WHEN the ecosystem explicitly enables drive attachment\n'
    'THEN it is enabled',
    () {
      setEnabled(false);
      setEnabled(true);

      expect(currentState(), isTrue);
    },
  );
}
