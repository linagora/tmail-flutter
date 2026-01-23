import 'dart:ui';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';

/// Configures global error handlers for both Flutter framework and Platform dispatcher.
void setupErrorHooks() {
  // Handle Flutter Framework Errors (Rendering, Build, Layout, etc.)
  FlutterError.onError = (details) {
    logError(
      'FlutterError: ${details.exception}',
      exception: details.exception,
      stackTrace: details.stack,
    );
    // Show the "Red Screen of Death" in debug mode.
    FlutterError.presentError(details);
  };

  // Handle Asynchronous Errors (Futures, Streams, Platform Channels)
  PlatformDispatcher.instance.onError = (error, stack) {
    logError(
      'PlatformDispatcherError: $error',
      exception: error,
      stackTrace: stack,
    );
    // Return true to prevent the app from crashing.
    return true;
  };
}
