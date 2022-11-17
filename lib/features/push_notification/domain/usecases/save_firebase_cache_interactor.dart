import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/firebase/firebase_dto.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/firebase_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/save_firebase_state.dart';

class SaveFirebaseCacheInteractor {
  final FirebaseRepository _firebaseRepository;

  SaveFirebaseCacheInteractor(this._firebaseRepository);

  Future<Either<Failure, Success>> execute(FirebaseDto firebaseDto) async {
    try {
      await _firebaseRepository.setCurrentFirebase(firebaseDto);
      return Right<Failure, Success>(SaveFirebaseSuccess());
    } catch (e) {
      logError('SaveFirebaseCacheInteractor::execute(): $e');
      return Left<Failure, Success>(SaveFirebaseFailure(e));
    }
  }
}
