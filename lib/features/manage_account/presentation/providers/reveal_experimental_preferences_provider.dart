import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/reveal_experimental_preferences_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/manage_account_data_providers.dart';

part 'reveal_experimental_preferences_provider.g.dart';

@riverpod
Future<void> revealExperimentalPreferences(Ref ref) async {
  return RevealExperimentalPreferencesInteractor(
    ref.watch(manageAccountRepositoryProvider),
  ).execute();
}
