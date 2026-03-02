import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A base app that allows to show SnackBars on cupertino as well
///
/// Compare [CupertinoSnackApp]
class PlatformSnackApp extends StatelessWidget {
  const PlatformSnackApp({
    super.key,
    this.widgetKey,
    this.navigatorKey,
    this.home,
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.routes = const <String, WidgetBuilder>{},
    this.onGenerateTitle,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.title = '',
    this.color,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
    this.scaffoldMessengerKey,
    this.cupertinoTheme,
    this.materialThemeMode = ThemeMode.system,
    this.materialTheme,
    this.materialDarkTheme,
    this.materialHighContrastTheme,
    this.materialHighContrastDarkTheme,
    this.materialThemeAnimationCurve = Curves.linear,
    this.materialThemeAnimationDuration = kThemeAnimationDuration,
  })  : _isRouter = false,
        backButtonDispatcher = null,
        routerConfig = null,
        routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null;

  PlatformSnackApp.router({
    super.key,
    this.widgetKey,
    this.backButtonDispatcher,
    this.routerConfig,
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.onGenerateTitle,
    this.builder,
    this.title = '',
    this.color,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
    this.scaffoldMessengerKey,
    this.cupertinoTheme,
    this.materialThemeMode = ThemeMode.system,
    this.materialTheme,
    this.materialDarkTheme,
    this.materialHighContrastTheme,
    this.materialHighContrastDarkTheme,
    this.materialThemeAnimationCurve = Curves.linear,
    this.materialThemeAnimationDuration = kThemeAnimationDuration,
  })  : _isRouter = true,
        routes = const <String, WidgetBuilder>{},
        initialRoute = null,
        onGenerateRoute = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        navigatorKey = null,
        home = null,
        navigatorObservers = const <NavigatorObserver>[];

  final Key? widgetKey;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final GlobalKey<NavigatorState>? navigatorKey;
  final Widget? home;
  final String? initialRoute;
  final Route Function(RouteSettings)? onGenerateRoute;
  final List<Route> Function(String)? onGenerateInitialRoutes;
  final Route Function(RouteSettings)? onUnknownRoute;
  final Map<String, Widget Function(BuildContext)> routes;
  final String Function(BuildContext)? onGenerateTitle;
  final List<NavigatorObserver> navigatorObservers;
  final Widget Function(BuildContext, Widget?)? builder;
  final String title;
  final Color? color;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Locale? Function(List<Locale>?, Iterable<Locale>)?
      localeListResolutionCallback;
  final Locale? Function(Locale?, Iterable<Locale>)? localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final Map<LogicalKeySet, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final String? restorationScopeId;
  final ScrollBehavior? scrollBehavior;
  final CupertinoThemeData? cupertinoTheme;
  final ThemeMode? materialThemeMode;
  final ThemeData? materialTheme;
  final ThemeData? materialDarkTheme;
  final ThemeData? materialHighContrastTheme;
  final ThemeData? materialHighContrastDarkTheme;
  final Curve materialThemeAnimationCurve;
  final Duration materialThemeAnimationDuration;
  final RouteInformationProvider? routeInformationProvider;
  final RouteInformationParser<Object>? routeInformationParser;
  final RouterDelegate<Object>? routerDelegate;
  final BackButtonDispatcher? backButtonDispatcher;
  final RouterConfig<Object>? routerConfig;

  final bool _isRouter;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => _isRouter
          ? MaterialApp.router(
              key: widgetKey,
              scaffoldMessengerKey: scaffoldMessengerKey,
              builder: builder,
              backButtonDispatcher: backButtonDispatcher,
              routerConfig: routerConfig,
              routeInformationParser: routeInformationParser,
              routeInformationProvider: routeInformationProvider,
              routerDelegate: routerDelegate,
              title: title,
              onGenerateTitle: onGenerateTitle,
              color: color,
              locale: locale,
              localizationsDelegates: localizationsDelegates,
              localeResolutionCallback: localeResolutionCallback,
              localeListResolutionCallback: localeListResolutionCallback,
              supportedLocales: supportedLocales,
              showPerformanceOverlay: showPerformanceOverlay,
              checkerboardRasterCacheImages: checkerboardRasterCacheImages,
              checkerboardOffscreenLayers: checkerboardOffscreenLayers,
              showSemanticsDebugger: showSemanticsDebugger,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner,
              shortcuts: shortcuts,
              actions: actions,
              restorationScopeId: restorationScopeId,
              scrollBehavior: scrollBehavior,
              themeMode: materialThemeMode,
              theme: materialTheme,
              darkTheme: materialDarkTheme,
              highContrastTheme: materialHighContrastTheme,
              highContrastDarkTheme: materialHighContrastDarkTheme,
              themeAnimationCurve: materialThemeAnimationCurve,
              themeAnimationDuration: materialThemeAnimationDuration,
            )
          : MaterialApp(
              key: widgetKey,
              scaffoldMessengerKey: scaffoldMessengerKey,
              navigatorKey: navigatorKey,
              navigatorObservers: navigatorObservers,
              home: home,
              routes: routes,
              initialRoute: initialRoute,
              onGenerateRoute: onGenerateRoute,
              onGenerateInitialRoutes: onGenerateInitialRoutes,
              onUnknownRoute: onUnknownRoute,
              builder: builder,
              title: title,
              onGenerateTitle: onGenerateTitle,
              color: color,
              locale: locale,
              localizationsDelegates: localizationsDelegates,
              localeResolutionCallback: localeResolutionCallback,
              localeListResolutionCallback: localeListResolutionCallback,
              supportedLocales: supportedLocales,
              showPerformanceOverlay: showPerformanceOverlay,
              checkerboardRasterCacheImages: checkerboardRasterCacheImages,
              checkerboardOffscreenLayers: checkerboardOffscreenLayers,
              showSemanticsDebugger: showSemanticsDebugger,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner,
              shortcuts: shortcuts,
              actions: actions,
              restorationScopeId: restorationScopeId,
              scrollBehavior: scrollBehavior,
              themeMode: materialThemeMode,
              theme: materialTheme,
              darkTheme: materialDarkTheme,
              highContrastTheme: materialHighContrastTheme,
              highContrastDarkTheme: materialHighContrastDarkTheme,
              themeAnimationCurve: materialThemeAnimationCurve,
              themeAnimationDuration: materialThemeAnimationDuration,
            ),
      cupertino: (context, platform) => _isRouter
          ? CupertinoSnackApp.router(
              widgetKey: widgetKey,
              scaffoldMessengerKey: scaffoldMessengerKey,
              backButtonDispatcher: backButtonDispatcher,
              routerConfig: routerConfig,
              routeInformationParser: routeInformationParser,
              routeInformationProvider: routeInformationProvider,
              routerDelegate: routerDelegate,
              builder: builder,
              title: title,
              onGenerateTitle: onGenerateTitle,
              color: color,
              locale: locale,
              localizationsDelegates: localizationsDelegates,
              localeResolutionCallback: localeResolutionCallback,
              localeListResolutionCallback: localeListResolutionCallback,
              supportedLocales: supportedLocales,
              showPerformanceOverlay: showPerformanceOverlay,
              checkerboardRasterCacheImages: checkerboardRasterCacheImages,
              checkerboardOffscreenLayers: checkerboardOffscreenLayers,
              showSemanticsDebugger: showSemanticsDebugger,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner,
              shortcuts: shortcuts,
              actions: actions,
              restorationScopeId: restorationScopeId,
              scrollBehavior: scrollBehavior,
              theme: cupertinoTheme,
            )
          : CupertinoSnackApp(
              widgetKey: widgetKey,
              scaffoldMessengerKey: scaffoldMessengerKey,
              navigatorKey: navigatorKey,
              navigatorObservers: navigatorObservers,
              home: home,
              routes: routes,
              initialRoute: initialRoute,
              onGenerateRoute: onGenerateRoute,
              onGenerateInitialRoutes: onGenerateInitialRoutes,
              onUnknownRoute: onUnknownRoute,
              builder: builder,
              title: title,
              onGenerateTitle: onGenerateTitle,
              color: color,
              locale: locale,
              localizationsDelegates: localizationsDelegates,
              localeResolutionCallback: localeResolutionCallback,
              localeListResolutionCallback: localeListResolutionCallback,
              supportedLocales: supportedLocales,
              showPerformanceOverlay: showPerformanceOverlay,
              checkerboardRasterCacheImages: checkerboardRasterCacheImages,
              checkerboardOffscreenLayers: checkerboardOffscreenLayers,
              showSemanticsDebugger: showSemanticsDebugger,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner,
              shortcuts: shortcuts,
              actions: actions,
              restorationScopeId: restorationScopeId,
              scrollBehavior: scrollBehavior,
              theme: cupertinoTheme,
            ),
    );
  }
}
