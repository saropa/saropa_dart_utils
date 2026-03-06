// ignore_for_file: avoid_print, avoid_synchronous_file_io, avoid_blocking_main_thread, require_platform_check, avoid_print_in_release
// Copyright (c) 2025 Saropa. See LICENSE for details.
//
// Scans Dart files for patterns that can be replaced with saropa_dart_utils.
// Run: dart run tool/suggest_saropa_utils.dart [path]
// With path: non-interactive (report to stdout). Without path: interactive Y/N/? prompts.
// --help, --version only. Errors to stderr.
//
// Core logic (scanContent, lineAtOffset, snippet, jsonString) lives in
// suggest_saropa_utils_lib.dart and is unit-tested.

import 'dart:io';

import 'suggest_saropa_utils_lib.dart';

/// Skip files larger than this (bytes) to avoid loading generated code.
const int _maxFileBytes = 512 * 1024;

const int _exitSuccess = 0;
const int _exitError = 1;
const int _exitNoSuggestions = 2;

void main(List<String> args) {
  String? pathArg;
  bool showHelp = false;
  bool showVersion = false;
  for (final String arg in args) {
    if (arg == '--help' || arg == '-h') {
      showHelp = true;
    } else if (arg == '--version' || arg == '-v') {
      showVersion = true;
    } else if (arg.startsWith('-')) {
      stderr.writeln('Error: unknown option $arg (use --help)');
      exit(_exitError);
    } else {
      if (pathArg != null) {
        stderr.writeln('Error: only one path allowed');
        exit(_exitError);
      }
      pathArg = arg;
    }
  }
  if (showHelp) {
    _printHelp();
    exit(_exitSuccess);
  }
  if (showVersion) {
    print('suggest_saropa_utils 1.0.0');
    exit(_exitSuccess);
  }
  final bool interactive = pathArg == null;
  final String path =
      pathArg ?? _ask('Directory to scan', '.', 'Path to the Dart project (e.g. . or ../my_app)');
  final Directory dir = Directory(path);
  if (!dir.existsSync()) {
    stderr.writeln('Error: path does not exist: $path');
    exit(_exitError);
  }
  final List<Suggestion> suggestions = _collectSuggestions(dir);
  if (suggestions.isEmpty) {
    print('No suggestions for $path');
    exit(_exitNoSuggestions);
  }
  OutputFormat output = OutputFormat.report;
  if (interactive) {
    final String outChoice = _ask(
      'Output: (r)eport or (j)son? (? for help)',
      'r',
      'r = human-readable; j = JSON for scripts.',
    );
    output = (outChoice.startsWith('j') || outChoice.startsWith('J'))
        ? OutputFormat.json
        : OutputFormat.report;
  }
  _printReport(suggestions, path, output);
  if (interactive) {
    final String applyChoice = _ask(
      'Apply changes automatically? (y/n/?)',
      'n',
      'Auto-apply not yet implemented; use the report and refactor manually.',
    );
    if (applyChoice.startsWith('y') || applyChoice.startsWith('Y')) {
      stderr.writeln(
        'Auto-apply not yet implemented. Refactor manually using the report above.',
      );
    }
  }
  exit(_exitSuccess);
}

/// Asks a Y/N/? question. Returns answer (trimmed). ? shows [help] and re-prompts; Enter = default.
String _ask(String prompt, String defaultVal, String help) {
  while (true) {
    stdout.write('$prompt [$defaultVal] (? = help): ');
    final String raw = (stdin.readLineSync() ?? '').trim();
    if (raw.isEmpty) return defaultVal;
    if (raw == '?') {
      stderr.writeln('  → $help');
      continue;
    }
    return raw;
  }
}

/// Walks [dir] for .dart files (skipping build, .dart_tool, .git, coverage),
/// reads each file under [_maxFileBytes], and returns all suggestions. Skips
/// files that fail to read (logs to stderr).
List<Suggestion> _collectSuggestions(Directory dir) {
  final List<Suggestion> out = <Suggestion>[];
  for (final File file in _dartFiles(dir)) {
    if (file.lengthSync() > _maxFileBytes) continue;
    try {
      final String content = file.readAsStringSync();
      out.addAll(scanContent(content, file.path));
    } catch (e) {
      stderr.writeln('Warning: skipped ${file.path}: $e');
    }
  }
  return out;
}

/// Yields .dart files under [dir] recursively. Skips build, .dart_tool, .git, coverage.
/// Skips directories that fail to list (no throw).
Iterable<File> _dartFiles(Directory dir) sync* {
  if (!dir.existsSync()) return;
  const List<String> skipDirs = <String>['build', '.dart_tool', '.git', 'coverage'];
  List<FileSystemEntity> entities;
  try {
    entities = dir.listSync(followLinks: false);
  } catch (e) {
    stderr.writeln('Warning: could not list ${dir.path}: $e');
    return;
  }
  for (final FileSystemEntity e in entities) {
    if (e is Directory) {
      final String name = e.path.split(Platform.pathSeparator).last;
      if (!skipDirs.contains(name)) yield* _dartFiles(e);
    } else if (e is File && e.path.endsWith('.dart')) {
      yield e;
    }
  }
}

void _printHelp() {
  stderr.writeln('suggest_saropa_utils — Find code that can use saropa_dart_utils\n');
  stderr.writeln('Usage: dart run tool/suggest_saropa_utils.dart [path]\n');
  stderr.writeln('  With path: print report and exit (no prompts).');
  stderr.writeln('  Without path: interactive (Y/N/? questions).');
  stderr.writeln('  --help, -h   This help.  --version, -v   Version.');
}

enum OutputFormat { report, json }

void _printReport(List<Suggestion> suggestions, String path, OutputFormat output) {
  if (output == OutputFormat.json) {
    _printJson(suggestions);
    return;
  }
  print('saropa_dart_utils suggestions for $path (${suggestions.length} found)\n');
  String? currentPath;
  for (final Suggestion s in suggestions) {
    if (s.path != currentPath) {
      currentPath = s.path;
      print('$currentPath');
    }
    print('  ${s.line}: ${s.snippet}');
    print('  → ${s.message}\n');
  }
}

void _printJson(List<Suggestion> suggestions) {
  final StringBuffer sb = StringBuffer();
  sb.write('[');
  for (int i = 0; i < suggestions.length; i++) {
    if (i > 0) sb.write(',');
    final Suggestion s = suggestions[i];
    sb.write('{"path":${jsonString(s.path)},"line":${s.line},');
    sb.write('"snippet":${jsonString(s.snippet)},"message":${jsonString(s.message)}}');
  }
  sb.write(']');
  print(sb.toString());
}
