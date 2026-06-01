// ─────────────────────────────────────────────────────────────────────────────
// gita_pdf_service.dart
//
// Handles picking, parsing, storing, and retrieving the Bhagavad Gita PDF.
//
// Dependencies (add to pubspec.yaml if not already present):
//   file_picker: ^8.0.0
//   shared_preferences: ^2.2.3
//   syncfusion_flutter_pdf: ^25.1.0   (or swap for pdfx / pdf_text — see note)
//
// Storage strategy:
//   The extracted plain-text is stored in SharedPreferences under two keys:
//     _kTextKey     → full extracted text (may be large; ~1–4 MB for the Gita)
//     _kNameKey     → original filename
//   On low-memory devices you can replace SharedPreferences with a local file
//   write (path_provider + dart:io) — the public API of this class stays the
//   same either way.
// ─────────────────────────────────────────────────────────────────────────────


import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

// ── Storage keys ──────────────────────────────────────────────────────────────
const String _kTextKey = 'gita_pdf_text';
const String _kNameKey = 'gita_pdf_filename';

// ── Result type ───────────────────────────────────────────────────────────────

/// Returned by [GitaPdfService.pickAndParsePdf].
class PdfLoadResult {
  /// `true` when the PDF was picked and parsed successfully.
  final bool isSuccess;

  /// `true` when an error occurred (file not picked counts as neither).
  final bool isError;

  /// Original filename (e.g. `Bhagavad_Gita.pdf`). Non-null when [isSuccess].
  final String? filename;

  /// Human-readable summary shown in the success SnackBar.
  /// e.g. "Loaded 701 pages · 312 840 characters"
  final String? summaryText;

  /// Human-readable error message. Non-null when [isError].
  final String? errorMessage;

  const PdfLoadResult._({
    required this.isSuccess,
    required this.isError,
    this.filename,
    this.summaryText,
    this.errorMessage,
  });

  /// User cancelled the file picker — not a success, not an error.
  factory PdfLoadResult.cancelled() =>
      const PdfLoadResult._(isSuccess: false, isError: false);

  factory PdfLoadResult.success({
    required String filename,
    required String summaryText,
  }) =>
      PdfLoadResult._(
        isSuccess: true,
        isError: false,
        filename: filename,
        summaryText: summaryText,
      );

  factory PdfLoadResult.error(String message) =>
      PdfLoadResult._(isSuccess: false, isError: true, errorMessage: message);
}

// ── Service ───────────────────────────────────────────────────────────────────

/// Static service for all Bhagavad Gita PDF operations used by GuidanceScreen.
abstract final class GitaPdfService {
  // ── Query ──────────────────────────────────────────────────────────────────

  /// Returns `true` if a previously parsed PDF is stored on this device.
  static Future<bool> isPdfLoaded() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_kTextKey);
    return text != null && text.isNotEmpty;
  }

  /// Returns the stored extracted text, or `null` if none is stored.
  static Future<String?> getStoredText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTextKey);
  }

  /// Returns the stored original filename, or `null` if none is stored.
  static Future<String?> getStoredFilename() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kNameKey);
  }

  // ── Pick & parse ───────────────────────────────────────────────────────────

  /// Opens the system file picker (PDF only), extracts text from every page,
  /// persists the result to SharedPreferences, and returns a [PdfLoadResult].
  ///
  /// Parsing is done on a background isolate via [compute] so the UI stays
  /// responsive even for large PDFs.
  static Future<PdfLoadResult> pickAndParsePdf() async {
    // 1. Let the user choose a PDF file.
    FilePickerResult? picked;
    try {
      picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // load bytes into memory (needed on web & iOS)
      );
    } catch (e) {
      return PdfLoadResult.error('Could not open file picker: $e');
    }

    if (picked == null || picked.files.isEmpty) {
      return PdfLoadResult.cancelled(); // user pressed Back
    }

    final file = picked.files.first;
    final Uint8List? bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      return PdfLoadResult.error(
          'Could not read the file. Please try again.');
    }

    final filename = file.name;

    // 2. Extract text on a background isolate.
    _ParseResult parsed;
    try {
      parsed = await compute(_extractTextFromBytes, bytes);
    } catch (e) {
      debugPrint('[GitaPdfService] parse error: $e');
      return PdfLoadResult.error(
          'Failed to parse the PDF. Make sure it is a valid, '
          'text-based (not scanned) PDF.');
    }

    if (parsed.text.isEmpty) {
      return PdfLoadResult.error(
          'No readable text found. The PDF may be a scanned image — '
          'please use a text-based Bhagavad Gita PDF.');
    }

    // 3. Persist to SharedPreferences.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTextKey, parsed.text);
      await prefs.setString(_kNameKey, filename);
    } catch (e) {
      return PdfLoadResult.error('Parsed successfully but could not save: $e');
    }

    final charCount = _formatNumber(parsed.text.length);
    final summary =
        'Loaded ${parsed.pageCount} page${parsed.pageCount == 1 ? '' : 's'} '
        '· $charCount characters';

    return PdfLoadResult.success(filename: filename, summaryText: summary);
  }

  // ── Clear ──────────────────────────────────────────────────────────────────

  /// Removes the stored PDF text and filename from SharedPreferences.
  static Future<void> clearStoredPdf() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTextKey);
    await prefs.remove(_kNameKey);
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  static String _formatNumber(int n) {
    // Simple thousands-separator formatter (avoids intl dependency).
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('\u202f'); // narrow NBSP
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ── Isolate helpers ───────────────────────────────────────────────────────────

class _ParseResult {
  final String text;
  final int pageCount;
  const _ParseResult(this.text, this.pageCount);
}

/// Top-level function suitable for [compute] (must not be a closure).
///
/// Uses syncfusion_flutter_pdf to extract text page by page.
/// If you prefer a different PDF package, replace only this function:
///   • pdfx / pdf_text → load bytes, iterate pages, extract text.
///   • The rest of the service stays the same.
_ParseResult _extractTextFromBytes(Uint8List bytes) {
  final PdfDocument doc = PdfDocument(inputBytes: bytes);
  final extractor = PdfTextExtractor(doc);

  final buffer = StringBuffer();
  final pageCount = doc.pages.count;

  for (var i = 0; i < pageCount; i++) {
    final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
    if (pageText.isNotEmpty) {
      buffer.write(pageText);
      buffer.write('\n\n'); // blank line between pages for readability
    }
  }

  doc.dispose();
  return _ParseResult(buffer.toString().trim(), pageCount);
}