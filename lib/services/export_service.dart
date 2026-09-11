import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ExportService {
  ExportService._();

  static String generateUniqueExportName(String templateName) {
    final clean = templateName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'SnapBeat_${clean}_$stamp.mp4';
  }

  /// Save video to device gallery (Movies/SnapBeat) using MediaStore
  static Future<bool> saveToGallery(BuildContext context, {required String videoPath, required String templateName}) async {
    final file = File(videoPath);
    if (!file.existsSync()) {
      _showToast(context, '⚠️ Video file not found on device.');
      return false;
    }

    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          if (context.mounted) {
            _showToast(context, '⚠️ Storage permission needed to save to gallery.');
          }
          return false;
        }
      }

      await Gal.putVideo(videoPath, album: 'SnapBeat');

      if (context.mounted) {
        _showToast(context, '✓ Saved to Gallery under SnapBeat album! 🎬');
      }
      return true;
    } catch (e) {
      debugPrint('Gal save error: ');
      if (context.mounted) {
        _showToast(context, 'Failed to save to gallery: ');
      }
      return false;
    }
  }

  /// Share video to social media or messaging apps via system share sheet
  static Future<void> shareReel(BuildContext context, {required String videoPath, required String templateName}) async {
    final file = File(videoPath);
    if (!file.existsSync()) {
      _showToast(context, '⚠️ Video file not found.');
      return;
    }

    try {
      final xfile = XFile(videoPath, mimeType: 'video/mp4', name: generateUniqueExportName(templateName));
      await SharePlus.instance.share(
        ShareParams(
          files: [xfile],
          text: 'Created with SnapBeat ⚡ #SnapBeat #BeatSync',
        ),
      );
    } catch (e) {
      debugPrint('Share error: ');
      if (context.mounted) {
        _showToast(context, 'Could not open share sheet: ');
      }
    }
  }

  static void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Color(0xFF2B2B2D),
          ),
        ),
        backgroundColor: const Color(0xFFFAF6EE),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFC8A232), width: 1.5),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
