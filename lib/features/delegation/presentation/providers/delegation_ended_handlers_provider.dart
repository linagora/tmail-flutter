import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/delegation_ended_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/composer_delegation_ended_handler.dart';

/// Every feature that keeps work of an ended delegation registers its handler here.
final delegationEndedHandlersProvider = Provider<List<DelegationEndedHandler>>(
  (ref) => const [ComposerDelegationEndedHandler()],
);
