
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

class ContactArguments with EquatableMixin {
  final AccountId accountId;
  final Session session;
  final Set<String> listContactSelected;
  final String? contactViewTitle;

  ContactArguments({
    required this.accountId,
    required this.session,
    required this.listContactSelected,
    this.contactViewTitle
  });

  @override
  List<Object?> get props => [
    accountId,
    session,
    listContactSelected,
    contactViewTitle,
  ];
}