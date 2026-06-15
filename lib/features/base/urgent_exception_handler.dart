import 'package:core/presentation/state/failure.dart';

abstract interface class UrgentExceptionHandler {
  bool validateUrgentException(dynamic exception);

  void handleUrgentException({Failure? failure, Exception? exception});
}
