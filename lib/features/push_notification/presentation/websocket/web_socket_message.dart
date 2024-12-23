import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class WebSocketMessage with EquatableMixin {
  final jmap.State newState;

  WebSocketMessage({required this.newState});

  String get id => newState.value;

  @override
  List<Object?> get props => [newState];
}