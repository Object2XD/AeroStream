# aero_stream

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Google Drive OAuth On Windows

If you downloaded a Google OAuth desktop client JSON from Google Cloud, you can
convert it into a Flutter `--dart-define-from-file` config and build or run the
Windows app without manually copying credentials.

1. Download a Desktop app OAuth client JSON from Google Cloud.
2. Generate a Flutter define file:

```powershell
dart run tool/prepare_google_drive_oauth.dart `
  --input "C:\path\to\client_secret_desktop.json"
```

3. Run the Windows app with the generated config:

```powershell
flutter run -d windows `
  --dart-define-from-file=build_config\google_drive_oauth.env.json
```

Or use the helper wrapper:

```powershell
.\tool\build_windows_with_google_oauth.ps1 `
  -OAuthJsonPath "C:\path\to\client_secret_desktop.json" `
  -Action run `
  -Mode debug
```

For release builds:

```powershell
.\tool\build_windows_with_google_oauth.ps1 `
  -OAuthJsonPath "C:\path\to\client_secret_desktop.json" `
  -Action build `
  -Mode release
```
