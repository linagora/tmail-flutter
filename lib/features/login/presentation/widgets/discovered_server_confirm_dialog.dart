import 'package:core/presentation/extensions/url_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/login/domain/state/dns_lookup_to_get_jmap_url_state.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Decides whether a mail server found over DNS may be used, asking the user
/// when a plaintext resolver found it: an attacker on the network path can
/// spoof that answer.
///
/// When asked, returns true only when the user taps Continue. Cancel, back or
/// any other dismissal returns false.
class DiscoveredServerConfirmDialog {
  const DiscoveredServerConfirmDialog();

  /// Returns false without asking when [currentEmail] is no longer the email
  /// of [answer] (the field was edited after the lookup started), whatever
  /// resolver found it. Accepts a server found over DNS-over-HTTPS without
  /// asking. Otherwise shows the dialog; returns false without asking when
  /// there is no screen to ask on or the email has no domain, and false when
  /// [currentEmail] changed while the dialog was open.
  Future<bool> confirm(
    BuildContext? context, {
    required DNSLookupToGetJmapUrlSuccess answer,
    required String? Function() currentEmail,
  }) async {
    final email = answer.email;
    if (currentEmail() != email) return false;
    if (answer.isEncryptedSource) return true;

    final emailDomain = email.split('@').last;
    if (emailDomain.isEmpty || context?.mounted != true) return false;

    final jmapUrl = answer.jmapUrl;
    final isConfirmed = await show(
      context!,
      emailDomain: emailDomain,
      serverHost: Uri.tryParse(jmapUrl.formatURLValid())?.host ?? jmapUrl,
    );
    return isConfirmed && currentEmail() == email;
  }

  Future<bool> show(
    BuildContext context, {
    required String emailDomain,
    required String serverHost,
  }) async {
    final appLocalizations = AppLocalizations.of(context);
    var isConfirmed = false;

    await MessageDialogActionManager().showConfirmDialogAction(
      context,
      '',
      appLocalizations.continueAction,
      key: const Key('confirm_discovered_server_dialog'),
      title: appLocalizations.discoveredServerTitle,
      alignCenter: true,
      outsideDismissible: false,
      listTextSpan: _buildMessage(appLocalizations, emailDomain, serverHost),
      onConfirmAction: () => isConfirmed = true,
    );

    return isConfirmed;
  }

  /// True when [serverHost] is the email domain or one of its subdomains.
  static bool isInEmailDomain(String serverHost, String emailDomain) {
    final host = serverHost.toLowerCase();
    final domain = emailDomain.toLowerCase();
    return domain.isNotEmpty && (host == domain || host.endsWith('.$domain'));
  }

  List<TextSpan> _buildMessage(
    AppLocalizations appLocalizations,
    String emailDomain,
    String serverHost,
  ) {
    final boldStyle = ThemeUtils.textStyleM3BodyMedium1.copyWith(
      fontWeight: FontWeight.bold,
    );

    return [
      TextSpan(text: '${appLocalizations.discoveredServerPrefix} '),
      TextSpan(text: emailDomain, style: boldStyle),
      const TextSpan(text: ': '),
      TextSpan(text: serverHost, style: boldStyle),
      TextSpan(text: '. ${appLocalizations.discoveredServerHint}'),
      if (!isInEmailDomain(serverHost, emailDomain))
        TextSpan(text: '\n${appLocalizations.discoveredServerOutsideDomainWarning}'),
    ];
  }
}
