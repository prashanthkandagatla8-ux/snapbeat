import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/sound_track.dart';
import '../../theme/app_colors.dart';
import 'sound_library_dialog.dart';
import 'retro_metal_panel.dart';
import 'tactile_action_button.dart';

class WebAudioConsoleDeck extends StatefulWidget {
  final bool isPlaying;
  final String trackTitle;
  final double currentSeconds;
  final double totalSeconds;
  final String? bpm;
  final String? genre;
  final bool isCustom;
  final VoidCallback onTogglePlay;
  final VoidCallback onStop;
  final VoidCallback onPickAudio;
  final VoidCallback? onPickVideoAudio;
  final VoidCallback? onOpenLibrary;

  const WebAudioConsoleDeck({
    super.key,
    required this.isPlaying,
    required this.trackTitle,
    required this.currentSeconds,
    required this.totalSeconds,
    this.bpm,
    this.genre,
    this.isCustom = false,
    required this.onTogglePlay,
    required this.onStop,
    required this.onPickAudio,
    this.onPickVideoAudio,
    this.onOpenLibrary,
  });

  @override
  State<WebAudioConsoleDeck> createState() => _WebAudioConsoleDeckState();
}

class _WebAudioConsoleDeckState extends State<WebAudioConsoleDeck>
    with SingleTickerProviderStateMixin {
  late AnimationController _eqController;

  static const List<double> _baseHeights = [
    45.0, 75.0, 30.0, 90.0, 60.0, 100.0, 40.0, 85.0, 55.0, 70.0, 95.0, 35.0, 80.0, 50.0, 65.0
  ];

  @override
  void initState() {
    super.initState();
    _eqController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    if (widget.isPlaying) {
      _eqController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WebAudioConsoleDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _eqController.repeat(reverse: true);
      } else {
        _eqController.stop();
      }
    }
  }

  @override
  void dispose() {
    _eqController.dispose();
    super.dispose();
  }

  String _formatTime(double secs) {
    if (secs.isNaN || secs.isInfinite || secs < 0) return '0:00';
    final m = secs ~/ 60;
    final s = (secs % 60).toInt();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return RetroMetalPanel(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Status LED dot, Title, and Digital Timecode Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isPlaying ? AppColors.vuGreen : AppColors.amberJewel,
                        boxShadow: [
                          BoxShadow(
                            color: widget.isPlaying
                                ? AppColors.vuGreen.withValues(alpha: 0.6)
                                : AppColors.amberJewel.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.music_note_rounded, size: 16, color: AppColors.brassGold),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        "SOUNDTRACK & AUDIO WAVEFORM",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textEngraved,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "PLAYHEAD",
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      color: AppColors.brassGold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.panelInset,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grooveLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "${_formatTime(widget.currentSeconds)} / ${_formatTime(widget.totalSeconds)}",
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: AppColors.yellowPrimary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Center Equalizer & Track Info Stage
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.panelInset,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grooveDark),
            ),
            child: Column(
              children: [
                // Animated Equalizer Spectrum Display
                AnimatedBuilder(
                  animation: _eqController,
                  builder: (context, _) {
                    return Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(15, (i) {
                          double heightFactor;
                          if (widget.isPlaying) {
                            final phase = (i * 0.42) + (_eqController.value * math.pi * 2);
                            final wave = 0.5 + 0.5 * math.sin(phase);
                            heightFactor = (0.2 + 0.8 * wave);
                          } else {
                            heightFactor = 0.25;
                          }
                          final barHeight = (_baseHeights[i] * heightFactor).clamp(10.0, 52.0);

                          return Container(
                            width: 5,
                            height: barHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: widget.isPlaying
                                  ? const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        AppColors.amberJewel,
                                        AppColors.brassGold,
                                        AppColors.yellowSpecular,
                                      ],
                                    )
                                  : null,
                              color: widget.isPlaying
                                  ? null
                                  : Colors.white.withValues(alpha: 0.2),
                              boxShadow: widget.isPlaying
                                  ? [
                                      BoxShadow(
                                        color: AppColors.brassGold.withValues(alpha: 0.45),
                                        blurRadius: 6,
                                        spreadRadius: 0.5,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Center Track Info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.brassGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brassGold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    widget.isCustom ? "CUSTOM AUDIO" : "PREMIUM STUDIO AUDIO",
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brassGold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    widget.trackTitle.isEmpty ? "No Audio Selected" : widget.trackTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textEngraved,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isCustom
                      ? "Uploaded File"
                      : (widget.bpm != null && widget.bpm!.isNotEmpty)
                          ? "${widget.bpm}${widget.genre != null && widget.genre!.isNotEmpty ? " * ${widget.genre}" : ""}"
                          : "Beat-Synchronized Audio",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.brassGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Transport Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 1. Browse Music Library Button (Primary Action)
              if (widget.onOpenLibrary != null)
                TactileActionButton.primary(
                  height: 38,
                  label: "BROWSE LIBRARY",
                  icon: Icons.library_music_rounded,
                  onTap: widget.onOpenLibrary,
                ),

              // 2. Play / Pause Button
              TactileActionButton(
                variant: widget.isPlaying ? TactileButtonVariant.secondaryGunmetal : TactileButtonVariant.primaryGold,
                height: 38,
                label: widget.isPlaying ? "PAUSE" : "PLAY",
                icon: widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onTap: widget.onTogglePlay,
              ),

              // 3. Stop Button
              TactileActionButton.secondary(
                height: 38,
                label: "STOP",
                icon: Icons.stop_rounded,
                onTap: widget.onStop,
              ),

              // 4. Load Custom MP3 Button
              TactileActionButton.secondary(
                height: 38,
                label: "CUSTOM MP3",
                icon: Icons.file_upload_outlined,
                onTap: widget.onPickAudio,
              ),

              // 5. From Video Button (optional)
              if (widget.onPickVideoAudio != null)
                TactileActionButton.secondary(
                  height: 38,
                  label: "FROM VIDEO",
                  icon: Icons.video_library_outlined,
                  onTap: widget.onPickVideoAudio,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CuratedSoundtrackSection extends StatefulWidget {
  final String selectedTrackTitle;
  final Function(SoundTrack) onSelectTrack;

  const CuratedSoundtrackSection({
    super.key,
    required this.selectedTrackTitle,
    required this.onSelectTrack,
  });

  @override
  State<CuratedSoundtrackSection> createState() => _CuratedSoundtrackSectionState();
}

class _CuratedSoundtrackSectionState extends State<CuratedSoundtrackSection> {
  final AudioPlayer _previewPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;
  String? _previewingId;
  bool _isPlayingPreview = false;

  @override
  void initState() {
    super.initState();
    _playerStateSub = _previewPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingPreview = (state == PlayerState.playing);
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
      if (_previewingId == track.id && _isPlayingPreview) {
        await _previewPlayer.pause();
        return;
      }
      if (_previewingId == track.id && !_isPlayingPreview) {
        await _previewPlayer.resume();
        return;
      }
      _previewingId = track.id;
      final relativeAssetPath = track.assetPath.replaceFirst('assets/', '');
      await _previewPlayer.stop();
      await _previewPlayer.play(AssetSource(relativeAssetPath));
    } catch (e) {
      debugPrint('Audio preview error: $e');
    }
  }

  void _handleSelect(SoundTrack track) {
    _previewPlayer.stop();
    setState(() {
      _isPlayingPreview = false;
      _previewingId = null;
    });
    widget.onSelectTrack(track);
  }

  @override
  Widget build(BuildContext context) {
    final tracks = SoundTrack.builtInLibrary;
    SoundTrack currentTrack = tracks.first;
    for (final t in tracks) {
      if (widget.selectedTrackTitle.toLowerCase().contains(t.title.toLowerCase()) ||
          widget.selectedTrackTitle.toLowerCase().contains(t.id.toLowerCase())) {
        currentTrack = t;
        break;
      }
    }
    final isPreviewing = (_previewingId == currentTrack.id && _isPlayingPreview);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.chassisBevelLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.library_music_rounded, size: 18, color: AppColors.brassGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "CURATED SOUNDTRACK LIBRARY",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textEngraved,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Select from royalty-free beat-synchronized studio tracks.",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brassGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderBrass),
                ),
                child: Text(
                  "${tracks.length} TRACKS",
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    color: AppColors.brassGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dropdown Track Selector Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.panelInset,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.brassGold.withValues(alpha: 0.7),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SoundTrack>(
                value: currentTrack,
                isExpanded: true,
                dropdownColor: AppColors.panelCreamDark,
                style: const TextStyle(
                  color: AppColors.textEngraved,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
                borderRadius: BorderRadius.circular(16),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.brassGold,
                  size: 26,
                ),
                selectedItemBuilder: (BuildContext context) {
                  return tracks.map<Widget>((SoundTrack track) {
                    return Row(
                      children: [
                        const Icon(
                          Icons.audiotrack_rounded,
                          size: 16,
                          color: AppColors.brassGold,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textEngraved,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.panelCream,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderBrass),
                          ),
                          child: Text(
                            track.bpm,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brassGold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
                items: tracks.map((SoundTrack track) {
                  final isItemCurrent = track.id == currentTrack.id;
                  return DropdownMenuItem<SoundTrack>(
                    value: track,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isItemCurrent ? FontWeight.w900 : FontWeight.w700,
                                    color: isItemCurrent ? AppColors.brassGold : AppColors.textEngraved,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  track.genre,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.panelInset,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.grooveLight),
                            ),
                            child: Text(
                              track.bpm,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.brassGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (SoundTrack? newTrack) {
                  if (newTrack != null) {
                    _handleSelect(newTrack);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Track Details & Quick Actions Row
          Row(
            children: [
              // Vibe / Genre info
              Expanded(
                child: Text(
                  "${currentTrack.genre} • ${currentTrack.vibe}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Quick Preview Button
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _togglePreview(currentTrack),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPreviewing
                        ? AppColors.pinkAccent.withValues(alpha: 0.2)
                        : AppColors.metalHighlight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPreviewing ? AppColors.pinkAccent : AppColors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPreviewing ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                        size: 14,
                        color: isPreviewing ? AppColors.pinkAccent : AppColors.textEngraved,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPreviewing ? "PLAYING" : "PREVIEW",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: isPreviewing ? AppColors.pinkAccent : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Browse All Button (Opens Full Sound Library Dialog)
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  SoundLibraryDialog.show(
                    context: context,
                    currentTrackTitle: widget.selectedTrackTitle,
                    onSelectTrack: (t) => _handleSelect(t),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.brassGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderBrass),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.search_rounded, size: 14, color: AppColors.brassGold),
                      SizedBox(width: 4),
                      Text(
                        "BROWSE ALL",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brassGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

