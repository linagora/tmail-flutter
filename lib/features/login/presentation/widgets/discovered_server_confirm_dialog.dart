import 'package:core/presentation/extensions/url_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Asks the user to confirm a mail server found over plaintext DNS, which an
/// attacker on the network path can spoof.
///
/// Returns true only when the user taps Continue. Cancel, back or any other
/// dismissal returns false.
class DiscoveredServerConfirmDialog {
  const DiscoveredServerConfirmDialog();

  /// Shows the dialog for the server [jmapUrl] found for [email]. Returns
  /// false without asking when [currentEmail] is no longer [email] (the field
  /// was edited after the lookup started), when there is no screen to ask on,
  /// or when [email] has no domain; and false when [currentEmail] changed
  /// while the dialog was open.
  Future<bool> confirm(
    BuildContext? context, {
    required String email,
    required String? Function() currentEmail,
    required String jmapUrl,
  }) async {
    final emailDomain = email.split('@').last;
    if (currentEmail() != email || emailDomain.isEmpty) return false;
    if (context?.mounted != true) return false;

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
