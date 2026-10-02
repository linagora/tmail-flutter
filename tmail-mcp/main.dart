import 'package:tmail_ui_user/main.dart' as app;

import 'marionette/marionette_mcp_binding.dart';
import 'runtime/mcp_app_runtime.dart';

Future<void> main() async {
  McpAppRuntime.bootstrap(const [
    MarionetteMcpBinding(),
  ]);
  await app.main();
}
