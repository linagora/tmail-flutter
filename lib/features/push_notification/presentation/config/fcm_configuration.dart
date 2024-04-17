
import 'dart:isolate';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/config/firebase_options.dart';

class FcmConfiguration {
  static FcmConfiguration? _instance;

  FcmConfiguration._();

  factory FcmConfiguration() => _instance ??= FcmConfiguration._();

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      logError('FcmConfiguration::initialize: Exception = $e');
    }
  }

  Future<void> initializeCrashlytics() async {
    try {
      const fatalError = true;
      // Non-async exceptions
      FlutterError.onError = (errorDetails) {
        if (fatalError) {
          // If you want to record a "fatal" exception
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
          // ignore: dead_code
        } else {
          // If you want to record a "non-fatal" exception
          FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
        }
      };
      // Async exceptions
      PlatformDispatcher.instance.onError = (error, stack) {
        if (fatalError) {
          // If you want to record a "fatal" exception
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          // ignore: dead_code
        } else {
          // If you want to record a "non-fatal" exception
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        return true;
      };

      // Errors outside of Flutter
      Isolate.current.addErrorListener(RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;

        if (fatalError) {
          // If you want to record a "fatal" exception
          await FirebaseCrashlytics.instance.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last,
            fatal: true,
          );
          // ignore: dead_code
        } else {
          // If you want to record a "non-fatal" exception
          await FirebaseCrashlytics.instance.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last
          );
        }
      }).sendPort);
    } catch (e) {
      logError('FcmConfiguration::initializeCrashlytics: Exception = $e');
    }
  }

  Future<void> recordError(Object error, StackTrace stack) async {
    try {
      return await FirebaseCrashlytics.instance.recordError(error, stack);
    } catch (e) {
      logError('FcmConfiguration::recordError: Exception = $e');
    }
  }

  // Use FirebaseCrashlytics to throw an error. Use this for confirmation that errors are being correctly reported.
  Future<void> reportCrash() async {
    FirebaseCrashlytics.instance.crash();
  }
}