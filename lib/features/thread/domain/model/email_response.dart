
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';

class EmailsResponse with EquatableMixin {
  final List<Email>? emailList;
  final List<EmailId>? notFoundEmailIds;
  final State? state;
  final EmailChangeResponse? emailChangeResponse;

  const EmailsResponse({
    this.emailList,
    this.notFoundEmailIds,
    this.state,
    this.emailChangeResponse,
  });

  bool hasEmails() => emailList != null && emailList!.isNotEmpty;

  bool hasState() => state != null;

  bool get existNotFoundEmails => notFoundEmailIds?.isNotEmpty == true;

  @override
  List<Object?> get props => [
    emailList,
    notFoundEmailIds,
    state,
    emailChangeResponse,
  ];

  EmailsResponse copyWith({
    List<Email>? emailList,
    List<EmailId>? notFoundEmailIds,
    State? state,
    EmailChangeResponse? emailChangeResponse,
  }) {
    return EmailsResponse(
      emailList: emailList ?? this.emailList,
      notFoundEmailIds: notFoundEmailIds ?? this.notFoundEmailIds,
      state: state ?? this.state,
      emailChangeResponse: emailChangeResponse ?? this.emailChangeResponse,
    );
  }
}