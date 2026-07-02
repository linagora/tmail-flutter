import 'package:equatable/equatable.dart';
import 'package:model/email/presentation_email.dart';

/// Result of a search: the rows to show and whether a load-more is possible.
/// Replaces the scattered `emailList` + `canLoadMore` booleans. See ADR-0093.
class SearchEmailState with EquatableMixin {
  final List<PresentationEmail> emails;
  final bool canLoadMore;

  const SearchEmailState({required this.emails, required this.canLoadMore});

  factory SearchEmailState.empty() =>
      const SearchEmailState(emails: [], canLoadMore: false);

  SearchEmailState copyWith({
    List<PresentationEmail>? emails,
    bool? canLoadMore,
  }) {
    return SearchEmailState(
      emails: emails ?? this.emails,
      canLoadMore: canLoadMore ?? this.canLoadMore,
    );
  }

  @override
  List<Object?> get props => [emails, canLoadMore];
}
