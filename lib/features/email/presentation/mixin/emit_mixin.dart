import 'package:core/presentation/state/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';

mixin EmitMixin {
  void emitFailure({
    required BaseController controller,
    required FeatureFailure failure,
  }) {
    controller.consumeState(Stream.value(Left(failure)));
  }
}
