
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class MailtoArguments extends RouterArguments {

  final Session session;
  final String? emailAddress;

  MailtoArguments({required this.session, this.emailAddress});

  Map<String, String?> toMapRouter() {
    return {
      'routeName': AppRoutes.mailtoURL,
      'emailAddress': emailAddress
    };
  }

  @override
  List<Object?> get props => [session, emailAddress];
}