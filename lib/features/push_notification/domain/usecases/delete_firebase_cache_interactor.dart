import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/firebase_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/delete_firebase_state.dart';

class DeleteFirebaseCacheInteractor {
  final FirebaseRepository _firebaseRepository;

  DeleteFirebaseCacheInteractor(this._firebaseRepository);

  Future<Either<Failure, Success>> execute(String token) async {
    try {
      await _firebaseRepository.deleteCurrentFirebase(token);
      return Right<Failure, Success>(DeleteFirebaseSuccess());
    } catch (e) {
      logError('DeleteFirebaseCacheInteractor::execute(): $e');
      return Left<Failure, Success>(DeleteFirebaseFailure(e));
    }
  }
}
