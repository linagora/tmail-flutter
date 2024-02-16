
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class MailtoArguments extends RouterArguments {

  final Session session;
  final String? mailtoUri;

  MailtoArguments({required this.session, this.mailtoUri});

  Map<String, dynamic> toMapRouter() => RouteUtils.parseMapMailtoFromUri(mailtoUri);

  @override
  List<Object?> get props => [session, mailtoUri];
}