import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/dns_lookup_to_get_jmap_url_state.dart';

class DNSLookupToGetJmapUrlInteractor {
  final LoginRepository _loginRepository;

  DNSLookupToGetJmapUrlInteractor(this._loginRepository);

  Stream<Either<Failure, Success>> execute(String emailAddress) async* {
    try {
      yield Right<Failure, Success>(DNSLookupToGetJmapUrlLoading());
      final jmapUrl = await _loginRepository.dnsLookupToGetJmapUrl(emailAddress);
      yield Right<Failure, Success>(DNSLookupToGetJmapUrlSuccess(jmapUrl));
    } catch (e) {
      yield Left<Failure, Success>(DNSLookupToGetJmapUrlFailure(
        e,
        email: emailAddress,
      ));
    }
  }
}