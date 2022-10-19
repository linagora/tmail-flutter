
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mdn/mdn.dart';

class SendReceiptToSenderRequest with EquatableMixin {

  final MDN mdn;
  final IdentityId identityId;
  final Id sendId;

  SendReceiptToSenderRequest({
    required this.mdn,
    required this.identityId,
    required this.sendId
  });

  @override
  List<Object?> get props => [mdn, identityId, sendId];
}