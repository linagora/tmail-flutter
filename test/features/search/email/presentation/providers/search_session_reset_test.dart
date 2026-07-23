import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/providers/search_executor_provider.dart';
import 'package:tmail_ui_user/features/search/email/presentation/providers/search_session_reset.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_executor_service.dart';

class _RecordingExecutor extends SearchExecutorService {
  _RecordingExecutor(this._ownContainer) : super(_ownContainer);

  final ProviderContainer _ownContainer;

  int resetSessionCount = 0;

  @override
  void resetSession() => resetSessionCount++;

  void disposeContainer() => _ownContainer.dispose();
}

void main() {
  test(
    'resetSearchResultSession ends the executor session and clears the result '
    'state so nothing leaks into the next search',
    () {
      final executor = _RecordingExecutor(ProviderContainer());
      final container = ProviderContainer(overrides: [
        searchExecutorServiceProvider.overrideWithValue(executor),
      ]);
      addTearDown(() {
        container.dispose();
        executor.disposeContainer();
      });

      container
          .read(searchEmailPresentationProvider.notifier)
          .setResultSearches([PresentationEmail(id: EmailId(Id('email-1')))]);
      expect(
        container.read(searchEmailPresentationProvider).listResultSearch,
        isNotEmpty,
      );

      resetSearchResultSession(container);

      expect(executor.resetSessionCount, 1);
      expect(
        container.read(searchEmailPresentationProvider).listResultSearch,
        isEmpty,
      );
    },
  );
}
