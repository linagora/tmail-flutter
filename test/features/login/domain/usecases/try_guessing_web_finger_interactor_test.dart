import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/try_guessing_web_finger_interactor.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:tmail_ui_user/features/login/domain/state/try_guessing_web_finger_state.dart';

@GenerateMocks([AuthenticationOIDCRepository])
import 'try_guessing_web_finger_interactor_test.mocks.dart';

void main() {
  late MockAuthenticationOIDCRepository mockRepository;
  late TryGuessingWebFingerInteractor interactor;

  final oidcRequest1 = OIDCRequest(
    baseUrl: 'https://example1.com',
    resourceUrl: 'https://example1.com/.well-known/openid-configuration'
  );
  final oidcRequest2 = OIDCRequest(
    baseUrl: 'https://example2.com', 
    resourceUrl: 'https://example2.com/.well-known/openid-configuration'
  );
  final successResponse = OIDCResponse('subject', []);

  setUp(() {
    mockRepository = MockAuthenticationOIDCRepository();
    interactor = TryGuessingWebFingerInteractor(mockRepository);
  });

  test('should return first successful response immediately', () async {
    // Arrange
    final completer1 = Completer<OIDCResponse>();
    final completer2 = Completer<OIDCResponse>();
    
    when(mockRepository.checkOIDCIsAvailable(oidcRequest1))
      .thenAnswer((_) => completer1.future);
    when(mockRepository.checkOIDCIsAvailable(oidcRequest2))
      .thenAnswer((_) => completer2.future);

    // Act
    final stream = interactor.execute([oidcRequest1, oidcRequest2]);
    final futureResults = stream.toList();
    
    completer1.complete(successResponse);
    await Future.delayed(Duration.zero); // Allow stream to process
    
    // Assert
    final results = await futureResults;
    expect(results, [
      Right(TryingGuessingWebFinger()),
      Right(TryGuessingWebFingerSuccess(successResponse)),
    ]);
    
    verifyInOrder([
      mockRepository.checkOIDCIsAvailable(oidcRequest1),
      mockRepository.checkOIDCIsAvailable(oidcRequest2),
    ]);
    
    // Verify second request was made but not completed
    expect(completer2.isCompleted, isFalse);
  });

  test('should return failure when all responses are null', () async {
    // Arrange
    when(mockRepository.checkOIDCIsAvailable(any))
      .thenAnswer((_) async => throw Exception());

    // Act
    final results = await interactor.execute([oidcRequest1, oidcRequest2]).toList();

    // Assert
    expect(results[0], Right(TryingGuessingWebFinger()));
    expect(results[1], isA<Left<Failure, Success>>());
    expect((results[1] as Left<Failure, Success>).value, isA<TryGuessingWebFingerFailure>());
  });

  test('should handle async response order correctly', () async {
    // Arrange
  final completer1 = Completer<OIDCResponse>();
  final completer2 = Completer<OIDCResponse>();
    
    when(mockRepository.checkOIDCIsAvailable(oidcRequest1))
      .thenAnswer((_) => completer1.future);
    when(mockRepository.checkOIDCIsAvailable(oidcRequest2))
      .thenAnswer((_) => completer2.future);

    // Act
    final stream = interactor.execute([oidcRequest1, oidcRequest2]);
    final futureResults = stream.toList();
    
    completer2.complete(successResponse);
    await Future.delayed(Duration.zero);
    completer1.completeError(Exception('Timeout'));
    
    final results = await futureResults;

    // Assert
    expect(results, [
      Right(TryingGuessingWebFinger()),
      Right(TryGuessingWebFingerSuccess(successResponse)),
    ]);
  });

  test('should handle exceptions properly', () async {
    // Arrange
    when(mockRepository.checkOIDCIsAvailable(any))
      .thenAnswer((_) => Future<OIDCResponse>.error(Exception('Test error')));

    // Act
    final results = await interactor.execute([oidcRequest1]).toList();

    // Assert
    expect(results[0], Right(TryingGuessingWebFinger()));
    expect(results[1], isA<Left<Failure, Success>>());
    expect((results[1] as Left<Failure, Success>).value, isA<TryGuessingWebFingerFailure>());
  });
}
