
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

extension ListSendingEmailExtension on List<SendingEmail> {
  List<SendingEmail> toggleSelection({required SendingEmail sendingEmailSelected}) =>
    map((sendingEmail) => sendingEmailSelected.sendingId == sendingEmail.sendingId
      ? sendingEmail.toggleSelection()
      : sendingEmail
    ).toList();

  List<SendingEmail> unAllSelected() => map((sendingEmail) => sendingEmail.unSelected()).toList();

  bool isAllSelected() => every((sendingEmail) => sendingEmail.isSelected);

  bool isAllUnSelected() => every((sendingEmail) => !sendingEmail.isSelected);

  List<SendingEmail> listSelected() => where((sendingEmail) => sendingEmail.isSelected).toList();

  bool isAllSendingStateError() => every((sendingEmail) => sendingEmail.isError);

  List<SendingEmail> toSendingStateWaiting() => map((sendingEmail) => sendingEmail.updatingSendingState(SendingState.waiting)).toList();
}