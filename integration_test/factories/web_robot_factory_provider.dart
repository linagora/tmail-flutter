import 'package:patrol/patrol.dart';

import 'robot_factory.dart';
import 'web_robot_factory.dart';

RobotFactory createRobotFactory(PatrolIntegrationTester $) => WebRobotFactory($);
