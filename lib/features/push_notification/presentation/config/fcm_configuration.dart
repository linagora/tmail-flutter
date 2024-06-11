
import 'dart:isolate';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/config/firebase_options.dart';

class FcmConfiguration {
  static FcmConfiguration? _instance;

  FcmConfiguration._();

  factory FcmConfiguration() => _instance ??= FcmConfiguration._();

  static FirebaseCrashlytics _firebaseCrashlytics = FirebaseCrashlytics.instance;
  static FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      await Future.wait([
        _initializeCrashlytics(),
        _initializeAnalytics(),
      ]);
    } catch (e) {
      logError('FcmConfiguration::initialize: Exception = $e');
    }
  }

  @visibleForTesting
  set firebaseCrashlytics(FirebaseCrashlytics value) {
    _firebaseCrashlytics = value;
  }

  @visibleForTesting
  set firebaseAnalytics(FirebaseAnalytics value) {
    _firebaseAnalytics = value;
  }

  Future<void> _initializeCrashlytics() async {
    try {
      const fatalError = true;
      // Non-async exceptions
      FlutterError.onError = (errorDetails) {
        if (fatalError) {
          // If you want to record a "fatal" exception
          _firebaseCrashlytics.recordFlutterFatalError(errorDetails);
          // ignore: dead_code
        } else {
          // If you want to record a "non-fatal" exception
          _firebaseCrashlytics.recordFlutterError(errorDetails);
        }
      };
      // Async exceptions
      PlatformDispatcher.instance.onError = (error, stack) {
        if (fatalError) {
          // If you want to record a "fatal" exception
          _firebaseCrashlytics.recordError(error, stack, fatal: true);
          // ignore: dead_code
        } else {
          // If you want to record a "non-fatal" exception
          _firebaseCrashlytics.recordError(error, stack);
        }
        return true;
      };

      // Errors outside of Flutter
      Isolate.current.addErrorListener(RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;

        if (fatalError) {
          // If you want to record a "fatal" exception
          await _firebaseCrashlytics.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last,
            fatal: true,
          );
          // ignore: dead_code
        } else {
          // If you want to record a "non-fatal" exception
          await _firebaseCrashlytics.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last
          );
        }
      }).sendPort);
    } catch (e) {
      logError('FcmConfiguration::initializeCrashlytics: Exception = $e');
    }
  }

  Future<void> _initializeAnalytics({bool enable = true}) async {
    try {
      await _firebaseAnalytics.setAnalyticsCollectionEnabled(enable);
    } catch (e) {
      logError('FcmConfiguration::initializeAnalytics: Exception = $e');
    }
  }

  Future<void> recordError(Object error, StackTrace stack) async {
    try {
      return await _firebaseCrashlytics.recordError(error, stack);
    } catch (e) {
      logError('FcmConfiguration::recordError: Exception = $e');
    }
  }

  // Use FirebaseCrashlytics to throw an error. Use this for confirmation that errors are being correctly reported.
  Future<void> reportCrash() async {
    _firebaseCrashlytics.crash();
  }

  // Use FirebaseCrashlytics to log error
  Future<void> logError(String message) async {
    await _firebaseCrashlytics.log(message);
  }

  // Use FirebaseAnalytics to log event
  Future<void> logEvent({required String name, required String message}) async {
    await _firebaseAnalytics.logEvent(
      name: name,
      parameters: <String, dynamic>{
        'message': message,
      }
    );
  }

  // Use FirebaseAnalytics to current screen
  Future<void> logCurrentScreen({required String screenName, required String screenClass}) async {
    await _firebaseAnalytics.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenClass,
    );
  }

  // Use FirebaseAnalytics to current screen
  Future<void> logUserProperty({required String name, required String value}) async {
    await _firebaseAnalytics.setUserProperty(name: name, value: value);
  }
}