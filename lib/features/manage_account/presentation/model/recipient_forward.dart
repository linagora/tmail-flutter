
import 'package:equatable/equatable.dart';
import 'package:model/mailbox/select_mode.dart';

class RecipientForward with EquatableMixin {
  final String emailAddress;
  final SelectMode selectMode;

  RecipientForward(this.emailAddress, {this.selectMode = SelectMode.INACTIVE});

  @override
  List<Object?> get props => [emailAddress, selectMode];
}

extension RecipientForwardExtension on RecipientForward {

  RecipientForward toggleSelection() {
    return RecipientForward(
      emailAddress,
      selectMode: selectMode == SelectMode.ACTIVE
          ? SelectMode.INACTIVE
          : SelectMode.ACTIVE
    );
  }

  RecipientForward cancelSelection() {
    return RecipientForward(emailAddress, selectMode: SelectMode.INACTIVE);
  }

  RecipientForward enableSelection() {
    return RecipientForward(emailAddress, selectMode: SelectMode.ACTIVE);
  }
}

extension ListRecipientForwardExtension on List<RecipientForward> {

  Set<String> get listEmailAddress =>
      map((recipient) => recipient.emailAddress).toSet();
}