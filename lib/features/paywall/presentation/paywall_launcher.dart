import 'package:core/utils/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

part 'paywall_launcher.g.dart';

/// Opens a resolved paywall destination.
///
/// Stateless collaborator rather than screen state: every CTA call site
/// resolves the same instance from [paywallLauncherProvider], and tests
/// substitute it by overriding that provider.
class PaywallLauncher {
  const PaywallLauncher();

  void launch(Uri destination) {
    final paywallUrl = destination.toString();
    // The CTA state only exposes validated destinations; re-check here because
    // this is the boundary that hands a URL to the platform launcher.
    if (!PaywallUtils.isValidPaywallUrl(paywallUrl)) {
      logWarning('$runtimeType::launch: Invalid paywall URL');
      return;
    }
    AppUtils.launchLink(paywallUrl);
  }
}

@Riverpod(keepAlive: true)
PaywallLauncher paywallLauncher(Ref ref) => const PaywallLauncher();
