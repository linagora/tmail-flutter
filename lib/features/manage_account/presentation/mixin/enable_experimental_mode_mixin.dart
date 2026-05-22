import 'dart:async';

import 'package:core/presentation/utils/app_toast.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/experimental_mode_notifier.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin EnableExperimentalModeMixin {
  void enableExperimentalMode() {
    unawaited(
      appProviderContainer
          .read(experimentalModeNotifierProvider.notifier)
          .enable()
          .then((_) {
        final isEnabled = appProviderContainer.read(experimentalModeNotifierProvider);
        if (!isEnabled) return;
        if (currentOverlayContext == null || currentContext == null) return;
        getBinding<AppToast>()?.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).experimentalFeaturesEnabled,
        );
      }),
    );
  }
}
