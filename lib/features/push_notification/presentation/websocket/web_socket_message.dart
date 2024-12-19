import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class WebSocketMessage with EquatableMixin {
  final jmap.State newState;
  final AccountId accountId;
  final Session session;

  WebSocketMessage({
    required this.newState,
    required this.accountId,
    required this.session,
  });

  String get id => newState.value;

  @override
  List<Object?> get props => [newState, accountId, session];
}