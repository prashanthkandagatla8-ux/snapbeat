import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import 'snapbeat_pink_dot.dart';

class SnapsReorderStrip extends StatefulWidget {
  final List<PhotoItem> photos;
  final VoidCallback onAddPhotos;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String id) onDelete;
  final String arrangementMode;
  final Function(String mode) onArrangementModeChanged;
  final VoidCallback? onLoadSample;
  final VoidCallback? onAutoShuffle;
  final bool isEnabled;
  final int maxPhotos;
  final VoidCallback? onPromptSelectMusic;

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
    this.isEnabled = true,
    this.maxPhotos = 60,
    this.onPromptSelectMusic,
  });

  @override
  State<SnapsReorderStrip> createState() => _SnapsReorderStripState();
}

class _SnapsReorderStripState extends State<SnapsReorderStrip> {
  final ScrollController _gridScrollController = ScrollController();

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.chassisBevelLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
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
                                'SAMPLE SNAPS',
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
                    onTap: widget.onAddPhotos,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: photos.length >= maxPhotos
                            ? null
                            : const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFFE082), Color(0xFFFFC72C)],
                              ),
                        color: photos.length >= maxPhotos ? AppColors.panelCreamDark : null,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: photos.length >= maxPhotos ? AppColors.chassisBevelLight : const Color(0xFFBF8A00),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, offset: Offset(1, 2), blurRadius: 2),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.panelInset,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.chassisBevelDark),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildOrderingModeChip('auto', 'AUTO', Icons.auto_mode_rounded),
                        const SizedBox(width: 4),
                        _buildOrderingModeChip('manual', 'MANUAL', Icons.pan_tool_alt_rounded),
                      ],
                    ),
                    if (widget.onAutoShuffle != null && widget.arrangementMode == 'auto')
                      GestureDetector(
                        onTap: widget.onAutoShuffle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.panelCreamDark,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.chassisBevelLight),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.shuffle_rounded, size: 12, color: AppColors.brassGold),
                              SizedBox(width: 4),
                              Text(
                                'SHUFFLE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brassGold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (widget.arrangementMode == 'manual')
                      Row(
                        children: const [
                          Icon(Icons.tune_rounded, size: 13, color: AppColors.amberJewel),
                          SizedBox(width: 4),
                          Text(
                            'CUSTOM SEQUENCE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: AppColors.amberJewel,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.panelInset,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.chassisBevelDark.withValues(alpha: 0.7)),
                ),
                child: Row(
                  children: const [
                    SnapBeatPinkDot(size: 8, withGlow: true),
                    SizedBox(width: 8),
                    Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.brassGold),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Tap ◀ ▶ to nudge, or drag to reorder. Scroll vertically for all photos.',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 9.5,
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

            const SizedBox(height: 12),

            // 4. Large Grid Photo Container with Vertical Scrolling & Visible Scrollbar
            if (photos.isEmpty)
              GestureDetector(
                onTap: widget.onAddPhotos,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                        height: 42,
                        width: 42,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'READY FOR SNAPS — TAP TO ADD',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.textEngraved,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Capacity: up to $maxPhotos photos for current track duration.\nTap ADD PHOTOS (+) or SAMPLE SNAPS above to load photos.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9.5,
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
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 380,
                  child: RawScrollbar(
                    controller: _gridScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thumbColor: AppColors.brassGold,
                    trackColor: Colors.black12,
                    trackBorderColor: Colors.transparent,
                    radius: const Radius.circular(4),
                    thickness: 6,
                    child: GridView.builder(
                      controller: _gridScrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(right: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.84,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final p = photos[index];
                        return DragTarget<int>(
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
                                  width: 140,
                                  height: 160,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelCreamDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.arrangementMode == 'manual' ? AppColors.brassGold : AppColors.metalBrushedDark,
          width: widget.arrangementMode == 'manual' ? 1.8 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDragging ? 0.6 : 0.35),
            offset: const Offset(1, 3),
            blurRadius: isDragging ? 8 : 4,
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
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(p.path),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.panelInset,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_rounded, size: 28, color: AppColors.textMuted),
                        );
                      },
                    ),
                  ),
                ),
                // Tactile Delete Pin Button (top-right)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onDelete(p.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.vuRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 35mm Slide Mount Footer Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                      ? () => widget.onReorder(index, index - 1)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: index > 0 ? AppColors.panelCreamDark : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 11,
                      color: index > 0 ? AppColors.textEngraved : AppColors.textMuted.withValues(alpha: 0.25),
                    ),
                  ),
                ),

                // Order Number Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.panelCreamDark,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.chassisBevelLight),
                  ),
                  child: Text(
                    '#${(index + 1).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textEngraved,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // Move Later button
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: index < widget.photos.length - 1
                      ? () => widget.onReorder(index, index + 2)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: index < widget.photos.length - 1 ? AppColors.panelCreamDark : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
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

  Widget _buildOrderingModeChip(String mode, String label, IconData icon) {
    final isSel = widget.arrangementMode == mode;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onArrangementModeChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? AppColors.brassGold : AppColors.panelCreamDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? AppColors.borderBrass : AppColors.chassisBevelLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 11,
              color: isSel ? AppColors.hardwareGunmetal : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: isSel ? AppColors.hardwareGunmetal : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}