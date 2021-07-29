
import 'package:equatable/equatable.dart';

class PresentationThread with EquatableMixin {

  final String id;
  final String? message;

  PresentationThread(this.id, {this.message});

  factory PresentationThread.createThreadEmpty() {
    return PresentationThread('empty');
  }

  @override
  List<Object?> get props => [id, message];
}