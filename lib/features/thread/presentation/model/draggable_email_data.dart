
import 'package:equatable/equatable.dart';
import 'package:model/email/presentation_email.dart';

class DraggableEmailData with EquatableMixin {
  final List<PresentationEmail>? listEmails;
  final bool isSelectAllEmailsEnabled;

  DraggableEmailData({
    this.isSelectAllEmailsEnabled = false,
    this.listEmails,
  });

  factory DraggableEmailData.withSelectAllEmails() =>
      DraggableEmailData(isSelectAllEmailsEnabled: true);

  @override
  List<Object?> get props => [
     listEmails,
     isSelectAllEmailsEnabled,
  ];
}