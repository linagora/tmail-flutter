import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saas/domain/model/code_challenge_method.dart';
import 'package:saas/domain/model/verifier_code.dart';
import 'package:saas/domain/utils/code_challenge_generator.dart';

void main() {
  /**
   * Contains all legal characters for a code verifier.
   * @see <a href="https://tools.ietf.org/html/rfc7636#section-4.1">RFC 7636, Section 4.1</a>
   */
  const codeVerifierLegalCharacters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_~.';

  group('Code Challenge', () {
    test('generate code challenge with s256 from all legal characters of code verifier', () {
      const codeVerifier = VerifierCode(codeVerifierLegalCharacters);
      final codeChallenge = CodeChallengeGenerator(CryptoUtils()).generateCodeChallenge(codeVerifier, codeChallengeMethod: CodeChallengeMethod.s256);
      expect(codeChallenge, equals('_Fk5DOV4ihL0sflHIbP8awdE_Dla_5sX5fZG1qSYiOs'));
    });

    test('generate code challenge with plain from all legal characters of code verifier', () {
      const codeVerifier = VerifierCode(codeVerifierLegalCharacters);
      final codeChallenge = CodeChallengeGenerator(CryptoUtils()).generateCodeChallenge(codeVerifier, codeChallengeMethod: CodeChallengeMethod.plain);
      expect(codeChallenge, equals(codeVerifierLegalCharacters));
    });

    test('generate code challenge with s256 from specific verifier', () {
      const codeVerifier = VerifierCode('RhtC9GtrA6-U8T4Rwf2cMEc2MRJSFILhBKWOR3QJP9OPTRlY2MPbvwn0GikyWEwz16a6kNehRneHwH1uy4spFA');
      final codeChallenger = CodeChallengeGenerator(CryptoUtils())
          .generateCodeChallenge(codeVerifier, codeChallengeMethod: CodeChallengeMethod.s256);
      expect(codeChallenger, equals('rVX0zGaiul5oaps_IQ_DztHBKmjocRR6lTbUy340OAY'));
    });
  });
}