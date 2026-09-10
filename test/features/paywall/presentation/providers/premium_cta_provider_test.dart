import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/saas/saas_account_capability.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/linagora_ecosystem_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_linagora_ecosystem_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_linagora_system_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/linagora_ecosystem_providers.dart';
import 'package:tmail_ui_user/features/paywall/presentation/providers/premium_cta_provider.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';

void main() {
  group('ecosystem request caching', _ecosystemCachingTests);
  group('ecosystem request lifecycle', _ecosystemLifecycleTests);
  group('ecosystem JMAP URL keying', _jmapUrlKeyingTests);
  group('ecosystem account isolation', _accountIsolationTests);
  group('premium CTA destination', _premiumCtaDestinationTests);
  group('premium CTA unavailable states', _premiumCtaUnavailableTests);
  group('premium CTA gating', _premiumCtaGatingTests);
  group('premium CTA urgent failure routing', _urgentFailureRoutingTests);
  group('premium CTA stream disposal', _streamDisposalTests);
  group('premium CTA missing dependencies', _missingDependenciesTests);
  group('premium CTA degraded inputs', _degradedInputTests);
}

void _ecosystemCachingTests() {
  test('shares one ecosystem request between concurrent consumers', () async {
    final completer = Completer<LinagoraEcosystem>();
    final repository = _EcosystemRepository((_) => completer.future);
    final container = _createContainer(repository);
    _keepEcosystemAlive(container, _firstTarget);

    final first = _readEcosystem(container, _firstTarget);
    final second = _readEcosystem(container, _firstTarget);
    await Future<void>.delayed(Duration.zero);
    expect(repository.callCount, 1);

    final expected = _ecosystem(_paywallTemplate);
    completer.complete(expected);

    expect(await first, same(expected));
    expect(await second, same(expected));
    expect(repository.callCount, 1);
  });

  test('uses account ID as part of the ecosystem cache key', () async {
    final repository = _succeedingRepository();
    final container = _createContainer(repository);

    await Future.wait([
      _readEcosystem(container, _firstTarget),
      _readEcosystem(container, _secondAccountOnFirstUrl),
    ]);

    expect(repository.callCount, 2);
  });
}

void _ecosystemLifecycleTests() {
  test('retries a failed ecosystem key after invalidation', () async {
    final expected = _ecosystem(_paywallTemplate);
    final repository = _failingOnceRepository(expected);
    final container = _createContainer(repository);
    _keepEcosystemAlive(container, _firstTarget);

    await expectLater(
      _readEcosystem(container, _firstTarget),
      throwsA(isA<Failure>()),
    );

    container.invalidate(ecosystemProvider(_firstAccountId, _firstJmapUrl));
    expect(await _readEcosystem(container, _firstTarget), same(expected));
    expect(repository.callCount, 2);
  });

  test('auto-disposes an ecosystem key after its final listener', () async {
    final repository = _succeedingRepository();
    final container = _createContainer(repository);

    final firstSubscription = container.listen(
      ecosystemProvider(_firstAccountId, _firstJmapUrl),
      (_, __) {},
      fireImmediately: true,
    );
    await _readEcosystem(container, _firstTarget);
    firstSubscription.close();
    await container.pump();

    _keepEcosystemAlive(container, _firstTarget);
    await _readEcosystem(container, _firstTarget);

    expect(repository.callCount, 2);
  });
}

void _jmapUrlKeyingTests() {
  test('reports a missing JMAP URL without fetching the ecosystem', () {
    _expectCtaWithoutFetch(
      _upgradableContext(_targetWithoutJmapUrl),
      PremiumCtaUnavailableReason.missingJmapUrl,
    );
  });

  test('treats a blank JMAP URL as missing', () {
    _expectCtaWithoutFetch(
      _upgradableContext(_targetWithBlankJmapUrl),
      PremiumCtaUnavailableReason.missingJmapUrl,
    );
  });

  test('keys the ecosystem state by the JMAP URL', () async {
    final repository = _succeedingRepository();
    final container = _createContainer(repository);
    expect(
      container.read(activeEcosystemProvider(_firstAccountId, null)),
      _unavailableEcosystem(EcosystemUnavailableReason.missingJmapUrl),
    );

    _keepActiveEcosystemAlive(container, _firstTarget);
    await _readEcosystem(container, _firstTarget);
    await container.pump();

    expect(
      container.read(activeEcosystemProvider(_firstAccountId, _firstJmapUrl)),
      isA<EcosystemAvailable>(),
    );
    expect(repository.callCount, 1);
  });
}

void _accountIsolationTests() {
  test('isolates late results after account and JMAP switches', () async {
    final firstCompleter = Completer<LinagoraEcosystem>();
    final secondCompleter = Completer<LinagoraEcosystem>();
    final repository = _EcosystemRepository((url) => url == _firstJmapUrl
        ? firstCompleter.future
        : secondCompleter.future);
    final container = _createContainer(repository);

    final firstFuture = _readEcosystem(container, _firstTarget);
    final secondFuture = _readEcosystem(container, _secondTarget);
    final secondEcosystem = _ecosystem('$_secondJmapUrl/premium');
    secondCompleter.complete(secondEcosystem);
    expect(await secondFuture, same(secondEcosystem));

    firstCompleter.complete(_ecosystem('$_firstJmapUrl/premium'));
    await firstFuture;

    expect(
      container.read(ecosystemProvider(_secondAccountId, _secondJmapUrl)).value,
      same(secondEcosystem),
    );
    expect(repository.callCount, 2);
  });
}

typedef _DestinationCase = ({
  String name,
  String ownerEmail,
  String expectedUrl,
});

const _destinationTemplate = 'https://paywall.domain.tld/{localPart}/{domainName}';

const _destinationCases = <_DestinationCase>[
  // Dots are stripped from the local part on purpose: the paywall expects the
  // normalized form, so 'alice.smith' resolves to 'alicesmith'.
  (
    name: 'resolves one ecosystem destination for premium CTA consumers',
    ownerEmail: 'alice.smith@domain.tld',
    expectedUrl: 'https://paywall.domain.tld/alicesmith/domain.tld',
  ),
  // Pins the fallback: an owner email the session could not provide drops the
  // {localPart} placeholder instead of blocking the CTA.
  (
    name: 'drops the local part when the owner email is empty',
    ownerEmail: '',
    expectedUrl: 'https://paywall.domain.tld//domain.tld',
  ),
];

void _premiumCtaDestinationTests() {
  for (final destinationCase in _destinationCases) {
    test(destinationCase.name, () async {
      final state = await _resolveCtaForTemplate(
        _destinationTemplate,
        context: _upgradableContext(
          _firstTarget,
          owner: PremiumCtaOwner(
            email: destinationCase.ownerEmail,
            domainName: 'domain.tld',
          ),
        ),
      );

      expect(state, _availableCta(Uri.parse(destinationCase.expectedUrl)));
    });
  }

  test('prefers Workplace destination without fetching ecosystem', () {
    final repository = _succeedingRepository();
    final container = _createContainer(repository);
    container
        .read(workplaceFqdnProvider.notifier)
        .setFqdn('workplace.domain.tld');

    expect(
      container.read(premiumCtaProvider(_upgradableContext(_firstTarget))),
      _availableCta(Uri.parse('https://workplace.domain.tld/settings/premium')),
    );
    expect(repository.callCount, 0);
  });
}

void _premiumCtaUnavailableTests() {
  test('rejects an invalid ecosystem paywall destination', () async {
    expect(
      await _resolveCtaForTemplate('javascript:alert(1)'),
      _unavailableCta(PremiumCtaUnavailableReason.invalidDestination),
    );
  });

  test('reports when ecosystem paywall is not configured', () async {
    expect(
      await _resolveCtaForTemplate(null),
      _unavailableCta(PremiumCtaUnavailableReason.paywallNotConfigured),
    );
  });

  test('maps ecosystem load failures to unavailable CTA state', () async {
    final state = await _resolveCta(
      _EcosystemRepository((_) async => throw StateError('load failed')),
    );

    expect(
      state,
      _unavailableCta(PremiumCtaUnavailableReason.ecosystemUnavailable)
          .having((state) => state.error, 'error', isA<Failure>()),
    );
  });
}

void _premiumCtaGatingTests() {
  test('does not fetch ecosystem for the highest subscription', () {
    _expectCtaWithoutFetch(
      _premiumContext(
        _firstTarget,
        capability: _highestSubscriptionCapability(),
      ),
      PremiumCtaUnavailableReason.highestSubscription,
    );
  });

  test('does not fetch ecosystem without premium capability', () {
    _expectCtaWithoutFetch(
      _premiumContext(_firstTarget, capability: _lockedCapability()),
      PremiumCtaUnavailableReason.premiumNotAvailable,
    );
  });

  test('does not fetch ecosystem when SaaS capability is absent', () {
    _expectCtaWithoutFetch(
      _premiumContext(_firstTarget, capability: null),
      PremiumCtaUnavailableReason.premiumNotAvailable,
    );
  });

  test('does not fetch ecosystem without session and account context', () {
    _expectCtaWithoutFetch(null, PremiumCtaUnavailableReason.missingAccount);
  });
}

void _urgentFailureRoutingTests() {
  test('routes urgent ecosystem failures exactly once', () async {
    final exception = StateError('urgent');
    final handler = _registerUrgentExceptionHandler();
    final container = _createContainer(
      _EcosystemRepository((_) async => throw exception),
    );
    _keepEcosystemAlive(container, _firstTarget);

    await expectLater(
      _readEcosystem(container, _firstTarget),
      throwsA(isA<Failure>()),
    );

    expect(handler.handledCount, 1);
    expect(handler.lastException, same(exception));
  });

  test('routes urgent ecosystem stream errors exactly once', () async {
    final exception = Exception('urgent stream error');
    final handler = _registerUrgentExceptionHandler();
    final repository = _succeedingRepository();
    final container = _createContainer(
      repository,
      interactor: _StreamErrorEcosystemInteractor(repository, exception),
    );

    await expectLater(
      _readEcosystem(container, _firstTarget),
      throwsA(same(exception)),
    );

    expect(handler.handledCount, 1);
    expect(handler.lastException, same(exception));
  });
}

void _streamDisposalTests() {
  test('cancels the interactor stream after its terminal state', () async {
    final expected = _ecosystem(_paywallTemplate);
    final repository = _EcosystemRepository((_) async => expected);
    final interactor = _OpenEndedEcosystemInteractor(repository, expected);
    final container = _createContainer(repository, interactor: interactor);

    expect(
      await _readEcosystem(container, _firstTarget)
          .timeout(const Duration(seconds: 1)),
      same(expected),
    );
    expect(interactor.wasCancelled, isTrue);
  });

  test('drops urgent routing for a failure that lands after disposal',
      () async {
    final completer = Completer<LinagoraEcosystem>();
    final handler = _registerUrgentExceptionHandler();
    final container = _createContainer(
      _EcosystemRepository((_) => completer.future),
    );
    final subscription = container.listen(
      ecosystemProvider(_firstAccountId, _firstJmapUrl),
      _ignoreState,
      fireImmediately: true,
    );

    subscription.close();
    await container.pump();
    completer.completeError(StateError('failed after disposal'));
    await container.pump();

    expect(handler.handledCount, 0);
  });
}

void _degradedInputTests() {
  test('fails the ecosystem load on an unexpected interactor success', () {
    final repository = _succeedingRepository();
    final container = _createContainer(
      repository,
      interactor: _UnexpectedSuccessEcosystemInteractor(repository),
    );

    expect(
      _readEcosystem(container, _firstTarget),
      throwsA(isA<StateError>()),
    );
  });

  test('reports a missing account without touching the ecosystem', () {
    _expectEcosystemWithoutFetch(
      null,
      EcosystemUnavailableReason.missingAccount,
    );
  });
}

void _missingDependenciesTests() {
  test('fails closed when the ecosystem interactor is unavailable', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(premiumCtaProvider(_upgradableContext(_firstTarget))),
      _unavailableCta(PremiumCtaUnavailableReason.ecosystemUnavailable),
    );
    expect(
      container.read(activeEcosystemProvider(_firstAccountId, _firstJmapUrl)),
      _unavailableEcosystem(EcosystemUnavailableReason.dependencyUnavailable),
    );
  });
}

const _firstJmapUrl = 'https://first.domain.tld';
const _secondJmapUrl = 'https://second.domain.tld';
const _paywallTemplate = 'https://paywall.domain.tld/premium';
const _defaultOwner = PremiumCtaOwner(
  email: 'alice@domain.tld',
  domainName: 'domain.tld',
);
final _firstAccountId = AccountId(Id('first-account'));
final _secondAccountId = AccountId(Id('second-account'));

/// The account plus the server its ecosystem is fetched from — the pair every
/// helper needs, kept together instead of threaded as loose values.
typedef _EcosystemTarget = ({AccountId accountId, String? jmapUrl});

final _firstTarget = (accountId: _firstAccountId, jmapUrl: _firstJmapUrl);
final _secondTarget = (accountId: _secondAccountId, jmapUrl: _secondJmapUrl);
final _secondAccountOnFirstUrl =
    (accountId: _secondAccountId, jmapUrl: _firstJmapUrl);
final _targetWithoutJmapUrl = (accountId: _firstAccountId, jmapUrl: null);
final _targetWithBlankJmapUrl = (accountId: _firstAccountId, jmapUrl: '   ');

LinagoraEcosystem _ecosystem(String? template) => LinagoraEcosystem.deserialize(
      template == null ? {} : {'paywallUrlTemplate': template},
    );

_EcosystemRepository _succeedingRepository() =>
    _EcosystemRepository((_) async => _ecosystem(_paywallTemplate));

_EcosystemRepository _failingOnceRepository(LinagoraEcosystem ecosystem) {
  var shouldFail = true;
  return _EcosystemRepository((_) async {
    if (shouldFail) {
      shouldFail = false;
      throw StateError('first load failed');
    }
    return ecosystem;
  });
}

SaaSAccountCapability _upgradableCapability() =>
    SaaSAccountCapability(canUpgrade: true);

SaaSAccountCapability _highestSubscriptionCapability() =>
    SaaSAccountCapability(isPaying: true, canUpgrade: false);

SaaSAccountCapability _lockedCapability() =>
    SaaSAccountCapability(canUpgrade: false);

PremiumCtaContext _premiumContext(
  _EcosystemTarget target, {
  required SaaSAccountCapability? capability,
  PremiumCtaOwner owner = _defaultOwner,
}) =>
    PremiumCtaContext.tryCreate(
      session: _session(target.accountId, capability),
      accountId: target.accountId,
      owner: owner,
      jmapUrl: target.jmapUrl,
    )!;

PremiumCtaContext _upgradableContext(
  _EcosystemTarget target, {
  PremiumCtaOwner owner = _defaultOwner,
}) =>
    _premiumContext(
      target,
      capability: _upgradableCapability(),
      owner: owner,
    );

ProviderContainer _createContainer(
  _EcosystemRepository repository, {
  GetLinagoraEcosystemInteractor? interactor,
}) {
  final container = ProviderContainer(overrides: [
    getLinagoraEcosystemInteractorProvider.overrideWithValue(
      interactor ?? GetLinagoraEcosystemInteractor(repository),
    ),
  ]);
  addTearDown(container.dispose);
  return container;
}

/// The shared seam resolves the handler through GetX (ADR-0103), so urgent
/// routing is exercised the way production wires it.
_UrgentExceptionHandler _registerUrgentExceptionHandler() {
  final handler = _UrgentExceptionHandler(isUrgent: true);
  Get.testMode = true;
  Get.put<UrgentExceptionHandler>(handler);
  addTearDown(Get.reset);
  return handler;
}

void _ignoreState(Object? previous, Object? next) {}

void _keepAlive(ProviderSubscription<Object?> subscription) =>
    addTearDown(subscription.close);

// Fetch helpers only take targets that carry a JMAP URL; the URL-less targets
// exist for the states that must never reach a fetch.
void _keepEcosystemAlive(
  ProviderContainer container,
  _EcosystemTarget target,
) =>
    _keepAlive(container.listen(
      ecosystemProvider(target.accountId, target.jmapUrl!),
      _ignoreState,
      fireImmediately: true,
    ));

void _keepActiveEcosystemAlive(
  ProviderContainer container,
  _EcosystemTarget target,
) =>
    _keepAlive(container.listen(
      activeEcosystemProvider(target.accountId, target.jmapUrl),
      _ignoreState,
      fireImmediately: true,
    ));

void _keepPremiumCtaAlive(
  ProviderContainer container,
  PremiumCtaContext context,
) =>
    _keepAlive(container.listen(
      premiumCtaProvider(context),
      _ignoreState,
      fireImmediately: true,
    ));

Future<LinagoraEcosystem> _readEcosystem(
  ProviderContainer container,
  _EcosystemTarget target,
) =>
    container.read(
      ecosystemProvider(target.accountId, target.jmapUrl!).future,
    );

Future<PremiumCtaState> _resolveCtaForTemplate(
  String? template, {
  PremiumCtaContext? context,
}) =>
    _resolveCta(
      _EcosystemRepository((_) async => _ecosystem(template)),
      context: context,
    );

Future<PremiumCtaState> _resolveCta(
  _EcosystemRepository repository, {
  PremiumCtaContext? context,
}) async {
  final container = _createContainer(repository);
  final ctaContext = context ?? _upgradableContext(_firstTarget);
  _keepPremiumCtaAlive(container, ctaContext);

  await _readEcosystem(
    container,
    (accountId: ctaContext.accountId, jmapUrl: ctaContext.jmapUrl),
  )
      .then<void>((_) {}, onError: (Object _) {});
  await container.pump();

  return container.read(premiumCtaProvider(ctaContext));
}

void _expectEcosystemWithoutFetch(
  AccountId? accountId,
  EcosystemUnavailableReason reason,
) {
  final repository = _succeedingRepository();
  final container = _createContainer(repository);

  expect(
    container.read(activeEcosystemProvider(accountId, _firstJmapUrl)),
    _unavailableEcosystem(reason),
  );
  expect(repository.callCount, 0);
}

void _expectCtaWithoutFetch(
  PremiumCtaContext? context,
  PremiumCtaUnavailableReason reason,
) {
  final repository = _succeedingRepository();
  final container = _createContainer(repository);

  expect(container.read(premiumCtaProvider(context)), _unavailableCta(reason));
  expect(repository.callCount, 0);
}

TypeMatcher<PremiumCtaAvailable> _availableCta(Uri destination) =>
    isA<PremiumCtaAvailable>()
        .having((state) => state.destination, 'destination', destination);

TypeMatcher<PremiumCtaUnavailable> _unavailableCta(
  PremiumCtaUnavailableReason reason,
) =>
    isA<PremiumCtaUnavailable>()
        .having((state) => state.reason, 'reason', reason);

TypeMatcher<EcosystemUnavailable> _unavailableEcosystem(
  EcosystemUnavailableReason reason,
) =>
    isA<EcosystemUnavailable>()
        .having((state) => state.reason, 'reason', reason);

Session _session(AccountId accountId, SaaSAccountCapability? capability) {
  final capabilities = {
    if (capability != null) SessionExtensions.linagoraSaaSCapability: capability,
  };
  final uri = Uri.parse('https://domain.tld/jmap');
  return Session(
    capabilities,
    {
      accountId: Account(
        AccountName(_defaultOwner.email),
        true,
        false,
        capabilities,
      ),
    },
    {
      if (capability != null)
        SessionExtensions.linagoraSaaSCapability: accountId,
    },
    UserName(_defaultOwner.email),
    uri,
    uri,
    uri,
    uri,
    jmap.State('state-${accountId.id.value}'),
  );
}

class _EcosystemRepository implements LinagoraEcosystemRepository {
  Future<LinagoraEcosystem> Function(String baseUrl) onCall;
  int callCount = 0;

  _EcosystemRepository(this.onCall);

  @override
  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl) {
    callCount++;
    return onCall(baseUrl);
  }
}

class _StreamErrorEcosystemInteractor extends GetLinagoraEcosystemInteractor {
  final Object error;

  _StreamErrorEcosystemInteractor(
    LinagoraEcosystemRepository repository,
    this.error,
  ) : super(repository);

  @override
  Stream<Either<Failure, Success>> execute(String baseUrl) =>
      Stream.error(error, StackTrace.current);
}

class _UnexpectedSuccessEcosystemInteractor
    extends GetLinagoraEcosystemInteractor {
  _UnexpectedSuccessEcosystemInteractor(super.repository);

  @override
  Stream<Either<Failure, Success>> execute(String baseUrl) =>
      Stream.value(Right(UIState.idle));
}

class _OpenEndedEcosystemInteractor extends GetLinagoraEcosystemInteractor {
  final LinagoraEcosystem ecosystem;
  bool wasCancelled = false;

  _OpenEndedEcosystemInteractor(
    LinagoraEcosystemRepository repository,
    this.ecosystem,
  ) : super(repository);

  @override
  Stream<Either<Failure, Success>> execute(String baseUrl) {
    late StreamController<Either<Failure, Success>> controller;
    controller = StreamController<Either<Failure, Success>>(
      onListen: () {
        controller
          ..add(Right(GettingLinagoraEcosystem()))
          ..add(Right(GetLinagoraEcosystemSuccess(ecosystem)));
      },
      onCancel: () {
        wasCancelled = true;
      },
    );
    return controller.stream;
  }
}

class _UrgentExceptionHandler implements UrgentExceptionHandler {
  final bool isUrgent;
  int handledCount = 0;
  Object? lastException;

  _UrgentExceptionHandler({this.isUrgent = false});

  @override
  bool validateUrgentException(dynamic exception) => isUrgent;

  @override
  void handleUrgentException({Failure? failure, Exception? exception}) {
    handledCount++;
    lastException = failure is FeatureFailure ? failure.exception : exception;
  }
}
