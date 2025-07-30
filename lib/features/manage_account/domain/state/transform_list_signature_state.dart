import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identity_signature.dart';

class TransformListSignatureLoading extends LoadingState {}

class TransformListSignatureSuccess extends UIState {
  final List<IdentitySignature> identitySignatures;

  TransformListSignatureSuccess(this.identitySignatures);

  @override
  List<Object?> get props => [identitySignatures];
}

class TransformListSignatureFailure extends FeatureFailure {
  final List<IdentitySignature> identitySignatures;

  TransformListSignatureFailure(exception, this.identitySignatures)
      : super(exception: exception);
}
