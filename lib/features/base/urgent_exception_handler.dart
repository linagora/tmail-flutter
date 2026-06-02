import 'package:core/presentation/state/failure.dart';

abstract class UrgentExceptionHandler {
  bool validateUrgentException(dynamic exception);
  void handleUrgentException({Failure? failure, Exception? exception});
}
