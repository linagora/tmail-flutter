# Configuration for Sentry

## Context
- **Twake Mail** uses **Sentry** to collect and track application errors and performance issues.
- Developers need to configure environment variables for **Sentry** service to enable monitoring and debugging.

## How to configure

### 1. Add environment variables for Sentry service
Edit the file [`env.file`](https://github.com/linagora/tmail-flutter/blob/master/env.file) with the following content:

```bash
SENTRY_DSN=<your_sentry_dsn>
SENTRY_ENVIRONMENT=<environment_name>
```

**Descriptions:**
- `SENTRY_DSN`: The unique DSN (Data Source Name) provided by Sentry, used to identify and connect your project.
- `SENTRY_ENVIRONMENT`: The environment name (e.g., `dev`, `staging`, `production`) to help Sentry categorize issues by deployment.

### 2. Activate Sentry in environment file
In [`env.file`](https://github.com/linagora/tmail-flutter/blob/master/env.file), ensure the following line is present:

- If you want to use Sentry:
```bash
SENTRY_ENABLED=true
```

- If you don't want to use Sentry:
```bash
SENTRY_ENABLED=false
```
  or
```bash
SENTRY_ENABLED=
```

### 3. Verification
Run the app and trigger a sample error to verify that it appears in your Sentry dashboard.
