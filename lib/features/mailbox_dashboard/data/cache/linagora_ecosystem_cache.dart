import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';

class LinagoraEcosystemCache {
  static final LinagoraEcosystemCache _instance = LinagoraEcosystemCache._internal();
  
  factory LinagoraEcosystemCache() => _instance;
  
  LinagoraEcosystemCache._internal();
  
  final Map<String, LinagoraEcosystem> _cache = {};
  
  void cacheEcosystem(LinagoraEcosystem ecosystem, String baseUrl) {
    _cache[baseUrl] = ecosystem;
  }
  
  LinagoraEcosystem? getCachedEcosystem(String baseUrl) {
    return _cache[baseUrl];
  }
  
  void clearCache() {
    _cache.clear();
  }
  
  bool hasCachedEcosystem(String baseUrl) {
    return _cache.containsKey(baseUrl);
  }
}