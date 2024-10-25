
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

enum DashboardType {
  normal,
  search;
}

class NavigationRouter with EquatableMixin {
  final EmailId? emailId;
  final MailboxId? mailboxId;
  final DashboardType dashboardType;
  final SearchQuery? searchQuery;
  final String? routeName;
  final List<EmailAddress>? listEmailAddress;
  final String? subject;
  final String? body;
  final AccountMenuItem accountMenuItem;
  final List<EmailAddress>? cc;
  final List<EmailAddress>? bcc;

  NavigationRouter({
    this.emailId,
    this.mailboxId,
    this.searchQuery,
    this.dashboardType = DashboardType.normal,
    this.routeName,
    this.listEmailAddress,
    this.subject,
    this.body,
    this.accountMenuItem = AccountMenuItem.none,
    this.cc,
    this.bcc,
  });

  factory NavigationRouter.initial() => NavigationRouter();

  @override
  List<Object?> get props => [
    emailId,
    mailboxId,
    searchQuery,
    dashboardType,
    routeName,
    listEmailAddress,
    subject,
    body,
    accountMenuItem,
    cc,
    bcc,
  ];
}