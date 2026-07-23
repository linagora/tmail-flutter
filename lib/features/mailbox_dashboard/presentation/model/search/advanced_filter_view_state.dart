import 'package:equatable/equatable.dart';
import 'package:model/mailbox/expand_mode.dart';

class AdvancedFilterViewState with EquatableMixin {
  final ExpandMode fromAddressExpandMode;
  final ExpandMode toAddressExpandMode;

  const AdvancedFilterViewState({
    required this.fromAddressExpandMode,
    required this.toAddressExpandMode,
  });

  factory AdvancedFilterViewState.initial() => const AdvancedFilterViewState(
        fromAddressExpandMode: ExpandMode.EXPAND,
        toAddressExpandMode: ExpandMode.EXPAND,
      );

  AdvancedFilterViewState copyWith({
    ExpandMode? fromAddressExpandMode,
    ExpandMode? toAddressExpandMode,
  }) {
    return AdvancedFilterViewState(
      fromAddressExpandMode:
          fromAddressExpandMode ?? this.fromAddressExpandMode,
      toAddressExpandMode: toAddressExpandMode ?? this.toAddressExpandMode,
    );
  }

  @override
  List<Object?> get props => [fromAddressExpandMode, toAddressExpandMode];
}
