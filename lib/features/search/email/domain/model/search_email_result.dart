import 'package:equatable/equatable.dart';
import 'package:model/email/presentation_email.dart';

/// Lifecycle of the load-more (append) operation, tracked inside the result so a
/// failed or in-flight load-more never discards the already-loaded page.
enum LoadMoreState { idle, inProgress, failure }

/// Result of a search: the rows to show, whether more can be loaded, and the
/// load-more lifecycle. Replaces the scattered `emailList` + `canLoadMore`
/// booleans previously held separately in the controllers. See ADR-0093.
class SearchEmailResult with EquatableMixin {
  final List<PresentationEmail> emails;
  final bool canLoadMore;
  final LoadMoreState loadMore;

  const SearchEmailResult({
    required this.emails,
    required this.canLoadMore,
    this.loadMore = LoadMoreState.idle,
  });

  factory SearchEmailResult.empty() =>
      const SearchEmailResult(emails: [], canLoadMore: false);

  SearchEmailResult copyWith({
    List<PresentationEmail>? emails,
    bool? canLoadMore,
    LoadMoreState? loadMore,
  }) {
    return SearchEmailResult(
      emails: emails ?? this.emails,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      loadMore: loadMore ?? this.loadMore,
    );
  }

  @override
  List<Object?> get props => [emails, canLoadMore, loadMore];
}
