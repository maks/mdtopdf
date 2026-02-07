# mdtopdf

A simple CLI that converts a Markdown file to a PDF in pure Dart.

```
Usage:
   dart run bin/markdown_to_pdf.dart <input.md> [--help]
 Options:
   --help                Show this help message and exit.
   --code-bg-colour <hex>  Background colour for code blocks (hex, e.g. #f0f0f0).
```


The output file will be saved alongside the markdown file, with the same name as the markdown file but with the extension of `.pdf`.