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
  static Future<bool> saveToGallery(
    BuildContext context, {
    required String videoPath,
    required String templateName,
    bool autoTriggered = false,
  }) async {
    final file = File(videoPath);
    if (!file.existsSync()) {
      if (!context.mounted) return false;
      _showToast(context, 'Video file not found on device.',
          icon: Icons.warning_amber_rounded);
      return false;
    }

    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          if (!context.mounted) return false;
          _showToast(context, 'Storage permission needed to save to gallery.',
              icon: Icons.warning_amber_rounded);
          return false;
        }
      }

      await Gal.putVideo(videoPath, album: 'SnapBeat Studio');

      if (!context.mounted) return false;
      _showToast(context, 'Saved to Photos (SnapBeat Studio album)',
          icon: Icons.check_circle_outline_rounded);
      return true;
    } catch (e) {
      debugPrint('Gal save error: $e');
      if (!context.mounted) return false;
      _showToast(context, 'Unable to save to gallery. Please check storage permissions.',
          icon: Icons.error_outline_rounded);
      return false;
    }
  }

  /// Share video to social media or messaging apps via system share sheet
  static Future<bool> shareReel(
    BuildContext context, {
    required String videoPath,
    String templateName = 'SnapBeat',
    Rect? sharePositionOrigin,
  }) async {
    final file = File(videoPath);
    if (!file.existsSync()) {
      if (!context.mounted) return false;
      _showToast(context, 'Video file not found.',
          icon: Icons.warning_amber_rounded);
      return false;
    }

    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin = sharePositionOrigin ?? (box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null);
      final xfile = XFile(videoPath, mimeType: 'video/mp4', name: generateUniqueExportName(templateName));
      await SharePlus.instance.share(
        ShareParams(
          files: [xfile],
          text: 'Created with SnapBeat #SnapBeat #BeatSync',
          sharePositionOrigin: origin,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Share error: $e');
      if (!context.mounted) return false;
      _showToast(context, 'Unable to share. Please try again.',
          icon: Icons.error_outline_rounded);
      return false;
    }
  }

  /// Shows a toast. [icon] is drawn as a vector glyph rather than baked into
  /// [message] as an emoji: no font SnapBeat ships carries emoji, so inline
  /// emoji rendered as tofu boxes.
  static void _showToast(BuildContext context, String message, {IconData? icon}) {
    if (!context.mounted) return;
    const textStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 11.5,
      color: Color(0xFF2B2B2D),
    );
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: const Color(0xFF2B2B2D)),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(message, style: textStyle)),
          ],
        ),
        backgroundColor: const Color(0xFFFAF6EE),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFC8A232), width: 1.5),
        ),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }
}
