import 'package:core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/experimental_mode_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/enable_experimental_mode_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_experimental_mode_enabled_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/manage_account_local_providers.dart';

class ExperimentalModeNotifier extends StateNotifier<bool> {
  static const int activationTapCount = 7;

  final GetExperimentalModeEnabledInteractor _getInteractor;
  final EnableExperimentalModeInteractor _enableInteractor;

  // Resolves when the initial load from storage completes.
  late final Future<void> ensureLoaded;

  ExperimentalModeNotifier(this._getInteractor, this._enableInteractor) : super(false) {
    ensureLoaded = _load().onError((e, _) {
      logError('ExperimentalModeNotifier: failed to load initial state: $e');
    });
  }

  Future<void> _load() async {
    final result = await _getInteractor.execute();
    result.fold(
      (_) {},
      (success) {
        if (success is GetExperimentalModeEnabledSuccess) state = success.isEnabled;
      },
    );
  }

  Future<void> enable() async {
    if (state) return;
    final result = await _enableInteractor.execute();
    result.fold(
      (_) {},
      (success) {
        if (success is EnableExperimentalModeSuccess) state = true;
      },
    );
  }
}

final experimentalModeNotifierProvider =
    StateNotifierProvider<ExperimentalModeNotifier, bool>(
  (ref) => ExperimentalModeNotifier(
    ref.read(getExperimentalModeEnabledProvider),
    ref.read(enableExperimentalModeProvider),
  ),
);
