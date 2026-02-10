## Configuration for Attachment Keyword Detection

### Context

* When a user composes an email, the system detects if the content implies an attachment (e.g., "Please find attached...") but no file is attached.
* We need a flexible way to add specific keywords (Include) or ignore specific tokens (Exclude) without modifying the source code.

### How to configure

1. Configuration File Location

   * The configuration is managed in the JSON file: `configurations/attachment_keywords.json`
   * This file must be declared in `pubspec.yaml` under `assets`.

2. JSON Structure

The file consists of two main arrays:

```json
{
  "includeList": [
    "invoice",
    "estimate",
    "báo giá"
  ],
  "excludeList": [
    "signature-logo",
    "no-reply",
    "icon-app"
  ]
}

```

* `includeList`: List of keywords to **add** to the detection dictionary.
  * Used when the default dictionary (hardcoded in app) is missing specific business terms.
  * Matches are case-insensitive.
  * Example: Adding `"cv"` will trigger the alert for "Attached is my CV".


* `excludeList`: List of tokens to **ignore/block** from detection.
  * Used to prevent false positives where a keyword exists but is part of a system string or signature.
  * The filter checks the full surrounding token (e.g., if you exclude `"signature-logo"`, the text `"check signature-logo"` will be ignored even if it contains "signature").



3. Application Logic

* **Loading:** The file is loaded lazily and cached in memory upon the first request (Singleton pattern).
* **Execution Flow:**
  1. User clicks "Send".
  2. App loads `includeList` and merges it with the default multi-language dictionary.
  3. Regex scans the text.
  4. Matches are filtered against the `excludeList`.
  5. If valid keywords remain and no file is attached, a warning dialog is shown.



4. Example Customization

If you want to support a new document type called "Blueprints" and ignore a specific CSS class in the email body:

**Modify `configurations\attachment_keywords.json`:**

```json
{
  "includeList": [
    "blueprints",
    "bản vẽ"
  ],
  "excludeList": [
    "css-class-attachment",
    "div-id-file"
  ]
}

```