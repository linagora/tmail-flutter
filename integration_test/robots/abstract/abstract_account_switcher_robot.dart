import 'abstract_account_switcher_assertion_robot.dart';

abstract class AbstractAccountSwitcherRobot {
  AbstractAccountSwitcherAssertionRobot get assertion;

  Future<void> openMenu();

  /// Opens the menu and picks a row by its visible address.
  Future<void> selectByAddress(String emailAddress);

  /// Picks a row when the avatar menu is already open (does not toggle the menu).
  Future<void> selectAddressWhenMenuOpen(String emailAddress);

  /// Opens the menu, picks [emailAddress], and waits for the loading dialog.
  ///
  /// Does not pump-and-settle after the tap so an in-flight switch stays visible.
  Future<void> selectByAddressAwaitingLoading(String emailAddress);

  Future<void> tapCancelOnLoadingDialog();

  /// Cancels an in-flight switch via the loading dialog Cancel, or via the
  /// notifier during the show-delay window before the dialog appears.
  Future<void> cancelInFlightSwitch();

  Future<void> dismissViewingBanner();
}
