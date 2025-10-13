import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class AutoRefreshArguments extends RouterArguments {
  final String jmapUrl;

  AutoRefreshArguments(this.jmapUrl);

  @override
  List<Object?> get props => [jmapUrl];
}
