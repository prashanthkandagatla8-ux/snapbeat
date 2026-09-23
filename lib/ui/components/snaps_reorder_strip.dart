import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import 'snapbeat_pink_dot.dart';
import 'retro_metal_panel.dart';

class SnapsReorderStrip extends StatefulWidget {
  final List<PhotoItem> photos;
  final VoidCallback onAddPhotos;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String id) onDelete;
  final Function(String id)? onDuplicate;
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
    this.onDuplicate,
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
  bool _isSmallThumbnails = false;
  double _thumbnailScale = 1.0;

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
                  SnapBeatPinkDot(size: 13, withGlow: isEnabled),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isEnabled ? const Color(0xFF252A34) : const Color(0xFF13151B),
                      borderRadius: BorderRadius.circular(4),
                      border: isEnabled ? null : Border.all(color: AppColors.chassisBevelLight),
                    ),
                    child: Text(
                      '2. PHOTOS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isEnabled ? AppColors.hardwareGunmetal : AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
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
                      color: isEnabled ? AppColors.textEngraved : AppColors.amberJewel,
                    ),
                  ),
                ],
              ),
              if (isEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.panelInset,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.chassisBevelDark),
                  ),
                  child: Text(
                    photos.isNotEmpty ? 'CURATED' : 'WAITING',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.amberJewel,
                      letterSpacing: 0.6,
                    ),
                  ),
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
                      Icon(Icons.lock_rounded, size: 11, color: AppColors.amberJewel),
                      SizedBox(width: 4),
                      Text(
                        'STEP 2',
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.amberJewel),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E222A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.chassisBevelLight),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, offset: Offset(1, 2), blurRadius: 2),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.auto_awesome, size: 13, color: AppColors.brassGold),
                            SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'SAMPLE PHOTOS',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 9.5,
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: photos.length >= maxPhotos ? null : AppColors.luxGoldGradient,
                        color: photos.length >= maxPhotos ? AppColors.panelCreamDark : null,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: photos.length >= maxPhotos ? AppColors.chassisBevelLight : const Color(0xFFFFF6CC),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: photos.length >= maxPhotos
                                ? Colors.black26
                                : AppColors.brassGold.withValues(alpha: 0.35),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 14,
                            color: photos.length >= maxPhotos ? AppColors.textMuted : const Color(0xFF1E1A10),
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  color: photos.length >= maxPhotos ? AppColors.textMuted : const Color(0xFF1E1A10),
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
                decoration: BoxDecoration(
                  color: AppColors.panelInset,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.chassisBevelDark),
                ),
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
                                  color: AppColors.amberJewel,
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
                        borderRadius: BorderRadius.circular(8),
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
                              fontSize: 9.5,
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
                  borderRadius: BorderRadius.circular(8),
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
                                  decoration: BoxDecoration(
                                    color: AppColors.brassGold.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: AppColors.brassGold.withValues(alpha: 0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shuffle_rounded, size: 12, color: AppColors.brassGold),
                                      SizedBox(width: 4),
                                      Text(
                                        'SHUFFLE',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.brassGold,
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
                                  activeTrackColor: AppColors.brassGold,
                                  inactiveTrackColor: AppColors.chassisBevelDark,
                                  thumbColor: AppColors.brassGold,
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
                            const Icon(Icons.photo_size_select_large_rounded, size: 13, color: AppColors.brassGold),
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
                                    decoration: BoxDecoration(
                                      color: AppColors.panelCreamDark,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.chassisBevelLight),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.shuffle_rounded, size: 11, color: AppColors.brassGold),
                                        SizedBox(width: 3),
                                        Text(
                                          'SHUFFLE',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.brassGold,
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
                                    decoration: BoxDecoration(
                                      color: AppColors.amberGold.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.restart_alt_rounded, size: 10, color: AppColors.amberGold),
                                        SizedBox(width: 3),
                                        Text(
                                          'CLEAR',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.amberGold,
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
                  children: const [
                    SnapBeatPinkDot(size: 7, withGlow: true),
                    SizedBox(width: 6),
                    Icon(Icons.swap_horiz_rounded, size: 13, color: AppColors.brassGold),
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
              GestureDetector(
                onTap: widget.onAddPhotos,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.panelInset,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.chassisBevelDark),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.graphiteRecess,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x1AFFFFFF)),
                        ),
                        child: const Icon(Icons.add_photo_alternate_outlined, size: 24, color: AppColors.indicatorAccent),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Add Photos to Get Started',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.textEngraved,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Capacity: up to $maxPhotos photos for current track duration.\nTap ADD PHOTOS (+) or SAMPLE PHOTOS above to load photos.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.panelInset,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.chassisBevelDark),
                ),
                padding: const EdgeInsets.all(6),
                child: SizedBox(
                  height: (560 * _thumbnailScale).clamp(500.0, 680.0),
                  child: RawScrollbar(
                    controller: _gridScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thumbColor: AppColors.brassGold,
                    trackColor: Colors.black12,
                    trackBorderColor: Colors.transparent,
                    radius: const Radius.circular(4),
                    thickness: 5,
                    child: GridView.builder(
                      controller: _gridScrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(right: 6),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _isSmallThumbnails ? 3 : 2,
                        childAspectRatio: _isSmallThumbnails ? 0.72 : 0.75,
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
                                borderRadius: BorderRadius.circular(8),
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
                                  borderRadius: BorderRadius.circular(8),
                                  border: isHovered
                                      ? Border.all(color: AppColors.pinkAccent, width: 2.5)
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
        decoration: BoxDecoration(
          color: const Color(0xFFFDFEFE),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDragging ? 0.6 : 0.25),
              offset: const Offset(2, 4),
              blurRadius: isDragging ? 12 : 8,
              spreadRadius: isDragging ? 2 : 0,
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          isSmall ? 3 : 4,
          isSmall ? 3 : 4,
          isSmall ? 3 : 4,
          isSmall ? 4 : 6,
        ),
        child: Column(
          children: [
            // Glossy photo inset
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
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
                          padding: EdgeInsets.all(isSmall ? 2.5 : 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1116),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x50FFFFFF), width: 0.8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x60000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(Icons.close_rounded, size: isSmall ? 10 : 12, color: Colors.white),
                        ),
                      ),
                    ),
                    // Tactile Duplicate Pin Button (top-left)
                    if (widget.onDuplicate != null)
                      Positioned(
                        top: isSmall ? 2 : 4,
                        left: isSmall ? 2 : 4,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onDuplicate!(p.id),
                          child: Container(
                            padding: EdgeInsets.all(isSmall ? 2.5 : 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1116),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0x50FFFFFF), width: 0.8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x60000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(Icons.copy_rounded, size: isSmall ? 9 : 11, color: Colors.white),
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
          color: AppColors.amberJewel,
        ),
      ),
    );
  }
}
