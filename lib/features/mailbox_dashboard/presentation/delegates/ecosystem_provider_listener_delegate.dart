import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/dashboard_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/drive_attachment_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/linagora_ecosystem_handler_registry.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/scribe_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/sentry_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/web_sentry_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/active_ecosystem_provider.dart';
import 'package:tmail_ui_user/features/paywall/presentation/providers/premium_cta_provider.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EcosystemProviderListenerDelegate
    implements DashboardProviderListenerDelegate {
  ProviderSubscription<EcosystemState>? _subscription;
  Worker? _accountIdWorker;
  LinagoraEcosystemHandlerRegistry? _registry;
  bool _isDisposed = false;

  @override
  void setup(WidgetRef ref, BuildContext Function() _) {
    final dashboardController = getBinding<MailboxDashBoardController>();
    if (dashboardController == null) return;
    final registry = ref.read(linagoraEcosystemHandlerRegistryProvider);
    _registry = registry;

    _registerHandlers(registry);
    _accountIdWorker = ever(
      dashboardController.accountId,
      (_) => _listen(
        ref,
        registry,
        dashboardController,
        accountChanged: true,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || _subscription != null) return;
      _listen(ref, registry, dashboardController);
    });
  }

  void _registerHandlers(
    LinagoraEcosystemHandlerRegistry registry,
  ) {
    if (registry.hasHandlers) return;
    registry
      ..register(DriveAttachmentEcosystemHandler())
      ..register(ScribeEcosystemHandler());
    if (PlatformInfo.isWeb) {
      registry.register(WebSentryEcosystemHandler());
    } else {
      registry.register(SentryEcosystemHandler(
        setUpSentry: (config) async {
          await getBinding<MailboxDashBoardController>()?.setUpSentry(config);
        },
        clearSentry: () async {
          await getBinding<MailboxDashBoardController>()?.clearSentry();
        },
        resetSentryReportingConsent: () {
          SentryManager.instance.setSentryReportingConsent(null);
        },
      ));
    }
  }

  void _listen(
    WidgetRef ref,
    LinagoraEcosystemHandlerRegistry registry,
    MailboxDashBoardController dashboardController, {
    bool accountChanged = false,
  }) {
    _subscription?.close();
    if (accountChanged) {
      registry.dispatchAccountChanged();
    } else {
      registry.dispatchCleared();
    }
    _subscription = ref.listenManual(
      activeEcosystemProvider(
        dashboardController.accountId.value,
        dashboardController.dynamicUrlInterceptors.jmapUrl,
      ),
      (previousState, state) {
        switch (state) {
          case EcosystemAvailable(:final ecosystem):
            registry.dispatchLoaded(ecosystem);
          case EcosystemUnavailable():
            registry.dispatchCleared();
          case EcosystemLoading():
            if (previousState != null && previousState is! EcosystemLoading) {
              registry.dispatchCleared();
            }
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _accountIdWorker?.dispose();
    _accountIdWorker = null;
    _subscription?.close();
    _subscription = null;
    // The registry outlives this delegate, so the ecosystem it was fed must not
    // outlive the session that produced it.
    _registry?.dispatchCleared();
    _registry = null;
  }
}
