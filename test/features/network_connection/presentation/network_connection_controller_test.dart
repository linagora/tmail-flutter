import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';

void main() {
  group('NetworkConnectionController.onInternetRestored', () {
    late NetworkConnectionController controller;
    late int restoredCount;

    setUp(() {
      controller = NetworkConnectionController(Connectivity());
      restoredCount = 0;
      controller.onInternetRestored.listen((_) => restoredCount++);
    });

    test('Should emit once WHEN the status turns connected', () async {
      controller.setInternetConnectivityStatus(InternetConnectionStatus.connected);
      await pumpEventQueue();

      expect(restoredCount, 1);
    });

    test('Should emit each time WHEN the internet is lost then back', () async {
      controller.setInternetConnectivityStatus(InternetConnectionStatus.connected);
      controller.setInternetConnectivityStatus(InternetConnectionStatus.disconnected);
      controller.setInternetConnectivityStatus(InternetConnectionStatus.connected);
      await pumpEventQueue();

      expect(restoredCount, 2);
    });

    test('Should not emit WHEN the internet is only lost', () async {
      controller.setInternetConnectivityStatus(InternetConnectionStatus.disconnected);
      await pumpEventQueue();

      expect(restoredCount, 0);
    });
  });

  group('NetworkConnectionController.isNetworkConnectionAvailable', () {
    late NetworkConnectionController controller;

    setUp(() => controller = NetworkConnectionController(Connectivity()));

    test('Should be available WHEN the internet was not probed yet', () {
      expect(controller.isNetworkConnectionAvailable(), isTrue);
    });

    test('Should be available WHEN the internet is connected', () {
      controller.setInternetConnectivityStatus(InternetConnectionStatus.connected);

      expect(controller.isNetworkConnectionAvailable(), isTrue);
    });

    test('Should not be available WHEN the internet is disconnected', () {
      controller.setInternetConnectivityStatus(InternetConnectionStatus.disconnected);

      expect(controller.isNetworkConnectionAvailable(), isFalse);
    });
  });
}
