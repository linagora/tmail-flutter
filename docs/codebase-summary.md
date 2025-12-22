# Codebase Summary

**Last Updated**: 2026-01-21
**Version**: 0.23.1
**Project**: Twake Mail (TMail) Flutter Application
**Repository**: https://github.com/linagora/tmail-flutter

## Overview

Twake Mail (TMail) is a multi-platform mobile and web email application implementing the JMAP (JSON Meta Application Protocol) standard. Developed by Linagora, it provides modern email capabilities across Android, iOS, and web platforms using Flutter framework. The application connects to JMAP servers and offers enhanced features through the Twake Mail backend.

### Why JMAP?

TMail uses JMAP instead of traditional IMAP because:
- **Modern Protocol**: Built for today's mobile-first world with real-time sync
- **Efficient**: Reduces bandwidth and latency compared to chatty IMAP extensions
- **Standards-Based**: Uses HTTP and JSON for easier development
- **Better Sync**: Proper synchronization primitives for mobile applications

## Project Structure

```
tmail-flutter/
├── lib/                          # Main application source
│   ├── features/                # Feature modules (Clean Architecture)
│   │   ├── base/               # Base classes and shared logic
│   │   ├── home/               # Main dashboard and navigation
│   │   ├── login/              # Authentication flows
│   │   ├── mailbox/            # Mailbox management
│   │   ├── mailbox_dashboard/  # Mailbox UI components
│   │   ├── email/              # Email viewing and management
│   │   ├── thread/             # Email thread list view
│   │   ├── thread_detail/      # Thread detail view (CRITICAL for rendering)
│   │   ├── composer/           # Email composition
│   │   ├── search/             # Email and mailbox search
│   │   ├── contact/            # Contact management
│   │   ├── labels/             # Label/tag management
│   │   ├── push_notification/  # FCM and WebSocket notifications
│   │   ├── offline_mode/       # Offline data handling (Hive)
│   │   ├── manage_account/     # Account settings
│   │   ├── identity_creator/   # Email identity management
│   │   ├── quotas/             # Storage quota display
│   │   ├── server_settings/    # Server configuration
│   │   ├── email_recovery/     # Deleted email recovery
│   │   ├── rules_filter_creator/ # Email filtering rules
│   │   ├── caching/            # Cache management
│   │   ├── starting_page/      # Initial app screen
│   │   ├── unknown_route_page/ # 404 page
│   │   ├── download/           # File download management
│   │   ├── upload/             # File upload management
│   │   ├── public_asset/       # Public asset handling
│   │   ├── sending_queue/      # Email sending queue
│   │   ├── mailto/             # mailto: URI handling
│   │   ├── network_connection/ # Network status monitoring
│   │   ├── destination_picker/ # File destination picker
│   │   ├── cleanup/            # Cache cleanup
│   │   └── paywall/            # Paywall feature
│   ├── main/                    # Application entry points
│   │   ├── bindings/           # Dependency injection (GetX)
│   │   ├── deep_links/         # Deep link handling
│   │   ├── error/              # Error handling
│   │   ├── exceptions/         # Custom exceptions
│   │   ├── localizations/      # i18n support
│   │   ├── pages/              # Route configuration
│   │   ├── permissions/        # Permission handling
│   │   ├── routes/             # Route definitions
│   │   ├── universal_import/   # Platform-specific imports
│   │   ├── utils/              # Utility functions
│   │   ├── app_runner.dart     # App initialization with monitoring
│   │   └── main_entry.dart     # Main entry function
│   ├── l10n/                    # Localization files
│   └── main.dart                # Application bootstrap
├── core/                         # Core business logic module
│   ├── data/                    # Data layer implementations
│   ├── domain/                  # Domain models and interfaces
│   ├── presentation/            # Shared presentation logic
│   └── utils/                   # Core utilities
├── model/                        # Shared data models
├── contact/                      # Contact feature module
├── labels/                       # Labels feature module
├── rule_filter/                  # Rule filter module
├── forward/                      # Email forwarding module
├── fcm/                          # Firebase Cloud Messaging module
├── email_recovery/               # Email recovery module
├── server_settings/              # Server settings module
├── cozy/                         # Cozy integration
├── scribe/                       # AI assistant integration
├── android/                      # Android platform code
├── ios/                          # iOS platform code
├── web/                          # Web platform code
├── assets/                       # Images, icons, animations
├── configurations/               # App configuration files
├── docs/                         # Documentation
├── scripts/                      # Build and utility scripts
├── test/                         # Unit tests
├── integration_test/             # Integration tests
├── backend-docker/               # Docker setup for backend testing
├── env.file                      # Environment configuration
└── pubspec.yaml                  # Flutter dependencies
```

## Core Technologies

### Framework & Language
- **Flutter**: 3.0+ (multi-platform framework)
- **Dart**: >=3.0.0 <4.0.0
- **SDK**: Android, iOS, Web

### Key Dependencies

**State Management & Architecture**:
- **GetX** (4.6.6): State management, dependency injection, routing
- **Dartz** (0.10.1): Functional programming (Either, Option)

**JMAP Protocol**:
- **jmap_dart_client**: JMAP protocol implementation (from Linagora)

**Email Composition**:
- **rich_text_composer**: Rich text editing
- **html_editor_enhanced**: HTML email editing

**Data & Caching**:
- **hive_ce** (2.11.3): Local NoSQL database (offline mode)
- **shared_preferences** (2.5.3): Key-value storage
- **dio** (5.2.0): HTTP client

**UI Components**:
- **flutter_svg** (2.1.0): SVG rendering
- **linagora_design_flutter**: Design system components
- **dropdown_button2** (2.0.0): Enhanced dropdowns
- **flutter_staggered_grid_view** (0.6.2): Grid layouts
- **flutter_portal** (1.1.3): Overlay positioning

**Authentication**:
- **flutter_appauth** (9.0.1): OAuth 2.0 / OpenID Connect
- **flutter_web_auth_2** (4.1.0): Web authentication

**Push Notifications**:
- **firebase_core** (2.11.0): Firebase SDK
- **firebase_messaging** (14.5.0): FCM push notifications
- **flutter_local_notifications** (17.2.2): Local notifications
- **web_socket_channel** (3.0.3): WebSocket for push

**File Handling**:
- **file_picker** (10.2.0): File selection
- **flutter_downloader** (1.12.0): Background downloads
- **share_plus** (7.2.1): File sharing
- **open_file** (3.5.10): File opening
- **permission_handler** (12.0.1): Runtime permissions

**Utilities**:
- **url_launcher** (6.3.1): Open external URLs
- **timeago** (3.7.1): Relative time formatting
- **rxdart** (0.27.7): Reactive programming extensions
- **connectivity_plus** (4.0.0): Network connectivity
- **uuid** (3.0.7): UUID generation
- **collection** (1.19.1): Collection utilities
- **html** (0.15.3): HTML parsing
- **intl** (0.20.2): Internationalization
- **flutter_linkify** (6.0.0): Link detection

**Error Tracking**:
- **sentry_flutter** (9.8.0): Error monitoring
- **sentry_dio** (9.8.0): Dio integration

**Testing**:
- **patrol** (3.19.0): UI testing framework
- **mockito** (5.4.4): Mocking framework

## Architectural Patterns

### Clean Architecture

TMail follows Clean Architecture with clear separation of concerns:

```
Feature Structure:
lib/features/[feature]/
├── data/              # Data layer
│   ├── datasource/   # API and local data sources
│   ├── model/        # Data transfer objects
│   ├── network/      # API services
│   └── repository/   # Repository implementations
├── domain/            # Business logic layer
│   ├── model/        # Domain entities
│   ├── repository/   # Repository interfaces
│   ├── state/        # Use case result states
│   ├── usecases/     # Business logic use cases (Interactors)
│   └── extensions/   # Domain extensions
└── presentation/      # UI layer
    ├── controller/   # GetX controllers
    ├── model/        # Presentation models
    ├── widgets/      # UI widgets
    ├── bindings/     # Dependency injection
    ├── styles/       # UI styles
    └── extensions/   # Presentation extensions
```

### Key Architectural Components

**1. Base Classes** (`lib/features/base/`):
- **BaseController**: Foundation for all controllers
  - Session management
  - Account handling
  - Capability checking
  - Logout flow
  - Error handling
  - State emission
- **BaseMailboxController**: Extension for mailbox operations
  - Mailbox state management
  - Folder operations
  - Thread management
  - Email rendering coordination

**2. State Management (GetX)**:
- Controllers manage feature state
- Bindings handle dependency injection
- Reactive UI updates via Obx/GetBuilder
- Navigation managed through Get.toNamed()

**3. Use Cases (Interactors)**:
- Each use case encapsulates single business operation
- Returns Either<Failure, Success> using Dartz
- Interactors are injected via bindings
- Example: `GetMailboxInteractor`, `SendEmailInteractor`

**4. Repository Pattern**:
- Interface in domain layer
- Implementation in data layer
- Supports multiple data sources (network, cache, local)
- Example: `MailboxRepository`, `EmailRepository`

**5. Offline Mode** (`lib/features/offline_mode/`):
- **Hive Database**: Local NoSQL storage
- **HiveWorker**: Background sync operations
- Caches emails, mailboxes, and metadata
- Syncs when online

## Entry Points & Build Flavors

### Main Entry Point
**File**: `/Users/datph/FlutterProject/tmail-flutter/lib/main.dart`

```dart
Future<void> main() async {
  await runAppWithMonitoring(runTmail); // Sentry monitoring
}

class TMailApp extends StatefulWidget {
  // GetMaterialApp with:
  // - Localization support (40+ languages)
  // - Custom theme
  // - Route management
  // - Deep link handling (mobile)
}
```

### Application Initialization Flow

1. **main.dart** → Calls `runAppWithMonitoring()`
2. **app_runner.dart** → Initializes monitoring (Sentry)
3. **main_entry.dart** → Bootstraps dependencies, initializes services
4. **TMailApp** → Starts GetMaterialApp with routing
5. **MainBindings** → Injects core dependencies
6. **Home/StartingPage** → Initial route based on auth state

### Platform-Specific Entry Points

**Android**: `android/app/src/main/kotlin/.../MainActivity.kt`
**iOS**: `ios/Runner/AppDelegate.swift`
**Web**: `web/index.html` + requires `env.file` with `SERVER_URL`

### Environment Configuration

**File**: `env.file` (root directory)
```
SERVER_URL=http://your-jmap-server.domain
```

Required for web builds to specify JMAP backend server.

## Key Features & Modules

### 1. Email Rendering (`thread_detail/`)
**CRITICAL MODULE** for displaying email content:
- Handles HTML email rendering
- Manages thread view state
- Coordinates with mailbox controller
- Known issues: Content not rendering when switching folders with thread view enabled

### 2. Authentication (`login/`)
- **OAuth 2.0 / OIDC**: Primary authentication method
- **Basic Auth**: Fallback authentication
- Supports multiple identity providers
- Token refresh and management
- Deep link authentication callback

### 3. Mailbox Management (`mailbox/`, `mailbox_dashboard/`)
- Folder hierarchy display
- Drag-and-drop organization
- Folder creation/deletion
- Unread count badges
- Search within mailbox

### 4. Email Composition (`composer/`)
- Rich text editing
- HTML email support
- Attachments (add, remove, preview)
- Drag-and-drop attachments
- Recipients autocomplete
- Draft saving
- Send queue for offline

### 5. Search (`search/`)
- Email content search
- Mailbox search
- Advanced filters
- Quick search suggestions

### 6. Labels (`labels/`)
- Custom labels/tags
- Color-coded organization
- Multi-label assignment
- Label management

### 7. Push Notifications (`push_notification/`)
- **Firebase Cloud Messaging (FCM)**: Mobile push
- **WebSocket**: Real-time updates (when supported by server)
- Background notifications
- Notification actions (reply, archive)

### 8. Contact Management (`contact/`)
- Contact list from device
- Contact autocomplete
- Contact details view
- Integration with compose

### 9. Offline Mode (`offline_mode/`)
- Local caching with Hive
- Background sync
- Queue email sends
- Conflict resolution

### 10. Email Rules (`rules_filter_creator/`)
- Create filtering rules
- Conditions and actions
- Automatic email organization

## Important Files & Their Purposes

### Core Application Files

| File Path | Purpose |
|-----------|---------|
| `/Users/datph/FlutterProject/tmail-flutter/lib/main.dart` | Application bootstrap and main widget |
| `/Users/datph/FlutterProject/tmail-flutter/lib/main/main_entry.dart` | Initialization logic and dependency setup |
| `/Users/datph/FlutterProject/tmail-flutter/lib/main/app_runner.dart` | Monitoring and error tracking setup |
| `/Users/datph/FlutterProject/tmail-flutter/lib/features/base/base_controller.dart` | Foundation controller with common logic |
| `/Users/datph/FlutterProject/tmail-flutter/lib/features/base/base_mailbox_controller.dart` | Mailbox-specific controller logic |

### Configuration Files

| File Path | Purpose |
|-----------|---------|
| `/Users/datph/FlutterProject/tmail-flutter/pubspec.yaml` | Flutter dependencies and app metadata |
| `/Users/datph/FlutterProject/tmail-flutter/env.file` | Environment configuration (SERVER_URL for web) |
| `/Users/datph/FlutterProject/tmail-flutter/android/app/build.gradle` | Android build configuration |
| `/Users/datph/FlutterProject/tmail-flutter/ios/Podfile` | iOS dependencies |

### Module Package Files

| Module | pubspec.yaml Location |
|--------|----------------------|
| Core | `/Users/datph/FlutterProject/tmail-flutter/core/pubspec.yaml` |
| Model | `/Users/datph/FlutterProject/tmail-flutter/model/pubspec.yaml` |
| Contact | `/Users/datph/FlutterProject/tmail-flutter/contact/pubspec.yaml` |
| Labels | `/Users/datph/FlutterProject/tmail-flutter/labels/pubspec.yaml` |
| Rule Filter | `/Users/datph/FlutterProject/tmail-flutter/rule_filter/pubspec.yaml` |
| Forward | `/Users/datph/FlutterProject/tmail-flutter/forward/pubspec.yaml` |
| FCM | `/Users/datph/FlutterProject/tmail-flutter/fcm/pubspec.yaml` |
| Email Recovery | `/Users/datph/FlutterProject/tmail-flutter/email_recovery/pubspec.yaml` |
| Server Settings | `/Users/datph/FlutterProject/tmail-flutter/server_settings/pubspec.yaml` |
| Cozy | `/Users/datph/FlutterProject/tmail-flutter/cozy/pubspec.yaml` |
| Scribe | `/Users/datph/FlutterProject/tmail-flutter/scribe/pubspec.yaml` |

### Build Scripts

| Script | Purpose |
|--------|---------|
| `/Users/datph/FlutterProject/tmail-flutter/scripts/prebuild.sh` | Pre-build setup (code generation, assets) |

## Development Workflow

### Build Process

1. **Pre-build**: Run `scripts/prebuild.sh` to:
   - Generate code (JSON serialization, Hive adapters)
   - Process assets
   - Setup platform-specific configurations

2. **Platform Builds**:
   ```bash
   # iOS
   flutter build ios

   # Android
   flutter build apk

   # Web (requires env.file with SERVER_URL)
   flutter build web
   ```

### Code Generation

```bash
# Generate code for JSON, Hive, etc.
flutter pub run build_runner build --delete-conflicting-outputs
```

### Localization

Translations available via Weblate:
https://hosted.weblate.org/projects/linagora/teammail/

Supported languages: 40+ (see `lib/l10n/`)

### Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Patrol tests (UI testing)
patrol test
```

## Navigation & Routing

### Route Management (GetX)

**File**: `/Users/datph/FlutterProject/tmail-flutter/lib/main/routes/app_routes.dart`

Main routes:
- `/home` - Main dashboard
- `/login` - Authentication
- `/mailbox` - Mailbox view
- `/email` - Email detail
- `/composer` - Compose email
- `/search` - Search view
- `/settings` - Account settings

### Deep Links

**Mobile**: Handled via `DeepLinksManager`
- `mailto:` URIs
- Authentication callbacks
- Shared content

**Web**: URL-based routing

## State Management Details

### GetX Controllers

Controllers extend `BaseController` or `BaseMailboxController` and handle:
- Business logic execution
- State updates via reactive variables (`.obs`)
- View updates via `update()` or reactive streams
- Navigation via `Get.toNamed()`, `Get.back()`, etc.

### Reactive Variables

```dart
// Observable variables
final unreadCount = 0.obs;
final selectedMailbox = Rxn<Mailbox>();

// Computed values
int get totalEmails => mailboxes.fold(0, (sum, m) => sum + m.totalEmails);
```

### Bindings (Dependency Injection)

Each feature defines bindings to inject dependencies:

```dart
class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController(
      Get.find<GetMailboxInteractor>(),
      Get.find<GetEmailInteractor>(),
    ));
  }
}
```

## Data Flow

### Typical Flow for User Action

1. **User Interaction** → Widget triggers controller method
2. **Controller** → Calls use case (interactor)
3. **Use Case** → Executes business logic via repository
4. **Repository** → Fetches from network or cache
5. **Response** → Returns `Either<Failure, Success>`
6. **Controller** → Updates state based on result
7. **Widget** → Reactively rebuilds with new state

### Example: Load Mailboxes

```dart
// 1. Controller
await _getMailboxInteractor.execute()
  .then((result) {
    result.fold(
      (failure) => _handleFailure(failure),
      (success) => _handleSuccess(success),
    );
  });

// 2. Use Case
class GetMailboxInteractor {
  Either<Failure, Success> execute() {
    return _mailboxRepository.getAll();
  }
}

// 3. Repository
class MailboxRepositoryImpl {
  Either<Failure, Success> getAll() {
    // Try cache first
    // Then network
    // Update cache
  }
}
```

## Local Modules

TMail uses local Flutter packages for modular organization:

- **core**: Shared business logic, UI components, utilities
- **model**: Domain entities and data models
- **contact**: Contact management feature
- **labels**: Label/tag management
- **rule_filter**: Email filtering rules
- **forward**: Email forwarding
- **fcm**: Firebase Cloud Messaging
- **email_recovery**: Deleted email recovery
- **server_settings**: Server configuration
- **cozy**: Cozy Drive integration
- **scribe**: AI writing assistant

Each module has its own `pubspec.yaml` and can be developed independently.

## Common Development Tasks

### Adding a New Feature

1. Create feature directory in `lib/features/[feature_name]/`
2. Implement Clean Architecture layers:
   - `data/`: Data sources, repositories
   - `domain/`: Use cases, models, interfaces
   - `presentation/`: Controllers, widgets, bindings
3. Define routes in `lib/main/routes/`
4. Create page registration in `lib/main/pages/app_pages.dart`
5. Add bindings for dependency injection
6. Write tests

### Fixing Email Rendering Issues

**Key Areas** (based on current bug context):
- `lib/features/thread_detail/`: Thread detail view controller
- `lib/features/base/base_mailbox_controller.dart`: Mailbox state management
- Check email content loading logic
- Verify dispose/rebuild cycle when switching folders
- Test with thread view enabled/disabled

### Adding i18n Support

1. Add strings to localization files in `lib/l10n/`
2. Use `AppLocalizations.of(context).stringKey`
3. Contribute translations via Weblate

### Debugging Tips

**Common Issues**:
- Email not rendering: Check `thread_detail` controller lifecycle
- Authentication fails: Verify OAuth config and redirect URIs
- Offline mode issues: Check Hive database initialization
- Push not working: Verify FCM setup in Firebase Console

**Logging**:
```dart
import 'package:core/utils/app_logger.dart';

AppLogger.d('Debug message');
AppLogger.e('Error message');
```

**GetX DevTools**:
```dart
// Check controller state
Get.find<HomeController>(); // Access controller
```

## Testing Strategy

### Unit Tests
Location: `test/`
- Test use cases in isolation
- Mock repositories
- Test business logic

### Widget Tests
- Test UI components
- Mock controllers
- Verify interactions

### Integration Tests
Location: `integration_test/`
- Full feature flows
- Real backend interaction
- Patrol framework for UI testing

## CI/CD

### GitHub Actions
`.github/workflows/`: Automated workflows
- Build verification
- Test execution
- Code quality checks

## Docker Support

### Web Application
TMail provides Docker images for web deployment:

**Official Image**: `linagora/tmail-web`

**Build Locally**:
```bash
docker build -t tmail-web:latest .
```

**Run**:
```bash
# Option 1: Pre-configured env.file
docker run -d -ti -p 8080:80 --name web tmail-web:latest

# Option 2: Mount env.file
docker run -d -ti -p 8080:80 \
  --mount type=bind,source="$(pwd)"/env.dev.file,target=/usr/share/nginx/html/assets/env.file \
  --name web tmail-web:latest
```

### Backend Testing
`backend-docker/docker-compose.yaml` provides:
- TMail Backend (JMAP server)
- Demo accounts (alice@localhost, bob@localhost, empty@localhost)
- Complete testing environment

## Tips for Navigating the Codebase

### Finding Feature Code
1. All features are in `lib/features/[feature]/`
2. Start with `presentation/controller/` for logic
3. Check `domain/usecases/` for business operations
4. Review `data/repository/` for data access

### Understanding Dependencies
1. Check `pubspec.yaml` for package versions
2. Review `lib/main/bindings/` for dependency injection
3. Look at feature-specific bindings in `presentation/bindings/`

### Tracing User Flows
1. Start from routes in `lib/main/routes/`
2. Find page widget in feature's `presentation/`
3. Follow controller method calls
4. Trace through use cases and repositories

### Debugging State Issues
1. Check controller's reactive variables (`.obs`)
2. Verify lifecycle methods (onInit, onReady, onClose)
3. Look for dispose issues in base controllers
4. Test with GetX DevTools

### Finding UI Components
1. Shared widgets: `lib/features/base/widget/`
2. Core components: `core/lib/presentation/`
3. Feature widgets: `lib/features/[feature]/presentation/widgets/`

## Git Workflow

### Branches
- `main` / `master`: Production branch
- `feature/*`: New features
- `bugfix/*`: Bug fixes
- `hotfix/*`: Urgent production fixes

### Current Branch Context
You are currently on: `bugfix/email-content-not-render-when-switch-folder-thread`

This branch addresses an issue where email content fails to render after switching folders when thread view is enabled.

**Related Files to Check**:
- `lib/features/thread_detail/`: Thread rendering logic
- `lib/features/base/base_mailbox_controller.dart`: Mailbox state coordination
- Email content loading and disposal lifecycle

## Version Information

**Current Version**: 0.23.1
**Flutter SDK**: >=3.0.0 <4.0.0
**Dart SDK**: >=3.0.0 <4.0.0

## Resources

### Documentation
- **User Guides**: `docs/user-guide/`
- **Configuration**: `docs/configuration/`
- **ADRs**: `docs/adr/` (Architecture Decision Records)
- **Stories**: `docs/stories/` (User stories)

### External Links
- **Official Website**: https://twake-mail.com
- **GitHub Repository**: https://github.com/linagora/tmail-flutter
- **Bug Reports**: https://github.com/linagora/tmail-flutter/issues
- **JMAP Dart Client**: https://github.com/linagora/jmap-dart-client
- **JMAP Protocol**: https://jmap.io/
- **Linagora**: https://linagora.com

### Community
- **Gitter Chat**: https://gitter.im/linagora/team-mail
- **Translations**: https://hosted.weblate.org/projects/linagora/teammail/

## Unresolved Questions

None identified. This summary provides comprehensive coverage of the TMail Flutter codebase structure, architecture, and development workflows.
