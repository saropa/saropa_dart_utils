// Generates CAPABILITIES.md — a per-symbol catalog of EVERY public declaration
// under lib/, scraped from the Dart AST (not regex). Run after adding utilities:
//
//     dart run tool/gen_capabilities.dart
//
// Why the AST and not a regex scan: the previous Python generator only listed
// declarations that happened to have a `///` doc block directly above them, so
// any undocumented public symbol (e.g. the `DateConstants` container class) was
// silently dropped, and constructor-call initializers were mislabeled (a field
// `final Duration x = Duration(...)` showed up as a `Duration` constructor). The
// analyzer's parsed AST knows each declaration's real name and kind exactly, so
// the catalog is both complete (every public member) and correctly labeled.
//
// Output is grouped by category (top-level dir under lib/) then by file, each
// file carrying its import path. The header is stamped with the package version
// (read from pubspec.yaml) and the regen date so a snapshot is identifiable.

import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/line_info.dart';

const String barrel = 'saropa_dart_utils.dart';

// Human label per top-level dir under lib/.
const Map<String, String> categoryLabels = <String, String>{
  'string': 'String',
  'datetime': 'DateTime',
  'iterable': 'Iterable',
  'list': 'List',
  'collections': 'Collections',
  'graph': 'Graph',
  'stats': 'Stats',
  'validation': 'Validation',
  'async': 'Async',
  'num': 'Number',
  'int': 'Integer',
  'double': 'Double',
  'bool': 'Bool',
  'map': 'Map',
  'parsing': 'Parsing',
  'caching': 'Caching',
  'url': 'URL & Path',
  'niche': 'Niche',
  'object': 'Object & Null',
  'enum': 'Enum',
  'json': 'JSON',
  'base64': 'Base64',
  'hex': 'Hex',
  'html': 'HTML',
  'uuid': 'UUID',
  'random': 'Random',
  'regex': 'Regex',
  'gesture': 'Gesture',
  'testing': 'Testing',
};

/// One catalog row: a public declaration with its kind and one-line summary.
class Sym {
  Sym(this.kind, this.name, this.target, this.description);

  /// class / mixin / enum / extension / extension type / typedef / function /
  /// method / getter / setter / operator / constructor / field / enum value.
  final String kind;

  /// The public identifier as declared (operators carry the `operator ` prefix,
  /// named constructors are `Class.named`).
  final String name;

  /// For extensions: the type the extension is `on`; null otherwise.
  final String? target;

  /// First sentence of the doc comment, or '' when the symbol is undocumented.
  final String description;
}

/// One file's contribution: its relative path, file-level purpose, and symbols.
class FileSyms {
  FileSyms(this.rel, this.purpose, this.symbols);
  final String rel;
  final String purpose;
  final List<Sym> symbols;
}

// Abbreviations whose trailing period must NOT be read as a sentence boundary,
// so an inline example like "(e.g. 0.01 for 1%)" survives intact (BUG-002).
const Set<String> abbreviations = <String>{
  'e.g',
  'i.e',
  'etc',
  'vs',
  'cf',
  'al',
  'approx',
  'fig',
  'no',
  'dr',
  'mr',
  'ms',
  'mrs',
  'st',
};

bool _isAlpha(String ch) =>
    (ch.compareTo('a') >= 0 && ch.compareTo('z') <= 0) ||
    (ch.compareTo('A') >= 0 && ch.compareTo('Z') <= 0);

/// Strips leading/trailing periods only (so "e.g" keeps its internal dot).
String _stripOuterDots(String s) {
  var a = 0;
  var b = s.length;
  while (a < b && s[a] == '.') {
    a++;
  }
  while (b > a && s[b - 1] == '.') {
    b--;
  }
  return s.substring(a, b);
}

/// True when the '.' at [i] is an abbreviation/initial dot, not a sentence end.
/// A single letter (an initial, or a standalone '.' token as in "split on . ! ?")
/// or a known abbreviation (e.g., i.e., vs.) does not terminate the sentence; a
/// '.' after a non-letter (')', a digit, '%') is a real boundary (BUG-002).
bool isAbbrevDot(String text, int i) {
  var j = i;
  while (j > 0 && (_isAlpha(text[j - 1]) || text[j - 1] == '.')) {
    j--;
  }
  final String word = text.substring(j, i);
  if (word.isEmpty) return false;
  if (word.length == 1 && _isAlpha(word)) return true;
  return abbreviations.contains(_stripOuterDots(word).toLowerCase());
}

/// Index just past the first sentence-ending period, or null. A '.' ends the
/// sentence only when it sits outside backticks and balanced parentheses, is
/// followed by a space or end-of-string, and is not an abbreviation/initial dot
/// — so inline examples like "(e.g. 0.01 for 1%)" and "(split on . ! ?)" are
/// kept whole instead of cut mid-phrase (BUG-002).
int? sentenceEnd(String text) {
  var inTick = false;
  var paren = 0;
  for (var i = 0; i < text.length; i++) {
    final String c = text[i];
    if (c == '`') {
      inTick = !inTick;
    } else if (c == '(') {
      paren++;
    } else if (c == ')') {
      if (paren > 0) paren--;
    } else if (c == '.' && !inTick && paren == 0) {
      final bool atBreak = (i + 1 == text.length) || text[i + 1] == ' ';
      if (atBreak && !isAbbrevDot(text, i)) return i + 1;
    }
  }
  return null;
}

/// Removes internal planning markers (e.g. "— roadmap #676") — backlog metadata
/// that is not API documentation and must not reach the customer-facing catalog
/// (BUG-003). Handles the dash-prefixed form and a bare "roadmap #NNN".
String stripInternalRefs(String text) {
  var t = text.replaceAll(RegExp(r'\s*[—–-]\s*roadmap\s*#\d+', caseSensitive: false), '');
  t = t.replaceAll(RegExp(r'\s*\broadmap\s*#\d+', caseSensitive: false), '');
  return t.trim();
}

/// Condenses a doc/comment blob to a single ≤160-char sentence for the table.
String firstSentence(String? doc) {
  if (doc == null) return '';
  var text = doc.replaceAll(RegExp(r'\s+'), ' ').trim();
  // Drop fenced code examples — the summary is prose only.
  text = text.split('```').first.trim();
  // Cut to the first real sentence BEFORE stripping backlog markers: a "roadmap"
  // ref sits either inside the first sentence ("… events — roadmap #676.") or in
  // a trailing one ("…. Roadmap #162."); cutting first then stripping drops the
  // marker in the first case and the whole trailing sentence in the second
  // without leaving a dangling period (BUG-002, BUG-003).
  final int? cut = sentenceEnd(text);
  if (cut != null) text = text.substring(0, cut).trim();
  text = stripInternalRefs(text);
  if (text.length > 160) text = '${text.substring(0, 157).trimRight()}...';
  return text;
}

/// Joins a declaration's `///` doc tokens into one string (markers stripped).
String? docText(AnnotatedNode node) {
  final Comment? c = node.documentationComment;
  if (c == null) return null;
  final StringBuffer buf = StringBuffer();
  for (final token in c.tokens) {
    var line = token.lexeme;
    if (line.startsWith('///')) {
      line = line.substring(3);
    } else if (line.startsWith('/**')) {
      line = line.substring(3);
    }
    buf.write(' ');
    buf.write(line.replaceFirst(RegExp(r'^\s*\*\s?'), '').trim());
  }
  return buf.toString();
}

/// File purpose = the first contiguous `///` block of leading comments, i.e. the
/// top-of-file note that precedes the first token (stops at the first blank-line
/// gap so a floating header is not merged with the first declaration's doc).
String filePurpose(CompilationUnit unit) {
  final LineInfo lineInfo = unit.lineInfo;
  final List<String> lines = <String>[];
  var prevLine = -1;
  var blockOffset = -1;
  Token? token = unit.beginToken.precedingComments;
  while (token != null) {
    final int line = lineInfo.getLocation(token.offset).lineNumber;
    final String lexeme = token.lexeme;
    if (lexeme.startsWith('///')) {
      // A gap (non-consecutive line) ends the leading block.
      if (prevLine != -1 && line > prevLine + 1) break;
      if (blockOffset == -1) blockOffset = token.offset;
      lines.add(lexeme.substring(3).trim());
      prevLine = line;
    } else if (lines.isNotEmpty) {
      break;
    }
    token = token.next;
  }
  if (lines.isEmpty) return '';
  // Suppress a leading block that is really the first DECLARATION's doc comment
  // (a member's dartdoc, not a file summary) — the analyzer attaches such a doc
  // to its declaration, so its offset matches the block we collected. A doc on a
  // `library;` directive, or a free-floating top-of-file note, is NOT a
  // declaration's doc, so its offset differs and it is kept (BUG-003).
  if (unit.declarations.isNotEmpty) {
    final Comment? firstDoc = unit.declarations.first.documentationComment;
    if (firstDoc != null && firstDoc.offset == blockOffset) return '';
  }
  return firstSentence(lines.join(' '));
}

/// Members of a type body. Analyzer 11 moved members onto the body node
/// (`BlockClassBody` / `EnumBody`); a primary-constructor `;` body has none.
List<ClassMember> bodyMembers(AstNode? body) {
  if (body is BlockClassBody) return body.members;
  if (body is EnumBody) return body.members;
  return const <ClassMember>[];
}

/// Appends rows for a class/mixin/enum/extension member (skips private names).
/// [enclosing] is the owning type's name, used to label constructors — the
/// member's AST parent is now the body node, not the declaration.
void addMember(List<Sym> out, ClassMember m, String enclosing) {
  if (m is MethodDeclaration) {
    final String name = m.name.lexeme;
    if (name.startsWith('_')) return;
    final String kind = m.isGetter
        ? 'getter'
        : m.isSetter
        ? 'setter'
        : m.isOperator
        ? 'operator'
        : 'method';
    final String label = m.isOperator ? 'operator $name' : name;
    out.add(Sym(kind, label, null, firstSentence(docText(m))));
  } else if (m is FieldDeclaration) {
    for (final v in m.fields.variables) {
      final String name = v.name.lexeme;
      if (name.startsWith('_')) continue;
      out.add(Sym('field', name, null, firstSentence(docText(m))));
    }
  } else if (m is ConstructorDeclaration) {
    final String? named = m.name?.lexeme;
    if (named != null && named.startsWith('_')) return;
    // Default constructor is shown by its class name; named adds `.name`.
    final String label = named == null ? enclosing : '$enclosing.$named';
    out.add(Sym('constructor', label, null, firstSentence(docText(m))));
  }
}

/// Extracts every public symbol declared at top level or as a type member.
List<Sym> parseUnit(CompilationUnit unit) {
  final List<Sym> out = <Sym>[];
  for (final d in unit.declarations) {
    if (d is ClassDeclaration) {
      final String name = d.namePart.typeName.lexeme;
      if (!name.startsWith('_')) {
        out.add(Sym('class', name, null, firstSentence(docText(d))));
      }
      for (final m in bodyMembers(d.body)) {
        addMember(out, m, name);
      }
    } else if (d is MixinDeclaration) {
      final String name = d.name.lexeme;
      if (!name.startsWith('_')) {
        out.add(Sym('mixin', name, null, firstSentence(docText(d))));
      }
      for (final m in bodyMembers(d.body)) {
        addMember(out, m, name);
      }
    } else if (d is EnumDeclaration) {
      final String name = d.namePart.typeName.lexeme;
      if (!name.startsWith('_')) {
        out.add(Sym('enum', name, null, firstSentence(docText(d))));
      }
      final EnumBody body = d.body;
      for (final c in body.constants) {
        if (c.name.lexeme.startsWith('_')) continue;
        out.add(Sym('enum value', c.name.lexeme, null, firstSentence(docText(c))));
      }
      for (final m in body.members) {
        addMember(out, m, name);
      }
    } else if (d is ExtensionDeclaration) {
      final String name = d.name?.lexeme ?? '(unnamed)';
      final String? target = d.onClause?.extendedType.toSource();
      out.add(Sym('extension', name, target, firstSentence(docText(d))));
      for (final m in bodyMembers(d.body)) {
        addMember(out, m, name);
      }
    } else if (d is FunctionDeclaration) {
      final String name = d.name.lexeme;
      if (name.startsWith('_')) continue;
      final String kind = d.isGetter
          ? 'getter'
          : d.isSetter
          ? 'setter'
          : 'function';
      out.add(Sym(kind, name, null, firstSentence(docText(d))));
    } else if (d is TopLevelVariableDeclaration) {
      for (final v in d.variables.variables) {
        final String name = v.name.lexeme;
        if (name.startsWith('_')) continue;
        out.add(Sym('field', name, null, firstSentence(docText(d))));
      }
    } else if (d is TypeAlias) {
      if (!d.name.lexeme.startsWith('_')) {
        out.add(Sym('typedef', d.name.lexeme, null, firstSentence(docText(d))));
      }
    }
  }
  return out;
}

String importPath(String rel) => "package:saropa_dart_utils/${rel.replaceAll('\\', '/')}";

String anchorFor(String cat) => cat.toLowerCase().replaceAll(' & ', '--').replaceAll(' ', '-');

String escapeCell(String s) => s.replaceAll('|', r'\|');

/// Reads the package version from pubspec.yaml, or null if unreadable. The
/// publish workflow resolves the release version into pubspec.yaml before it
/// regenerates this index, so the stamp matches the shipped version.
String? readPubspecVersion(String root) {
  try {
    for (final line in File('$root/pubspec.yaml').readAsLinesSync()) {
      final Match? m = RegExp(r'^version:\s*(\S+)').firstMatch(line);
      if (m != null) return m.group(1);
    }
  } on FileSystemException {
    // Non-fatal: the header simply omits the version.
  }
  return null;
}

void main() {
  final String root = Directory.current.path;
  final Directory lib = Directory('$root/lib');

  // category label -> list of files with symbols.
  final Map<String, List<FileSyms>> cats = <String, List<FileSyms>>{};
  var totalFiles = 0;
  var totalSyms = 0;

  final List<File> dartFiles =
      lib
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && !f.path.endsWith(barrel))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in dartFiles) {
    final String rel = file.path.substring(lib.path.length + 1).replaceAll('\\', '/');
    final parsed = parseString(content: file.readAsStringSync(), throwIfDiagnostics: false);
    final List<Sym> syms = parseUnit(parsed.unit);
    if (syms.isEmpty) continue;

    final String topDir = rel.split('/').first;
    final String cat = categoryLabels[topDir] ?? '${topDir[0].toUpperCase()}${topDir.substring(1)}';
    cats.putIfAbsent(cat, () => <FileSyms>[]).add(FileSyms(rel, filePurpose(parsed.unit), syms));
    totalFiles++;
    totalSyms += syms.length;
  }

  final String? version = readPubspecVersion(root);
  final DateTime now = DateTime.now();
  final String today =
      '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final String releaseLabel = version != null ? 'Release $version' : 'Release (version unknown)';

  final List<String> out = <String>['# Capabilities Index', ''];
  out
    ..add('**$releaseLabel** · Generated $today')
    ..add('')
    ..add(
      'A complete, per-symbol catalog of every public utility in '
      '`saropa_dart_utils` — for teams evaluating or adopting the library. '
      'Covers **$totalSyms public symbols** across **$totalFiles files**.',
    )
    ..add('')
    ..add(
      "Each file is independently importable for minimal bundle size "
      "(`import 'package:saropa_dart_utils/<path>';`), or import the barrel "
      "`package:saropa_dart_utils/saropa_dart_utils.dart` for everything.",
    )
    ..add('')
    ..add(
      '> Generated by `tool/gen_capabilities.dart` from the Dart AST under '
      '`lib/` — every public declaration, documented or not. Run it after '
      'adding utilities to keep this complete.',
    )
    ..add('')
    ..add('---')
    ..add('')
    ..add('## Categories')
    ..add('');

  final List<String> sortedCats = cats.keys.toList()..sort();
  for (final cat in sortedCats) {
    final int count = cats[cat]!.fold(0, (sum, fs) => sum + fs.symbols.length);
    out.add('- [$cat](#${anchorFor(cat)}) — $count symbols');
  }
  out
    ..add('')
    ..add('---')
    ..add('');

  for (final cat in sortedCats) {
    out
      ..add('## $cat')
      ..add('');
    final List<FileSyms> files = cats[cat]!..sort((a, b) => a.rel.compareTo(b.rel));
    for (final fs in files) {
      out.add('### `${fs.rel}`');
      if (fs.purpose.isNotEmpty) {
        out
          ..add('')
          ..add(fs.purpose);
      }
      out
        ..add('')
        ..add("`import '${importPath(fs.rel)}';`")
        ..add('')
        ..add('| Symbol | Kind | Description |')
        ..add('|--------|------|-------------|');
      for (final s in fs.symbols) {
        final String label = s.kind == 'extension' && s.target != null
            ? '`${s.name}` on `${s.target}`'
            : '`${s.name}`';
        out.add('| $label | ${s.kind} | ${escapeCell(s.description)} |');
      }
      out.add('');
    }
    out
      ..add('---')
      ..add('');
  }

  File('$root/CAPABILITIES.md').writeAsStringSync('${out.join('\n')}\n');
  stdout.writeln('Wrote CAPABILITIES.md: $totalSyms symbols, $totalFiles files');
}
