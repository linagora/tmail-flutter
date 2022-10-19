import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mdn/mdn.dart';

class SendReceiptToSenderLoading extends UIState {}

class SendReceiptToSenderSuccess extends UIState {

  final MDN mdn;

  SendReceiptToSenderSuccess(this.mdn);

  @override
  List<Object?> get props => [mdn];
}

class SendReceiptToSenderFailure extends FeatureFailure {

  final dynamic exception;

  SendReceiptToSenderFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}