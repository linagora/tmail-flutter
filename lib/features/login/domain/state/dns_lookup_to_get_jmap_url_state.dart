import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DNSLookupToGetJmapUrlLoading extends LoadingState {}

class DNSLookupToGetJmapUrlSuccess extends UIState {
  final String jmapUrl;

  /// False when the server came from a plaintext resolver: the user must
  /// confirm it before the app contacts it.
  final bool isEncryptedSource;

  DNSLookupToGetJmapUrlSuccess(this.jmapUrl, {this.isEncryptedSource = true});

  @override
  List<Object> get props => [jmapUrl, isEncryptedSource];
}

class DNSLookupToGetJmapUrlFailure extends FeatureFailure {
  DNSLookupToGetJmapUrlFailure(
    dynamic exception, {
    required this.email,
  }) : super(exception: exception);

  final String email;
}