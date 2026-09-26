import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import 'neomorphic_kit.dart';
import 'retro_metal_panel.dart';

class SnapsReorderStrip extends StatefulWidget {
  final List<PhotoItem> photos;
  final VoidCallback onAddPhotos;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String id) onDelete;
  final String arrangementMode;
  final Function(String mode) onArrangementModeChanged;
  final VoidCallback? onLoadSample;
  final VoidCallback? onAutoShuffle;
  final VoidCallback? onClearAll;
  final VoidCallback? onResetPhotos;
  final bool isEnabled;
  final int maxPhotos;
  final VoidCallback? onPromptSelectMusic;

  static final Map<String, ui.Image> photoImageCache = {};

  static void disposeImageCache() {
    for (final img in photoImageCache.values) {
      img.dispose();
    }
    photoImageCache.clear();
  }

  const SnapsReorderStrip({
    super.key,
    required this.photos,
    required this.onAddPhotos,
    required this.onReorder,
    required this.onDelete,
    required this.arrangementMode,
    required this.onArrangementModeChanged,
    this.onLoadSample,
    this.onAutoShuffle,
    this.onClearAll,
    this.onResetPhotos,
    this.isEnabled = true,
    this.maxPhotos = 60,
    this.onPromptSelectMusic,
  });

  @override
  State<SnapsReorderStrip> createState() => _SnapsReorderStripState();
}

class _SnapsReorderStripState extends State<SnapsReorderStrip> {
  final ScrollController _gridScrollController = ScrollController();
  bool _isSmallThumbnails = true;
  double _thumbnailScale = 0.75;

  VoidCallback? get _effectiveClear => widget.onClearAll ?? widget.onResetPhotos;

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    final isEnabled = widget.isEnabled;
    final maxPhotos = widget.maxPhotos;

    return RetroMetalPanel(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Nameplate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.iridescentGradient)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111722),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x18FFFFFF), width: 1.0),
                      boxShadow: AppColors.darkHardwareShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.photo_library_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          '2. PHOTOS',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEnabled ? '(${photos.length} / $maxPhotos max)' : '(LOCKED)',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isEnabled ? AppColors.textEngraved : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (isEnabled)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (photos.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.only(left: 4, right: 10, top: 4, bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.panelInset,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.chassisBevelLight, width: 1.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.canvasBg,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/snapbeat_camera_mascot.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Text(
                                  'SYNCHRONIZED',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDarkText,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Positioned(
                                  top: -2,
                                  right: -8,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.greenAccent,
                                      boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 4)],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111722),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x18FFFFFF), width: 1.0),
                        boxShadow: AppColors.darkHardwareShadow,
                      ),
                      child: Text(
                        photos.isNotEmpty ? 'CURATED' : 'WAITING',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.panelCreamDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.chassisBevelLight),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_rounded, size: 11, color: AppColors.primaryDarkText),
                      SizedBox(width: 4),
                      Text(
                        'STEP 2',
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.primaryDarkText),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // 2. Action Buttons in Dedicated Full-Width Row (never overflows!)
          if (isEnabled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.onLoadSample != null) ...[
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onLoadSample,
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7F8),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: AppColors.softRaisedShadow,
                          border: Border.all(color: const Color(0xB3FFFFFF), width: 1.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.auto_awesome, size: 18, color: AppColors.textInkBlack),
                            SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'SAMPLE PHOTOS',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: AppColors.textEngraved,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: photos.length >= maxPhotos
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            widget.onAddPhotos();
                          },
                    child: Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: photos.length >= maxPhotos ? null : AppColors.darkHardwareGradient,
                        color: photos.length >= maxPhotos ? const Color(0xFFECEFF3) : null,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: photos.length >= maxPhotos ? null : AppColors.darkHardwareShadow,
                        border: Border.all(color: const Color(0x12FFFFFF), width: 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 20,
                            color: photos.length >= maxPhotos ? AppColors.textMuted : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                photos.length >= maxPhotos ? 'FULL ($maxPhotos MAX)' : 'ADD PHOTOS (+)',
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: photos.length >= maxPhotos ? AppColors.textMuted : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (!isEnabled) ...[
            const SizedBox(height: 12),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onPromptSelectMusic,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.graphiteRecess,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x1AFFFFFF)),
                          ),
                          child: const Icon(Icons.music_note_rounded, size: 26, color: AppColors.indicatorAccent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'CHOOSE MUSIC IN STEP 1 FIRST',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: AppColors.primaryDarkText,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Select or load a soundtrack in Step 1. We calculate the exact photo capacity based on your track length & beat tempo.',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: AppColors.brassKnobGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.hardwareGunmetal),
                          SizedBox(width: 6),
                          Text(
                            'CHOOSE MUSIC IN STEP 1 TO UNLOCK',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: AppColors.hardwareGunmetal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // 3. Ordering Mode & Shuffle Bar (when photos present)
            if (photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.panelInset,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.chassisBevelDark),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Quick Actions: Auto Shuffle & Reset
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.onAutoShuffle != null)
                              InkWell(
                                onTap: widget.onAutoShuffle,
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: NeumorphicKit.raisedPill(radius: 5),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shuffle_rounded, size: 12, color: AppColors.textInkBlack),
                                      SizedBox(width: 4),
                                      Text(
                                        'SHUFFLE',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textInkBlack,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // 2. VIEW Group: Photo Preview Size Slider
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildGroupLabel('SIZE:'),
                            const SizedBox(width: 4),
                            const Icon(Icons.photo_size_select_small_rounded, size: 12, color: AppColors.textMuted),
                            SizedBox(
                              width: 75,
                              height: 24,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2.5,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.5),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 9),
                                  activeTrackColor: AppColors.primaryDarkText,
                                  inactiveTrackColor: AppColors.chassisBevelDark,
                                  thumbColor: AppColors.primaryDarkText,
                                ),
                                child: Slider(
                                  value: _thumbnailScale,
                                  min: 0.75,
                                  max: 1.25,
                                  onChanged: (val) => setState(() {
                                    _thumbnailScale = val;
                                    _isSmallThumbnails = val < 0.95;
                                  }),
                                ),
                              ),
                            ),
                            const Icon(Icons.photo_size_select_large_rounded, size: 13, color: AppColors.textSecondary),
                          ],
                        ),
                      ],
                    ),
                    if ((widget.onAutoShuffle != null && widget.arrangementMode == 'auto') || _effectiveClear != null) ...[
                      const SizedBox(height: 6),
                      Container(height: 1, color: AppColors.chassisBevelDark.withValues(alpha: 0.5)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.arrangementMode == 'auto'
                                ? 'Beat-synced automatic sequence'
                                : 'Manual drag-and-drop order',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.onAutoShuffle != null && widget.arrangementMode == 'auto') ...[
                                GestureDetector(
                                  onTap: widget.onAutoShuffle,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                    decoration: NeumorphicKit.pianoBlackPill(radius: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.shuffle_rounded, size: 11, color: Colors.white),
                                        SizedBox(width: 3),
                                        Text(
                                          'SHUFFLE',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                              ],
                              if (_effectiveClear != null)
                                GestureDetector(
                                  onTap: _effectiveClear,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: NeumorphicKit.pianoBlackPill(radius: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.restart_alt_rounded, size: 10, color: Colors.white),
                                        SizedBox(width: 3),
                                        Text(
                                          'CLEAR',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
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
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.panelInset,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.chassisBevelDark.withValues(alpha: 0.7)),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.iridescentGradient)),
                    SizedBox(width: 6),
                    Icon(Icons.swap_horiz_rounded, size: 13, color: AppColors.textSecondary),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Tap arrows to nudge or drag to reorder.',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textEngraved,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // 4. Large Grid Photo Container with Vertical Scrolling & Visible Scrollbar
            if (photos.isEmpty)
              Container(
                width: double.infinity,
                height: math.max(400.0, MediaQuery.sizeOf(context).height - 240),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.panelInset,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.chassisBevelDark),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/snapbeat_camera_mascot.png',
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                    Container(
                      width: 80,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0x20352A20),
                        borderRadius: BorderRadius.all(Radius.elliptical(80, 10)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.canvasBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: AppColors.softRaisedShadow,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'SNAPBEAT CAM · READY TO ROLL!',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: AppColors.textEngraved,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Select 3 to 12 photos and I'll sync them seamlessly to your music.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.onLoadSample != null) ...[
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: widget.onLoadSample,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: NeumorphicKit.raisedPill(radius: 20),
                                    child: const Text(
                                      'LOAD SAMPLES',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textInkBlack,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: widget.onAddPhotos,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.darkHardwareGradient,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: AppColors.darkHardwareShadow,
                                  ),
                                  child: const Text(
                                    'ADD PHOTOS (+)',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(color: Colors.transparent),
                padding: const EdgeInsets.all(6),
                child: SizedBox(
                  height: math.max(400.0, MediaQuery.sizeOf(context).height - 240),
                  child: RawScrollbar(
                    controller: _gridScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thumbColor: const Color(0xFFCBD5E1),
                    trackColor: Colors.transparent,
                    trackBorderColor: Colors.transparent,
                    radius: const Radius.circular(4),
                    thickness: 5,
                    child: GridView.builder(
                      controller: _gridScrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(right: 6, bottom: 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _isSmallThumbnails ? 3 : 2,
                        childAspectRatio: _isSmallThumbnails ? 0.72 : 0.76,
                        crossAxisSpacing: _isSmallThumbnails ? 6 : 8,
                        mainAxisSpacing: _isSmallThumbnails ? 6 : 8,
                      ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final p = photos[index];
                        return DragTarget<int>(
                          key: ValueKey(p.id),
                          onAcceptWithDetails: (details) {
                            final oldIdx = details.data;
                            if (oldIdx != index) {
                              widget.onReorder(
                                oldIdx,
                                index > oldIdx ? index + 1 : index,
                              );
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            final isHovered = candidateData.isNotEmpty;
                            return LongPressDraggable<int>(
                              data: index,
                              feedback: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: _isSmallThumbnails ? 100 : 140,
                                  height: _isSmallThumbnails ? 125 : 160,
                                  child: _buildGridPhotoCard(p, index, isDragging: true),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.35,
                                child: _buildGridPhotoCard(p, index),
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: isHovered
                                      ? Border.all(color: AppColors.primaryDarkText, width: 2.5)
                                      : null,
                                ),
                                child: _buildGridPhotoCard(p, index),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridPhotoCard(PhotoItem p, int index, {bool isDragging = false}) {
    final isSmall = _isSmallThumbnails;
    final angle = isDragging ? 0.0 : ((index % 5 - 2) * 0.012);

    return Transform.rotate(
      angle: angle,
      child: Container(
        decoration: isDragging
            ? AppColors.tactileWhiteCardDecoration.copyWith(
                boxShadow: const [
                  BoxShadow(color: Color(0x2E1E2837), offset: Offset(0, 18), blurRadius: 35, spreadRadius: 0),
                  BoxShadow(color: Color(0xE6FFFFFF), offset: Offset(0, -4), blurRadius: 12, spreadRadius: 0),
                ])
            : AppColors.tactileWhiteCardDecoration,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Glossy photo inset
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SnapsReorderStrip.photoImageCache[p.path] != null
                        ? RawImage(
                            image: SnapsReorderStrip.photoImageCache[p.path],
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(p.path),
                            fit: BoxFit.cover,
                            cacheWidth: 240,
                            cacheHeight: 300,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFE2E8F0),
                                alignment: Alignment.center,
                                child: Icon(Icons.broken_image_rounded, size: isSmall ? 20 : 26, color: const Color(0xFF94A3B8)),
                              );
                            },
                          ),
                    // Subtle photo gloss reflection
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.12),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.15),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                    // Tactile Delete Pin Button (top-right) - Dark pill with specular rim
                    Positioned(
                      top: isSmall ? 2 : 4,
                      right: isSmall ? 2 : 4,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          final removed = SnapsReorderStrip.photoImageCache.remove(p.id) ??
                              SnapsReorderStrip.photoImageCache.remove(p.path);
                          removed?.dispose();
                          widget.onDelete(p.id);
                        },
                        child: Container(
                          width: isSmall ? 28 : 34,
                          height: isSmall ? 28 : 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF111722),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x25FFFFFF), width: 0.8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x50000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.close_rounded, size: isSmall ? 13 : 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Polaroid Bottom Chin (Index stamp & tactile nudge arrows)
            Padding(
              padding: EdgeInsets.only(top: isSmall ? 3 : 5, bottom: isSmall ? 1 : 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Move Earlier nudge arrow
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: index > 0
                        ? () {
                            HapticFeedback.selectionClick();
                            widget.onReorder(index, index - 1);
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: isSmall ? 9 : 11,
                        color: index > 0 ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),

                  // Polaroid Chin Index Stamp
                  Text(
                    index == 0 ? 'COVER' : '#${(index + 1).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontFamily: index == 0 ? 'Montserrat' : 'Courier',
                      fontSize: isSmall ? 8.5 : 10,
                      fontWeight: FontWeight.w900,
                      color: index == 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),

                  // Move Later nudge arrow
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: index < widget.photos.length - 1
                        ? () {
                            HapticFeedback.selectionClick();
                            widget.onReorder(index, index + 2);
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: isSmall ? 9 : 11,
                        color: index < widget.photos.length - 1
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.metalDeepCavity,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.chassisBevelDark, width: 0.8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
          color: AppColors.primaryDarkText,
        ),
      ),
    );
  }
}
