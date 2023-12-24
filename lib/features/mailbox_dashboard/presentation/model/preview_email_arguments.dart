
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class PreviewEmailArguments extends RouterArguments {

  final Session session;
  final EmailId emailId;

  PreviewEmailArguments({required this.session, required this.emailId});

  @override
  List<Object?> get props => [session, emailId];
}