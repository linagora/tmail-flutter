import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';

class DraggableEmailAddress with EquatableMixin {
  final EmailAddress emailAddress;
  final PrefixEmailAddress prefix;
  final String? composerId;

  DraggableEmailAddress({
    required this.emailAddress,
    required this.prefix,
    this.composerId,
  });

  @override
  List<Object?> get props => [emailAddress, prefix, composerId];
}