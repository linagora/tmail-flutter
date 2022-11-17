import 'package:model/firebase/firebase_dto.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/firebase_cache.dart';

extension FirebaseExtensions on FirebaseDto {
  FirebaseCache toCache() {
    return FirebaseCache(token);
  }
}