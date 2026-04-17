import 'package:patrol/patrol.dart';

import 'robot_factory.dart';
import 'mobile_robot_factory.dart';

RobotFactory createRobotFactory(PatrolIntegrationTester $) => MobileRobotFactory($);
