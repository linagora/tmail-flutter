import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/email_selection_action_type_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';

extension ListEmailSelectionActionTypeExtension on List<EmailSelectionActionType> {
  List<EmailActionType> get emailActionTypes {
    return map((action) => action.toEmailActionType()).nonNulls.toList();
  }
}
