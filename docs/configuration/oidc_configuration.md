## Configuration for OIDC

### Context
- Team Mail ready to work with OIDC both for Mobile and Web version

### How to config

- OIDC_SCOPES: Scopes of OIDC application, each scope is separated by a comma `,`
- Other configurations depend on the platform:

#### Web:
- `DOMAIN_REDIRECT_URL`:  URL of your TwakeMail web application
- `WEB_OIDC_CLIENT_ID`: Client ID of your OIDC application

#### Mobile:
- if you want to change client Id for mobile

For Android: 
- `/android/app/build.gradle`

```gradle
        manifestPlaceholders = [
                'appAuthRedirectScheme': 'teammail.mobile'
        ]
```

- `model/lib/oidc/oidc_configuration.dart`

```dart
  static const String redirectUrlScheme = 'teammail.mobile';
```

For iOS:
- `/ios/Runner/Info.plist`

```plist
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>teammail.mobile</string>
            </array>
        </dict>
    </array>
```