import 'package:patrol/patrol.dart';

abstract class BaseScenario {
  final PatrolIntegrationTester $;

  const BaseScenario(this.$);

  Future<void> execute();
}