import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/manage_account_data_providers.dart';

part 'experimental_preferences_revealed_provider.g.dart';

@Riverpod(keepAlive: true)
Future<bool> experimentalPreferencesRevealed(Ref ref) async {
  return ref.watch(getExperimentalPreferencesRevealedInteractorProvider).execute();
}
