## Configuration for App Grid

### Context
- Team Mail is a service inside Twake Workspace which include other services
- User need to access other services from Team Mail

### How to config

1. Add services to configuration file
 
- Each service have the information:
```
    {
      "appName": "Contacts",
      "icon": "ic_contacts_app.svg",
      "appLink": "https://openpaas.linagora.com/contacts/",
      "androidPackageId": "xxx",
      "iosUrlScheme": "xxx",
      "iosAppStoreLink": "xxx",
      "publicIconUri": "xxx"
    }
```

- All services must be added to the configuration file [configurations\app_dashboard.json](https://github.com/linagora/tmail-flutter/blob/master/configurations/app_dashboard.json)
For example:
```
{
  "apps": [
    {
      "appName": "Twake",
      "icon": "ic_twake_app.svg",
      "appLink": "http://twake.linagora.com/",
      "androidPackageId": "xxx",
      "iosUrlScheme": "xxx",
      "iosAppStoreLink": "xxx"
    },
    {
      "appName": "App 1",
      "icon": "ic_twake_app.svg",
      "appLink": "http://twake.linagora.com/",
      "androidPackageId": "xxx",
      "iosUrlScheme": "xxx",
      "iosAppStoreLink": "xxx"
    },
    {
      "appName": "App 2",
      "appLink": "http://twake.linagora.com/",
      "androidPackageId": "xxx",
      "iosUrlScheme": "xxx",
      "iosAppStoreLink": "xxx",
      "publicIconUri": "xxx"
    },
    ...
  ]
}
```

- `appName`: The name will be showed in App Grid
- `icon`: Name of icon was added in `configurations\icons` folder. If not, `publicIconUri` must be provided.
- `appLink`: Service URL
- `androidPackageId`: ApplicationId of android app
- `iosUrlScheme`: UrlScheme name of the ios app.
- `iosAppStoreLink`: iTunes link of the ios app. 
Allow navigate to store (appStore) if app is not found in the device. Example:
`itms-apps://itunes.apple.com/us/app/linshare/id1534003175` or `https://itunes.apple.com/us/app/linshare/id1534003175`
- `publicIconUri`: Public link for the icon, used when `icon` is null or empty.

2. Enable it in [env.file](https://github.com/linagora/tmail-flutter/blob/master/env.file)
```
APP_GRID_AVAILABLE=supported
```
If you want to disable it, please change the value to `unsupported` or remove this from `env.file`

3. Enable open app on mobile(Android/iOS)

- In `Android 11+` to open another app already installed, you have to add the package with name `ApplicationId`' in [AndroidManifest](https://github.com/linagora/tmail-flutter/blob/master/android/app/src/main/AndroidManifest.xml) inside `queries` tag. Example:
```
<queries>
   <package android:name="com.linagora.android.linshare" /> 
</queries>
```
- - In `iOS 9+` to open another app already installed, you have to add the `UrlScheme`' in [Info.plist](https://github.com/GeekyAnts/external_app_launcher/blob/master/example/ios/Runner/Info.plist) under the `LSApplicationQueriesSchemes` key. Example:
```
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>linshare.mobile</string>
</array>
```
