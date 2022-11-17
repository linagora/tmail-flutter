
import 'package:model/firebase/firebase_dto.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/firebase_cache.dart';

extension FirebaseCacheExtension on FirebaseCache {

  FirebaseDto toFirebaseDto() {
    return FirebaseDto(token);
  }
}