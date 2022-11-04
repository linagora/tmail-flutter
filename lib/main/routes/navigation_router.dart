
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

enum DashboardType {
  normal,
  search;
}

class NavigationRouter with EquatableMixin {
  final EmailId? emailId;
  final MailboxId? mailboxId;
  final DashboardType dashboardType;

  NavigationRouter({
    this.emailId,
    this.mailboxId,
    this.dashboardType = DashboardType.normal
  });

  @override
  List<Object?> get props => [emailId, mailboxId, dashboardType];
}