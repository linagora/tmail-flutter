import 'package:core/presentation/state/success.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';

class MailViewShortcutActionViewEvent extends ViewEvent {
  final EmailActionType actionType;
  final PresentationEmail presentationEmail;

  MailViewShortcutActionViewEvent(this.actionType, this.presentationEmail);

  @override
  List<Object?> get props => [actionType, presentationEmail];
}