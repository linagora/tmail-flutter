import 'package:core/utils/app_logger.dart';
import 'package:model/firebase/firebase_dto.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/firebase_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/firebase_repository.dart';

class FirebaseRepositoryImpl extends FirebaseRepository {

  final FirebaseDatasource _firebaseDatasource;

  FirebaseRepositoryImpl(this._firebaseDatasource);

  @override
  Future<FirebaseDto> getCurrentFirebase() {
    return _firebaseDatasource.getCurrentFirebase();
  }

  @override
  Future<void> setCurrentFirebase(FirebaseDto newCurrentFirebase) {
    log('FirebaseRepositoryImpl::setCurrentFirebase(): $newCurrentFirebase');
    return _firebaseDatasource.setCurrentFirebase(newCurrentFirebase);
  }

  @override
  Future<void> deleteCurrentFirebase(String token) {
    return _firebaseDatasource.deleteCurrentFirebase(token);
  }
}