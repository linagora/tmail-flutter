
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/firebase_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_firebase_state.dart';

class GetFirebaseCacheInteractor {

  final FirebaseRepository _firebaseRepository;

  GetFirebaseCacheInteractor(this._firebaseRepository);

  Future<Either<Failure, Success>> execute(
      OIDCConfiguration config,
      String refreshToken) async {
    try {
      final firebase = await _firebaseRepository.getCurrentFirebase();
      return Right<Failure, Success>(GetFirebaseSuccess(firebase));
    } catch (e) {
      logError('GetFirebaseCacheInteractor::execute(): $e');
      return Left<Failure, Success>(GetFirebaseFailure(e));
    }
  }
}