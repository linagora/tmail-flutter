export 'package:universal_html/src/html.dart';

class BroadcastChannel {
  BroadcastChannel(this.name);

  final String name;

  Stream get onMessage => const Stream.empty();
}