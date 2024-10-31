
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class EmailsResponse with EquatableMixin {
  final List<Email>? emailList;
  final State? state;

  const EmailsResponse({
    this.emailList,
    this.state
  });

  bool hasEmails() => emailList != null && emailList!.isNotEmpty;

  bool hasState() => state != null;

  @override
  List<Object?> get props => [emailList, state];
}