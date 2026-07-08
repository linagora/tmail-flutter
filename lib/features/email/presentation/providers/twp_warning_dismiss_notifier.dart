import 'package:core/presentation/state/failure.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/base/handle_urgent_exception.dart';
import 'package:tmail_ui_user/features/email/domain/state/dismiss_twp_warning_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/dismiss_twp_warning_interactor.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

part 'twp_warning_dismiss_notifier.g.dart';

/// Outcome of [TwpWarningDismiss.dismiss]. [urgentHandled] means the failure was
/// an urgent exception already routed centrally (re-login, etc.), so the caller
/// must not show its own error UI.
enum TwpWarningDismissResult { dismissed, failed, urgentHandled }

/// Per-email set of `X-TWP-Message` warning indexes dismissed this session.
///
/// `autoDispose`: alive only while the email view `ref.watch`es it, so the set
/// clears when the view closes (no leak; replaces the old controller reset).
/// Cross-session persistence is the backend keyword `twp-warning-dismissed-<index>`
/// (see [DismissTwpWarningInteractor], [PresentationEmail.isTwpWarningDismissed]).
@riverpod
class TwpWarningDismiss extends _$TwpWarningDismiss {
  @override
  Set<int> build(String emailId) => const <int>{};

  /// Optimistically hides the warning at [index], then persists the dismissal
  /// keyword via [DismissTwpWarningInteractor]. Rolls back on failure; urgent
  /// exceptions are routed centrally (see [handleUrgentExceptionIfNeeded]) and
  /// reported as [TwpWarningDismissResult.urgentHandled].
  Future<TwpWarningDismissResult> dismiss(
    Session session,
    AccountId accountId,
    EmailId emailId,
    int index,
  ) async {
    if (state.contains(index)) return TwpWarningDismissResult.dismissed;

    state = {...state, index};

    final interactor = getBinding<DismissTwpWarningInteractor>();
    if (interactor == null) {
      _rollback(index);
      return TwpWarningDismissResult.failed;
    }

    try {
      final result = await interactor
          .execute(session, accountId, emailId, index)
          .last;

      return result.fold((failure) => _onFailure(index, failure: failure), (
        success,
      ) {
        if (success is DismissTwpWarningSuccess) {
          return TwpWarningDismissResult.dismissed;
        }
        _rollback(index);
        return TwpWarningDismissResult.failed;
      });
    } catch (e) {
      return _onFailure(index, exception: e);
    }
  }

  TwpWarningDismissResult _onFailure(
    int index, {
    Failure? failure,
    Object? exception,
  }) {
    _rollback(index);
    final isUrgent = handleUrgentExceptionIfNeeded(
      failure: failure,
      exception: exception,
    );
    return isUrgent
        ? TwpWarningDismissResult.urgentHandled
        : TwpWarningDismissResult.failed;
  }

  void _rollback(int index) {
    if (!ref.mounted) return;
    state = {...state}..remove(index);
  }
}
