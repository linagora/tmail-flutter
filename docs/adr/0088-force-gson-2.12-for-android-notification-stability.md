# 0088. Force Gson 2.12.0 to Fix Android Notification Crash

Date: 2026-05-13

## Status

Accepted

## Context

On Android release/profile builds, calling `FlutterLocalNotificationsPlugin.cancel()` consistently threw:

```
java.lang.RuntimeException: Missing type parameter.
    at TypeToken.<init>
    at FlutterLocalNotificationsPlugin.loadScheduledNotifications
    at FlutterLocalNotificationsPlugin.removeNotificationFromCache
    at FlutterLocalNotificationsPlugin.cancel
```

`cancel()` internally calls `loadScheduledNotifications()` on every invocation to update the SharedPreferences cache. That method uses:

```java
Type type = new TypeToken<ArrayList<NotificationDetails>>() {}.getType();
```

The anonymous `TypeToken` subclass carries its generic type argument (`ArrayList<NotificationDetails>`) in the bytecode `Signature` attribute. R8 strips `Signature` attributes from anonymous classes unless explicitly told not to.

`flutter_local_notifications` 17.2.2 depends on `com.google.code.gson:gson:2.8.9`, which ships **no ProGuard/R8 consumer rules**. With no rule protecting `Signature`, R8 strips it. Gson 2.8.9's `TypeToken` constructor calls `getSuperclassTypeParameter()`, sees a raw `Class` instead of a `ParameterizedType`, and throws `RuntimeException("Missing type parameter.")`.

This crashed `removeNotification()` and `removeGroupPushNotification()` on every call, propagating as an unhandled `PlatformException` to Dart and making Android push notifications completely unreliable.

## Decision

Add `com.google.code.gson:gson:2.12.0` as a direct dependency in `android/app/build.gradle`. Gradle's version resolution picks the highest declared version, overriding the transitive 2.8.9.

Gson 2.12.0 ships `META-INF/proguard/gson.pro` as consumer rules, automatically applied to the app's R8 config:

```proguard
-keepattributes Signature
-keep,allowobfuscation class * extends com.google.gson.reflect.TypeToken
```

This preserves generic signatures on all `TypeToken` subclasses, including the anonymous one in `loadScheduledNotifications`. The crash no longer occurs.

## Consequences

- `cancel()` succeeds on all Android builds; push notification removal is stable.
- The forced dependency must be revisited when upgrading `flutter_local_notifications` — version 19.5.0 already declares `gson:2.12.0` directly, making the override unnecessary.
