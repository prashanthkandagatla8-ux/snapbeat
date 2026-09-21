import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import 'snapbeat_pink_dot.dart';

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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.luxDarkCardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.chassisBevelLight.withValues(alpha: 0.9), width: 1.2),
        boxShadow: AppColors.luxCardShadow,
      ),
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
                      color: isEnabled ? AppColors.brassGold : AppColors.panelCreamDark,
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
                          color: AppColors.metalBrushedDark,
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
                        Image.asset(
                          'assets/images/snapbeat_mascot.png',
                          height: 48,
                          width: 48,
                          fit: BoxFit.contain,
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
                        // 1. ARRANGE Group: AUTO & MANUAL
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildGroupLabel('ARRANGE:'),
                            const SizedBox(width: 4),
                            _buildOrderingModeChip('auto', 'AUTO', Icons.auto_mode_rounded),
                            const SizedBox(width: 3),
                            _buildOrderingModeChip('manual', 'MANUAL', Icons.pan_tool_alt_rounded),
                          ],
                        ),
                        // 2. VIEW Group: BIG Thumbnails
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildGroupLabel('VIEW:'),
                            const SizedBox(width: 4),
                            _buildBigModeChip(),
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
                                      color: AppColors.vuRed.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.vuRed.withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.restart_alt_rounded, size: 10, color: AppColors.vuRed),
                                        SizedBox(width: 3),
                                        Text(
                                          'CLEAR',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.vuRed,
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
                      Image.asset(
                        'assets/images/snapbeat_mascot.png',
                        height: 38,
                        width: 38,
                        fit: BoxFit.contain,
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
                  height: _isSmallThumbnails ? 195 : 215,
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
                        childAspectRatio: _isSmallThumbnails ? 0.80 : 0.86,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelCreamDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.arrangementMode == 'manual' ? AppColors.brassGold : AppColors.metalBrushedDark,
          width: widget.arrangementMode == 'manual' ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDragging ? 0.6 : 0.3),
            offset: const Offset(1, 2),
            blurRadius: isDragging ? 6 : 3,
          ),
        ],
      ),
      child: Column(
        children: [
          // 35mm Slide Image Window
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isSmall ? 4 : 5,
                    isSmall ? 4 : 5,
                    isSmall ? 4 : 5,
                    isSmall ? 2 : 2,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SnapsReorderStrip.photoImageCache[p.path] != null
                        ? RawImage(
                            image: SnapsReorderStrip.photoImageCache[p.path],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(p.path),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            cacheWidth: 240,
                            cacheHeight: 300,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.panelInset,
                                alignment: Alignment.center,
                                child: Icon(Icons.broken_image_rounded, size: isSmall ? 20 : 26, color: AppColors.textMuted),
                              );
                            },
                          ),
                  ),
                ),
                // Tactile Delete Pin Button (top-right)
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
                        color: AppColors.vuRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
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
                          color: AppColors.brassGold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(Icons.copy_rounded, size: isSmall ? 9 : 11, color: const Color(0xFF1E1A10)),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 35mm Slide Mount Footer Controls
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 4 : 6,
              vertical: isSmall ? 2 : 3,
            ),
            decoration: const BoxDecoration(
              color: AppColors.panelInset,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Move Earlier button
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: index > 0
                      ? () {
                          HapticFeedback.selectionClick();
                          widget.onReorder(index, index - 1);
                        }
                      : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: isSmall ? 3 : 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: index > 0 ? AppColors.panelCreamDark : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: isSmall ? 9 : 11,
                      color: index > 0 ? AppColors.textEngraved : AppColors.textMuted.withValues(alpha: 0.25),
                    ),
                  ),
                ),

                // Order Number Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isSmall ? 4 : 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    gradient: index == 0 ? AppColors.luxGoldGradient : null,
                    color: index == 0 ? null : AppColors.panelCreamDark,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: index == 0 ? const Color(0xFFFFF6CC) : AppColors.chassisBevelLight),
                    boxShadow: index == 0
                        ? [
                            BoxShadow(
                              color: AppColors.brassGold.withValues(alpha: 0.35),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    index == 0 ? 'COVER' : '#${(index + 1).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontFamily: index == 0 ? 'Montserrat' : 'Courier',
                      fontSize: isSmall ? 8 : 9,
                      fontWeight: FontWeight.w900,
                      color: index == 0 ? AppColors.hardwareGunmetal : AppColors.textEngraved,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),

                // Move Later button
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: index < widget.photos.length - 1
                      ? () {
                          HapticFeedback.selectionClick();
                          widget.onReorder(index, index + 2);
                        }
                      : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: isSmall ? 3 : 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: index < widget.photos.length - 1 ? AppColors.panelCreamDark : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: isSmall ? 9 : 11,
                      color: index < widget.photos.length - 1
                          ? AppColors.textEngraved
                          : AppColors.textMuted.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildOrderingModeChip(String mode, String label, IconData icon) {
    final isSel = widget.arrangementMode == mode;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onArrangementModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? AppColors.brassGold : AppColors.metalDeepCavity,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSel ? const Color(0xFFBF8A00) : AppColors.chassisBevelDark,
            width: isSel ? 1.4 : 1.0,
          ),
          boxShadow: isSel
              ? [
                  BoxShadow(
                    color: AppColors.amberGlow.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 10.5,
              color: isSel ? AppColors.hardwareGunmetal : AppColors.textMuted,
            ),
            const SizedBox(width: 3.5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
                color: isSel ? AppColors.hardwareGunmetal : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigModeChip() {
    final isBig = !_isSmallThumbnails;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _isSmallThumbnails = !_isSmallThumbnails),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isBig ? AppColors.brassGold : AppColors.metalDeepCavity,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isBig ? const Color(0xFFBF8A00) : AppColors.chassisBevelDark,
            width: isBig ? 1.4 : 1.0,
          ),
          boxShadow: isBig
              ? [
                  BoxShadow(
                    color: AppColors.amberGlow.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.view_agenda_rounded,
              size: 10.5,
              color: isBig ? AppColors.hardwareGunmetal : AppColors.textMuted,
            ),
            const SizedBox(width: 3.5),
            Text(
              'BIG',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
                color: isBig ? AppColors.hardwareGunmetal : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}