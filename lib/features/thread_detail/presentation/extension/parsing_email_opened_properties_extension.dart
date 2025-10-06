import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension ParsingEmailOpenedPropertiesExtension on ThreadDetailController {
  List<Attachment> get currentAttachmentsList =>
      currentEmailLoaded.value?.attachments ?? [];

  bool get isEmailExpandedHasAttachments =>
      currentAttachmentsList.isNotEmpty == true;
}
