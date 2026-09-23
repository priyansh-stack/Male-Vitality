import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'fcm_service.dart';

class PdfDownloadService {
  PdfDownloadService._();
  static final PdfDownloadService instance = PdfDownloadService._();

  /// Saves PDF bytes directly to the user-accessible Android Download directory
  /// (/storage/emulated/0/Download/) or fallback to external/documents dir.
  /// Also triggers a system notification for the user.
  Future<File> saveAndNotify({
    required Uint8List bytes,
    required String fileName,
  }) async {
    File? savedFile;

    // 1. Primary: Direct write to public Download folder on Android
    try {
      final publicDownloadDir = Directory('/storage/emulated/0/Download');
      if (await publicDownloadDir.exists()) {
        savedFile = File('${publicDownloadDir.path}/$fileName');
        await savedFile.writeAsBytes(bytes, flush: true);
        debugPrint('[PdfDownloadService] Successfully wrote ${bytes.length} bytes to public downloads: ${savedFile.path}');
      }
    } catch (e) {
      debugPrint('[PdfDownloadService] Public download dir write failed: $e');
    }

    // 2. Secondary: getExternalStorageDirectory / getApplicationDocumentsDirectory
    if (savedFile == null || !await savedFile.exists()) {
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          savedFile = File('${extDir.path}/$fileName');
          await savedFile.writeAsBytes(bytes, flush: true);
          debugPrint('[PdfDownloadService] Wrote to external storage: ${savedFile.path}');
        }
      } catch (e) {
        debugPrint('[PdfDownloadService] External storage fallback failed: $e');
      }
    }

    if (savedFile == null || !await savedFile.exists()) {
      final appDocDir = await getApplicationDocumentsDirectory();
      savedFile = File('${appDocDir.path}/$fileName');
      await savedFile.writeAsBytes(bytes, flush: true);
      debugPrint('[PdfDownloadService] Wrote to app documents: ${savedFile.path}');
    }

    // 3. Trigger download completion notification
    try {
      final sizeKb = (savedFile.lengthSync() / 1024).toStringAsFixed(1);
      await FcmService.instance.showLocalAlert(
        title: '📥 PDF Download Complete: $fileName',
        body: 'Saved to ${savedFile.path.contains("Download") ? "Downloads folder" : savedFile.path} ($sizeKb KB). Tap to view.',
        payload: savedFile.path,
      );
    } catch (e) {
      debugPrint('[PdfDownloadService] Failed to post download notification: $e');
    }

    return savedFile;
  }

  /// Opens the PDF file using OpenFilex
  Future<OpenResult> openPdf(String filePath) async {
    try {
      return await OpenFilex.open(filePath);
    } catch (e) {
      debugPrint('[PdfDownloadService] OpenFilex error: $e');
      return OpenResult(type: ResultType.error, message: e.toString());
    }
  }
}
