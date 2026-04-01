import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    _printUsage();
    return;
  }

  final options = _parseArgs(args);
  if (options == null) {
    exitCode = 64;
    return;
  }

  final inputFile = File(options.inputPath);
  if (!await inputFile.exists()) {
    stderr.writeln('OAuth JSON not found: ${options.inputPath}');
    exitCode = 66;
    return;
  }

  final rawJson = await inputFile.readAsString();
  final validationError = _validateGoogleDesktopOAuthJson(rawJson);
  if (validationError != null) {
    stderr.writeln(validationError);
    exitCode = 65;
    return;
  }

  final outputFile = File(options.outputPath);
  await outputFile.parent.create(recursive: true);
  final outputJson = const JsonEncoder.withIndent('  ').convert(<String, String>{
    'AERO_DRIVE_GOOGLE_OAUTH_JSON': rawJson,
  });
  await outputFile.writeAsString('$outputJson\n');

  stdout.writeln('Wrote dart-define file: ${outputFile.path}');
  stdout.writeln(
    'Use it with: flutter ${options.flutterHint} --dart-define-from-file=${outputFile.path}',
  );
}

class _Options {
  const _Options({
    required this.inputPath,
    required this.outputPath,
    required this.flutterHint,
  });

  final String inputPath;
  final String outputPath;
  final String flutterHint;
}

_Options? _parseArgs(List<String> args) {
  String? inputPath;
  var outputPath = 'build_config/google_drive_oauth.env.json';
  var flutterHint = 'run -d windows';

  for (var index = 0; index < args.length; index++) {
    switch (args[index]) {
      case '--input':
        if (index + 1 >= args.length) {
          stderr.writeln('Missing value for --input.');
          _printUsage();
          return null;
        }
        inputPath = args[++index];
      case '--output':
        if (index + 1 >= args.length) {
          stderr.writeln('Missing value for --output.');
          _printUsage();
          return null;
        }
        outputPath = args[++index];
      case '--flutter-hint':
        if (index + 1 >= args.length) {
          stderr.writeln('Missing value for --flutter-hint.');
          _printUsage();
          return null;
        }
        flutterHint = args[++index];
    }
  }

  if (inputPath == null || inputPath.isEmpty) {
    stderr.writeln('Missing required --input <path-to-downloaded-oauth-json>.');
    _printUsage();
    return null;
  }

  return _Options(
    inputPath: inputPath,
    outputPath: outputPath,
    flutterHint: flutterHint,
  );
}

String? _validateGoogleDesktopOAuthJson(String rawJson) {
  try {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      return 'OAuth JSON must be a JSON object.';
    }

    final installed = decoded['installed'];
    if (installed is! Map<String, dynamic>) {
      return 'Expected a Google Desktop app OAuth JSON with an "installed" section.';
    }

    final clientId = installed['client_id'] as String? ?? '';
    if (clientId.isEmpty) {
      return 'The OAuth JSON is missing installed.client_id.';
    }

    return null;
  } catch (error) {
    return 'Could not parse OAuth JSON: $error';
  }
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run tool/prepare_google_drive_oauth.dart '
    '--input <downloaded-client-secret.json> '
    '[--output build_config/google_drive_oauth.env.json] '
    '[--flutter-hint "run -d windows"]',
  );
}
