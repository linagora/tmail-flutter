
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class EmailsResponse with EquatableMixin {
  final List<Email>? emailList;
  final List<EmailId>? notFoundEmailIds;
  final State? state;

  const EmailsResponse({
    this.emailList,
    this.notFoundEmailIds,
    this.state
  });

  bool hasEmails() => emailList != null && emailList!.isNotEmpty;

  bool hasState() => state != null;

  bool get existNotFoundEmails => notFoundEmailIds?.isNotEmpty == true;

  @override
  List<Object?> get props => [emailList, notFoundEmailIds, state];
}