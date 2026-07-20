import 'package:equatable/equatable.dart';

/// Tracks independent simple/advanced search activation.
/// Advanced also drives icon state; simple keeps [isRunning] true.
class SearchActivationState with EquatableMixin {
  final bool simpleIsActivated;
  final bool advancedIsActivated;

  const SearchActivationState({
    required this.simpleIsActivated,
    required this.advancedIsActivated,
  });

  factory SearchActivationState.initial() => const SearchActivationState(
    simpleIsActivated: false,
    advancedIsActivated: false,
  );

  bool get isRunning => simpleIsActivated || advancedIsActivated;

  SearchActivationState copyWith({
    bool? simpleIsActivated,
    bool? advancedIsActivated,
  }) {
    return SearchActivationState(
      simpleIsActivated: simpleIsActivated ?? this.simpleIsActivated,
      advancedIsActivated: advancedIsActivated ?? this.advancedIsActivated,
    );
  }

  @override
  List<Object?> get props => [simpleIsActivated, advancedIsActivated];
}
