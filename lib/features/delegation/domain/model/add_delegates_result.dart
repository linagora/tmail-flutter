import 'package:delegation/model/delegate.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';

class AddDelegatesResult with EquatableMixin {
  final List<String> addedUsernames;
  final Map<String, SetError?> rejectedUsernames;

  /// The list re-read in the same request, null when that read failed (list is stale, retry only re-reads).
  final List<Delegate>? delegates;

  AddDelegatesResult({
    required this.addedUsernames,
    required this.rejectedUsernames,
    this.delegates,
  });

  @override
  List<Object?> get props => [addedUsernames, rejectedUsernames, delegates];
}
