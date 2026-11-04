import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DNSLookupToGetJmapUrlLoading extends LoadingState {}

class DNSLookupToGetJmapUrlSuccess extends UIState {
  final String jmapUrl;

  /// The address the lookup was made for: the server belongs to its domain,
  /// not to whatever the email field holds when the answer arrives.
  final String email;

  /// False when the server came from a plaintext resolver: the user must
  /// confirm it before the app contacts it. Fails closed: unset means plaintext.
  final bool isEncryptedSource;

  DNSLookupToGetJmapUrlSuccess(
    this.jmapUrl, {
    required this.email,
    this.isEncryptedSource = false,
  });

  @override
  List<Object> get props => [jmapUrl, email, isEncryptedSource];
}

class DNSLookupToGetJmapUrlFailure extends FeatureFailure {
  DNSLookupToGetJmapUrlFailure(
    dynamic exception, {
    required this.email,
  }) : super(exception: exception);

  final String email;
}