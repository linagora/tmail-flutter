import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:labels/model/label.dart';

class LabelChangeResponse with EquatableMixin {
  final List<Label>? updated;
  final List<Label>? created;
  final List<Id>? destroyed;
  final State? newStateLabel;
  final State? newStateChanges;
  final bool hasMoreChanges;

  LabelChangeResponse({
    this.updated,
    this.created,
    this.destroyed,
    this.newStateLabel,
    this.newStateChanges,
    this.hasMoreChanges = false,
  });

  @override
  List<Object?> get props => [
        updated,
        created,
        destroyed,
        newStateLabel,
        newStateChanges,
        hasMoreChanges,
      ];
}
