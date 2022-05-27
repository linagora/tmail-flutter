
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

class ManageAccountArguments with EquatableMixin {

  final Session? session;

  ManageAccountArguments(this.session);

  @override
  List<Object?> get props => [session];
}