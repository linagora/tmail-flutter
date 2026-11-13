import 'abstract_workplace_account_switcher_assertion_robot.dart';

abstract class AbstractWorkplaceAccountSwitcherRobot {
  AbstractWorkplaceAccountSwitcherAssertionRobot get assertion;

  Future<void> openMenu();

  /// Opens the menu and picks a row by its visible address.
  Future<void> selectByAddress(String emailAddress);

  /// Picks a row when the chip menu is already open.
  Future<void> selectAddressWhenMenuOpen(String emailAddress);
}
