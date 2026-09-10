import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';

class SnapsReorderStrip extends StatelessWidget {
  final List<PhotoItem> photos;
  final VoidCallback onAddPhotos;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String id) onDelete;
  final String arrangementMode;
  final Function(String mode) onArrangementModeChanged;
  final VoidCallback? onLoadSample;

  const SnapsReorderStrip({
    super.key,
    required this.photos,
    required this.onAddPhotos,
    required this.onReorder,
    required this.onDelete,
    required this.arrangementMode,
    required this.onArrangementModeChanged,
    this.onLoadSample,
  });

  @override
  Widget build(BuildContext context) {
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
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.brassGold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PHOTOS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.hardwareGunmetal,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${photos.length})',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (onLoadSample != null) ...[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onLoadSample,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppColors.panelCreamDark,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.chassisBevelLight),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.auto_awesome, size: 12, color: AppColors.textEngraved),
                            SizedBox(width: 4),
                            Text(
                              'DEMO',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: AppColors.textEngraved,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onAddPhotos,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.panelCreamDark,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.chassisBevelLight),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.add_photo_alternate_rounded, size: 12, color: AppColors.textEngraved),
                          SizedBox(width: 4),
                          Text(
                            'ADD PHOTOS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: AppColors.textEngraved,
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
          const SizedBox(height: 12),

          // Slides Horizontal Carousel
          SizedBox(
            height: 130,
            child: photos.isEmpty
                ? GestureDetector(
                    onTap: onAddPhotos,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.panelInset,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.chassisBevelDark, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_roll_outlined, size: 32, color: AppColors.textMuted),
                          SizedBox(height: 6),
                          Text(
                            'No photos yet — tap to add',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    // ignore: deprecated_member_use
                    onReorder: onReorder,
                    itemBuilder: (context, index) {
                      final p = photos[index];
                      return Container(
                        key: ValueKey(p.id),
                        margin: const EdgeInsets.only(right: 12),
                        width: 90,
                        decoration: BoxDecoration(
                          color: AppColors.panelCreamDark,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.metalBrushedDark, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              offset: const Offset(2, 3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // 35mm Slide Window
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 6, right: 6, bottom: 24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.file(
                                  File(p.path),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.panelInset,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.broken_image_rounded, size: 24, color: AppColors.textMuted),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Slide Mount Footer
                            Positioned(
                              bottom: 4,
                              left: 6,
                              right: 6,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#${(index + 1).toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontFamily: 'Courier',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Delete Pin
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => onDelete(p.id),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppColors.vuRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, size: 10, color: Colors.white),
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