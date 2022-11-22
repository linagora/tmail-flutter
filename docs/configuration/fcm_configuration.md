## Configuration for App Grid

### Context
- Team Mail using FCM service
- User need config env for FCM service
- Now only support to Android
### How to config

1.Add environment of FCM service in [env.fcm](https://github.com/linagora/tmail-flutter/blob/master/configurations/env.fcm)
```
FIREBASE_ANDROID_API_KEY=abc
FIREBASE_ANDROID_APP_ID=abc
FIREBASE_ANDROID_MESSAGING_SENDER_ID=123
FIREBASE_ANDROID_PROJECT_ID=abc
FIREBASE_ANDROID_DATABASE_URL=https://abc.app
FIREBASE_ANDROID_STORAGE_BUCKET=abc.com
```
