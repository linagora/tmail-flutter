import 'dart:isolate';

import 'package:core/utils/app_logger.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/caching/extension/token_oidc_collection_extension.dart';
import 'package:tmail_ui_user/features/caching/interactions/isar/isar_token_oidc_collection_interaction.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/data/manager/token_cache_manager.dart';

class IsarTokenCacheManager extends TokenCacheManager {
  final IsarTokenOidcCollectionInteraction _collectionInteraction;

  IsarTokenCacheManager(this._collectionInteraction);

  @override
  Future<TokenOIDC> getTokenOidc(String tokenIdHash) async {
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::getTokenOidc(): tokenIdHash: $tokenIdHash');
    final tokenCache = await _collectionInteraction.getItem(tokenIdHash);
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::getTokenOidc: Token: ${tokenCache.token}');
    return tokenCache.toTokenOidc();
  }

  @override
  Future<void> persistOneTokenOidc(TokenOIDC tokenOIDC) async {
    log('IsarTokenCacheManager::persistOneTokenOidc: tokenIdHash = ${tokenOIDC.tokenIdHash}');
    await deleteTokenOidc();
    await _collectionInteraction.insertItem(tokenOIDC.toTokenOidcCollection());
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::persistOneTokenOidc(): done');
  }

  @override
  Future<void> deleteTokenOidc() async {
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::deleteTokenOidc:');
    await _collectionInteraction.clear();
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::deleteTokenOidc: DONE');
  }
}