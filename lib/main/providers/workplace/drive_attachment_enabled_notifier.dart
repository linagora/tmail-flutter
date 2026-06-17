import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drive_attachment_enabled_notifier.g.dart';

@Riverpod(keepAlive: true)
class DriveAttachmentEnabledNotifier extends _$DriveAttachmentEnabledNotifier {
  @override
  bool build() => true;

  void setEnabled(bool? value) => state = value ?? true;
}
