import '../base/core_robot.dart';
import 'abstract/abstract_search_viewport_robot.dart';

class SearchViewportRobot extends CoreRobot
    implements AbstractSearchViewportRobot {
  SearchViewportRobot(super.$);

  @override
  Future<void> resizeToMobileViewport() async {
    // Native integration tests already execute in the device's responsive layout.
  }

  @override
  Future<void> resizeToTabletViewport() async {
    // Native integration tests preserve the connected device viewport.
  }
}
