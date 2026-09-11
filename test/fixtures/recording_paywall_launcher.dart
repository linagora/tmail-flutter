import 'package:tmail_ui_user/features/paywall/presentation/paywall_launcher.dart';

class RecordingPaywallLauncher implements PaywallLauncher {
  int launchCount = 0;
  Uri? launchedDestination;

  @override
  void launch(Uri destination) {
    launchCount++;
    launchedDestination = destination;
  }
}
