import 'package:model/firebase/firebase_dto.dart';

abstract class FirebaseDatasource {
  Future<FirebaseDto> getCurrentFirebase();

  Future<void> setCurrentFirebase(FirebaseDto newCurrentFirebase);

  Future<void> deleteCurrentFirebase(String token);
}