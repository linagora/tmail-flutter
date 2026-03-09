import 'package:core/domain/exceptions/app_base_exception.dart';

abstract class RemoteException extends AppBaseException {
  final int? code;

  const RemoteException({
    this.code,
    String? message,
  }) : super(message);

  @override
  String toString() {
    if (code != null && message != null) {
      return '$exceptionName(code: $code): $message';
    }

    if (code != null) {
      return '$exceptionName(code: $code)';
    }

    return super.toString();
  }

  @override
  List<Object?> get props => [code, ...super.props];
}
