import 'package:equatable/equatable.dart';
import 'package:model/email/presentation_email.dart';

/// Lifecycle of the load-more (append) operation, tracked inside the result so a
/// failed or in-flight load-more never discards the already-loaded page.
enum LoadMoreState { idle, inProgress, failure }

/// Result of a search: the rows to show, whether more can be loaded, and the
/// load-more lifecycle. Replaces the scattered `emailList` + `canLoadMore`
/// booleans previously held separately in the controllers. See ADR-0093.
class SearchEmailResult with EquatableMixin {
  /// Sentinel letting `copyWith` tell "keep the current exception" apart from an
  /// explicit `null` (clear it), since `null` is a valid value for the field.
  static const Object _keepPendingException = Object();

  final List<PresentationEmail> emails;
  final bool canLoadMore;
  final LoadMoreState loadMore;

  /// Transient failure from a background op (load-more or refresh) that preserves
  /// the list, carried for the controller to route (ADR-0103) and cleared on the
  /// next operation.
  final Object? pendingUrgentException;

  const SearchEmailResult({
    required this.emails,
    required this.canLoadMore,
    this.loadMore = LoadMoreState.idle,
    this.pendingUrgentException,
  });

  factory SearchEmailResult.empty() =>
      const SearchEmailResult(emails: [], canLoadMore: false);

  SearchEmailResult copyWith({
    List<PresentationEmail>? emails,
    bool? canLoadMore,
    LoadMoreState? loadMore,
    Object? pendingUrgentException = _keepPendingException,
  }) {
    return SearchEmailResult(
      emails: emails ?? this.emails,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      loadMore: loadMore ?? this.loadMore,
      pendingUrgentException:
          identical(pendingUrgentException, _keepPendingException)
              ? this.pendingUrgentException
              : pendingUrgentException,
    );
  }

  @override
  List<Object?> get props => [emails, canLoadMore, loadMore];
}
