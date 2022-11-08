import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

typedef SetMethodErrors = Map<Id, SetError>;

/// Returns true if handle [setError] successfully and otherwise
typedef SetMethodErrorHandler = bool Function(MapEntry<Id, SetError> setError);
