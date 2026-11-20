import 'package:delegation/model/delegate.dart';
import 'package:equatable/equatable.dart';

class RemoveDelegateResult with EquatableMixin {
  final Delegate removedDelegate;

  /// The list re-read in the same request, null when that read failed (list is stale, retry only re-reads).
  final List<Delegate>? delegates;

  RemoveDelegateResult({
    required this.removedDelegate,
    this.delegates,
  });

  @override
  List<Object?> get props => [removedDelegate, delegates];
}
