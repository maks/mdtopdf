#!/usr/bin/env dart

/// markdown_to_pdf.dart
///
/// A tiny command‑line utility that:
///   1. Reads a Markdown file supplied as the first positional argument.
///   2. Converts the Markdown into PDF widgets using the **browser rendering
///      engine** of `htmltopdfwidgets`.
///   3. Writes the resulting PDF to the same directory, preserving the base
///      filename (e.g. `document.md → document.pdf`).
///
/// Usage:
///   dart run bin/markdown_to_pdf.dart <input.md> [--help]
///
/// Options:
///   --help                Show this help message and exit.
///   --code-bg-colour <hex>  Background colour for code blocks (hex, e.g. #f0f0f0).
import 'dart:io';
import 'package:args/args.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:pdf/widgets.dart' as pw;

/// Prints a short help/usage message.
void printHelp() {
  const usage = '''
Usage: markdown_to_pdf <input.md>
Converts a Markdown file to PDF using htmltopdfwidgets (browser‑rendering engine).
Positional arguments:
  <input.md>    Path to the markdown source file (required).
The generated PDF is saved next to the input file with the same base name
(e.g. "notes.md" → "notes.pdf").
''';
  stdout.writeln(usage);
}

Future<void> main(List<String> args) async {
  // ----------------- Argument parsing with ArgParser -----------------
  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Show this help message and exit.')
    ..addOption('code-bg-colour',
        help: 'Background colour for code blocks (hex, e.g. #f0f0f0).',
        valueHelp: '<hex>');

  ArgResults argResults;
  try {
    argResults = parser.parse(args);
  } catch (e) {
    stderr.writeln('Argument parsing error: $e');
    stdout.writeln(parser.usage);
    exit(64);
  }

  if (argResults['help'] as bool) {
    printHelp();
    stdout.writeln(parser.usage);
    exit(0);
  }

  // Retrieve positional arg (input file)
  final inputPath = argResults.rest.first;
  final inputFile = File(inputPath);
  if (!await inputFile.exists()) {
    stderr.writeln('Error: File not found – $inputPath');
    exit(1);
  }
  // ---------------------------  Read markdown  ---------------------------
  final markdownContent = await inputFile.readAsString();
  // ------------------  Convert markdown → PDF widgets (new engine)  ------------------
  // The `useNewEngine` flag activates the browser‑rendering engine.
  final List<pw.Widget> pdfWidgets;
  try {
    pdfWidgets =
        await HTMLToPdf().convertMarkdown(markdownContent, useNewEngine: true);
  } catch (e, st) {
    stderr.writeln('Conversion failed: $e');
    // Optionally you could print the stack trace for debugging:
    // stderr.writeln(st);
    exit(2);
  }
  // ---------------------------  Build PDF document  ---------------------------
  final pdfDoc = pw.Document();
  pdfDoc.addPage(pw.MultiPage(build: (_) => pdfWidgets));
  // ---------------------------  Output file path  ---------------------------
  final outputPath = inputFile.parent.uri
      .resolve('${inputFile.uri.pathSegments.last.split('.').first}.pdf')
      .toFilePath();
  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(await pdfDoc.save());
  stdout.writeln('✅ PDF generated: $outputPath');
}
