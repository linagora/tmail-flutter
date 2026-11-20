import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/delegation_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/services/local_settings_service.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';

class _FakeGetLocalSettingsInteractor implements GetLocalSettingsInteractor {
  final Either<Failure, Success> result;

  _FakeGetLocalSettingsInteractor(this.result);

  @override
  Stream<Either<Failure, Success>> execute() => Stream.value(result);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(() {
    appProviderContainer
      ..invalidate(localSettingsProvider)
      ..invalidate(localSettingsLoadedProvider);
  });

  Future<void> load(Either<Failure, Success> result) async {
    LocalSettingsService(_FakeGetLocalSettingsInteractor(result)).onInit();
    await pumpEventQueue();
  }

  test('marks the settings loaded with the saved values once they are read', () async {
    final saved = PreferencesSetting([DelegationConfig(isEnabled: true)]);

    await load(Right(GetLocalSettingsSuccess(saved)));

    expect(appProviderContainer.read(localSettingsProvider), saved);
    expect(appProviderContainer.read(localSettingsLoadedProvider), isTrue);
  });

  test('marks the settings loaded with the defaults when the read fails', () async {
    await load(Left(GetLocalSettingsFailure(exception: Exception('cache unreadable'))));

    expect(appProviderContainer.read(localSettingsProvider), PreferencesSetting.initial());
    expect(appProviderContainer.read(localSettingsLoadedProvider), isTrue);
  });

  test('SHOULD NOT mark the settings loaded before the read ends', () {
    expect(appProviderContainer.read(localSettingsLoadedProvider), isFalse);
  });
}
