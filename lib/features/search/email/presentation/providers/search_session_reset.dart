import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/providers/search_executor_provider.dart';

/// Clears the keepAlive search result SSOT when a search session ends: the
/// executor session plus the raw and presentation result state.
///
/// Must run on every leave-search path, not just the SearchEmailController
/// teardown — on wide web, selecting a mailbox leaves search without disposing
/// the controller, so its onClose never runs and the stale results would
/// otherwise reappear the next time search is opened. Filter reset is left to
/// callers.
void resetSearchResultSession(ProviderContainer container) {
  container.read(searchExecutorServiceProvider).resetSession();
  container.invalidate(searchEmailProvider);
  container.invalidate(searchEmailPresentationProvider);
}
