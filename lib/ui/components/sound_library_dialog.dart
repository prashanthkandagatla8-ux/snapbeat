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
  String? _previewingId;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _previewPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = (state == PlayerState.playing);
        });
      }
    });
  }

  @override
  void dispose() {
    _previewPlayer.stop();
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePreview(SoundTrack track) async {
    try {
      if (_previewingId == track.id && _isPlaying) {
        await _previewPlayer.pause();
      } else {
        _previewingId = track.id;
        // AudioPlayer plays asset using AssetSource (without 'assets/' prefix)
        final relativeAssetPath = track.assetPath.replaceFirst('assets/', '');
        await _previewPlayer.stop();
        await _previewPlayer.play(AssetSource(relativeAssetPath));
      }
    } catch (e) {
      debugPrint('Audio preview error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracks = SoundTrack.builtInLibrary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: AppColors.canvasChassis,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: AppColors.chassisBevelLight, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 25,
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
              color: AppColors.textMuted,
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
                            color: AppColors.panelInset,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIBRARY',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Music Library',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textEngraved,
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
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.panelCreamDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.chassisBevelDark),
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textEngraved),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.chassisBevelDark),

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
                     cleanCurrentTitle.startsWith(track.title.toLowerCase()) ||
                     (cleanCurrentTitle.contains(track.title.toLowerCase()) && track.title.length > 3));
                final isCurrentPreview = (_previewingId == track.id && _isPlaying);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.panelCream,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.brassGold : AppColors.chassisBevelLight,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        offset: const Offset(1, 2),
                        blurRadius: 4,
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
                                color: AppColors.amberJewel,
                                border: Border.all(
                                  color: AppColors.amberGlow,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
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
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                          color: AppColors.textEngraved,
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
                                        color: AppColors.panelInset,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(color: AppColors.chassisBevelDark),
                                      ),
                                      child: Text(
                                        track.genre.toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textSecondary,
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
                                        color: AppColors.textSecondary,
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
                                gradient: isSelected ? null : AppColors.brassKnobGradient,
                                color: isSelected ? AppColors.vuGreen.withValues(alpha: 0.15) : null,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? AppColors.vuGreen : AppColors.brassDark,
                                  width: 1.2,
                                ),
                                boxShadow: isSelected
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          offset: const Offset(1, 2),
                                          blurRadius: 3,
                                        ),
                                      ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isSelected ? '✓ SELECTED' : 'SELECT',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                      color: isSelected ? AppColors.vuGreen : AppColors.hardwareGunmetal,
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
                            color: AppColors.textMuted,
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
    );
  }
}
