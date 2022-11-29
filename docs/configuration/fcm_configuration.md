## Configuration for FCM

### Context
- Team Mail using FCM service
- User need config env for FCM service
- Now only support to Android
### How to config
1.Add environment of FCM service in [env.fcm](https://github.com/linagora/tmail-flutter/blob/master/configurations/env.fcm)
Android config:
```
FIREBASE_ANDROID_API_KEY=abc
FIREBASE_ANDROID_APP_ID=abc
FIREBASE_ANDROID_MESSAGING_SENDER_ID=123
FIREBASE_ANDROID_PROJECT_ID=abc
FIREBASE_ANDROID_DATABASE_URL=https://abc.app
FIREBASE_ANDROID_STORAGE_BUCKET=abc.com
```
Web config:
```
FIREBASE_WEB_API_KEY=abc
FIREBASE_WEB_APP_ID=abc
FIREBASE_WEB_MESSAGING_SENDER_ID=abc
FIREBASE_WEB_PROJECT_ID=abc
FIREBASE_WEB_DATABASE_URL=https://abc.app
FIREBASE_WEB_STORAGE_BUCKET=abc.com
FIREBASE_WEB_AUTH_DOMAIN=abc.com
FIREBASE_WEB_VAPID_PUBLIC_KEY=abc
```
2. Active field FCM_AVAILABLE in [env.file](https://github.com/linagora/tmail-flutter/blob/master/env.file)
```
FCM_AVAILABLE=supported
```