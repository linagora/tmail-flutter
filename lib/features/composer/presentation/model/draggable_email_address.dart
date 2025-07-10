import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';

class DraggableEmailAddress with EquatableMixin {
  final EmailAddress emailAddress;
  final FilterField filterField;
  final String? composerId;

  DraggableEmailAddress({
    required this.emailAddress,
    required this.filterField,
    this.composerId,
  });

  @override
  List<Object?> get props => [emailAddress, filterField, composerId];
}