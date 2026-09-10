import 'package:core/utils/platform_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_launcher.dart';
import 'package:tmail_ui_user/features/paywall/presentation/providers/premium_cta_provider.dart';

/// Premium CTA access shared by every call site, so the "is it still
/// available?" check and the launch live in one place instead of at each button.
extension PremiumCtaWidgetRefExtension on WidgetRef {
  /// Watches the CTA only where the paywall can be opened: web.
  PremiumCtaState watchWebPremiumCta(PremiumCtaContext? context) =>
      PlatformInfo.isWeb
          ? watch(premiumCtaProvider(context))
          : const PremiumCtaUnavailable(
              PremiumCtaUnavailableReason.premiumNotAvailable,
            );

  void openPremiumCta(PremiumCtaContext? context) => _openPremiumCta(
        read(premiumCtaProvider(context)),
        read(paywallLauncherProvider),
      );
}

/// Imperative entry points for GetX call sites.
///
/// Deliberately platform-neutral: the composer over-quota dialog offers the CTA
/// on mobile too (unchanged behaviour), while the sidebar scroll offset applies
/// its own `PlatformInfo.isWeb` check. Only the widget-facing
/// [PremiumCtaWidgetRefExtension.watchWebPremiumCta] is web-gated.
extension PremiumCtaContainerExtension on ProviderContainer {
  bool isPremiumCtaAvailable(PremiumCtaContext? context) =>
      read(premiumCtaProvider(context)) is PremiumCtaAvailable;

  void openPremiumCta(PremiumCtaContext? context) => _openPremiumCta(
        read(premiumCtaProvider(context)),
        read(paywallLauncherProvider),
      );
}

void _openPremiumCta(PremiumCtaState state, PaywallLauncher launcher) {
  if (state is! PremiumCtaAvailable) return;
  launcher.launch(state.destination);
}
