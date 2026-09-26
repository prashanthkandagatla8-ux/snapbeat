import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/sound_track.dart';
import '../../theme/app_colors.dart';

class SoundLibraryDialog extends StatefulWidget {
  final String currentTrackTitle;
  final Function(SoundTrack) onSelectTrack;

  const SoundLibraryDialog({
    super.key,
    required this.currentTrackTitle,
    required this.onSelectTrack,
  });

  static Future<void> show({
    required BuildContext context,
    required String currentTrackTitle,
    required Function(SoundTrack) onSelectTrack,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SoundLibraryDialog(
        currentTrackTitle: currentTrackTitle,
        onSelectTrack: onSelectTrack,
      ),
    );
  }

  @override
  State<SoundLibraryDialog> createState() => _SoundLibraryDialogState();
}

class _SoundLibraryDialogState extends State<SoundLibraryDialog> {
  final AudioPlayer _previewPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;
  String? _previewingId;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playerStateSub = _previewPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = (state == PlayerState.playing);
        });
      }
    });
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _previewPlayer.stop();
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePreview(SoundTrack track) async {
    try {
      if (_previewingId == track.id && _isPlaying) {
        await _previewPlayer.pause();
        return;
      }
      if (_previewingId == track.id && !_isPlaying) {
        await _previewPlayer.resume();
        setState(() => _isPlaying = true);
        return;
      }
      _previewingId = track.id;
      // AudioPlayer plays asset using AssetSource (without 'assets/' prefix)
      final relativeAssetPath = track.assetPath.replaceFirst('assets/', '');
      await _previewPlayer.stop();
      await _previewPlayer.play(AssetSource(relativeAssetPath));
    } catch (e) {
      debugPrint('Audio preview error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracks = SoundTrack.builtInLibrary;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: BoxDecoration(
          color: AppColors.ceramicWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, -6),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.pianoBlack,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0x30FFFFFF)),
                            ),
                            child: const Text(
                              'LIBRARY',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Music Library',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textInkBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tap to preview, then select a track',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textInkSecondary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textInkBlack),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Track List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                final cleanCurrentTitle = widget.currentTrackTitle.trim().toLowerCase();
                final isSelected = cleanCurrentTitle.isNotEmpty &&
                    (cleanCurrentTitle == track.title.toLowerCase() ||
                     cleanCurrentTitle == track.assetPath.toLowerCase() ||
                     cleanCurrentTitle == track.fileName.toLowerCase());
                final isCurrentPreview = (_previewingId == track.id && _isPlaying);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.pianoBlack : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Audition / Play Preview Button
                          GestureDetector(
                            onTap: () => _togglePreview(track),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.pianoBlack,
                                border: Border.all(
                                  color: isCurrentPreview
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0x35FFFFFF),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isCurrentPreview ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Track Title & Vibe
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        track.title,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                          color: AppColors.textInkBlack,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Text(
                                        track.genre.toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textInkSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${track.bpm} • ${track.durationSeconds.toInt()}s',
                                      style: const TextStyle(
                                        fontFamily: 'Courier',
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textInkSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Mount Button
                          GestureDetector(
                            onTap: () {
                              _previewPlayer.stop();
                              widget.onSelectTrack(track);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: isSelected ? AppColors.iridescentGradient : null,
                                color: isSelected ? null : AppColors.pianoBlack,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : const Color(0x35FFFFFF),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 3),
                                  ],
                                  Text(
                                    isSelected ? 'SELECTED' : 'SELECT',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Vibe description footer
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 56),
                        child: Text(
                          track.vibe,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 9.5,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textInkSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}
