
import '../mixin/requires_login_mixin.dart';
import '../mixin/scenario_utils_mixin.dart';
import 'base_scenario.dart';

abstract class BaseTestScenario extends BaseScenario
    with RequiresLoginMixin, ScenarioUtilsMixin {

  const BaseTestScenario(super.$);

  @override
  Future<void> execute() async {
    await executeLoginScenario();
    await runTestLogic();
  }

  Future<void> runTestLogic();
}
