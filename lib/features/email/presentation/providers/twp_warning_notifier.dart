import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/twp_warning.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'twp_warning_notifier.g.dart';

const String twpWarningDismissedKeywordPrefix = 'twp-warning-dismissed-';

class TwpWarningState with EquatableMixin {
  final EmailId? emailId;
  final List<TwpWarning> warnings;
  final Set<String> dismissedKeywords;

  const TwpWarningState({
    this.emailId,
    this.warnings = const [],
    this.dismissedKeywords = const {},
  });

  TwpWarningState copyWith({
    EmailId? emailId,
    List<TwpWarning>? warnings,
    Set<String>? dismissedKeywords,
  }) {
    return TwpWarningState(
      emailId: emailId ?? this.emailId,
      warnings: warnings ?? this.warnings,
      dismissedKeywords: dismissedKeywords ?? this.dismissedKeywords,
    );
  }

  @override
  List<Object?> get props => [emailId, warnings, dismissedKeywords];
}

@riverpod
class TwpWarningNotifier extends _$TwpWarningNotifier {
  @override
  TwpWarningState build() => const TwpWarningState();

  /// Replaces the owning email id and warning list together — fed on
  /// content-load success (`GetEmailContentSuccess`/
  /// `GetEmailContentFromCacheSuccess`). Never called from a keyword-only
  /// update, so a keyword-only refresh never wipes the warning list.
  void setWarnings(EmailId emailId, List<TwpWarning> warnings) {
    state = TwpWarningState(
      emailId: emailId,
      warnings: warnings,
      dismissedKeywords: state.dismissedKeywords,
    );
  }

  void clearWarnings() {
    state = TwpWarningState(
      emailId: null,
      warnings: const [],
      dismissedKeywords: state.dismissedKeywords,
    );
  }

  /// Recomputes the effective dismissed-keyword set from the open email's
  /// live keywords. Fed independently of [setWarnings] whenever the open
  /// email changes (WebSocket-refreshed keywords included).
  void setKeywords(Map<KeyWordIdentifier, bool>? keywords) {
    final dismissed = keywords?.entries
        .where((entry) =>
            entry.value && entry.key.value.startsWith(twpWarningDismissedKeywordPrefix))
        .map((entry) => entry.key.value)
        .toSet() ?? const <String>{};
    state = state.copyWith(dismissedKeywords: dismissed);
  }
}
