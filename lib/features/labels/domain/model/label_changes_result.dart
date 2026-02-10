import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:labels/model/label.dart';

class LabelChangesResult with EquatableMixin {
  final List<Label> createdLabels;
  final List<Label> updatedLabels;
  final List<Id> destroyedLabelIds;
  final State? newState;

  LabelChangesResult({
    required this.createdLabels,
    required this.updatedLabels,
    required this.destroyedLabelIds,
    required this.newState,
  });

  @override
  List<Object?> get props => [
    createdLabels,
    updatedLabels,
    destroyedLabelIds,
    newState,
  ];
}
