import 'package:core/presentation/state/failure.dart';

// A failure's toString can dump the whole request.
String describeFailure(Failure failure) => failure is FeatureFailure
    ? '${failure.runtimeType}: ${failure.exception}'
    : '${failure.runtimeType}';
