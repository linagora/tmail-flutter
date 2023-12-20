import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

class RestoredDeletedMessageRequest with EquatableMixin {
  final Id createRequestId;
  final EmailRecoveryAction emailRecoveryAction;

  RestoredDeletedMessageRequest(this.createRequestId, this.emailRecoveryAction);

  @override
  List<Object?> get props => [
    createRequestId,
    emailRecoveryAction
  ];
}