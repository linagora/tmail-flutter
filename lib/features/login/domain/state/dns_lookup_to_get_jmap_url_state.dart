import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DNSLookupToGetJmapUrlLoading extends LoadingState {}

class DNSLookupToGetJmapUrlSuccess extends UIState {
  final String jmapUrl;

  DNSLookupToGetJmapUrlSuccess(this.jmapUrl);

  @override
  List<Object> get props => [jmapUrl];
}

class DNSLookupToGetJmapUrlFailure extends FeatureFailure {
  DNSLookupToGetJmapUrlFailure(
    dynamic exception, {
    required this.email,
  }) : super(exception: exception);

  final String email;
}