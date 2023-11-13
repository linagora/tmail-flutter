import 'package:core/data/network/config/service_path.dart';

class Endpoint {
  static final ServicePath webFinger = ServicePath('/.well-known/webfinger');
  static final ServicePath sessionPath = ServicePath('/.well-known/jmap');
}
