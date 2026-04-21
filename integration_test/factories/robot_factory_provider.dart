// Single branching point for platform selection — this file never changes.
// dart.library.html is true on web (dart2js/dartdevc), false on mobile (dart2native).
export 'mobile_robot_factory_provider.dart'
    if (dart.library.html) 'web_robot_factory_provider.dart';
