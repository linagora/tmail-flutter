import 'dart:convert';

import 'package:core/core.dart';
import 'package:crypto/crypto.dart';
import 'package:saas/domain/model/code_challenge_method.dart';
import 'package:saas/domain/model/verifier_code.dart';

class CodeChallengeGenerator {

  final CryptoUtils _cryptoUtils;

  CodeChallengeGenerator(this._cryptoUtils);

  String generateCodeChallenge(VerifierCode verifierCode, {
    CodeChallengeMethod codeChallengeMethod = CodeChallengeMethod.s256
  }) {
    switch (codeChallengeMethod) {
      case CodeChallengeMethod.plain:
        return verifierCode.value;
      case CodeChallengeMethod.s256:
        return _generateCodeChallengeS256(verifierCode);
    }
  }

  String _generateCodeChallengeS256(VerifierCode codeVerifier) {
    final rawCode = utf8.encode(codeVerifier.value);
    final codeChallenge = _cryptoUtils.encodeBase64(base64UrlEncode(sha256.convert(rawCode).bytes));
    return codeChallenge;
  }
}