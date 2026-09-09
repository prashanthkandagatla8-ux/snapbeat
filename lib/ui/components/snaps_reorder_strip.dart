import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';

class SnapsReorderStrip extends StatelessWidget {
  final List<PhotoItem> photos;
  final VoidCallback onPickPhotos;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String id) onDelete;
  final String arrangementMode;
  final Function(String mode) onArrangementChanged;

  const SnapsReorderStrip({
    super.key,
    required this.photos,
    required this.onPickPhotos,
    required this.onReorder,
    required this.onDelete,
    required this.arrangementMode,
    required this.onArrangementChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderGold),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text("📸", style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        "Curate Your Snaps",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${photos.length} Snaps Loaded (Max 60)",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onPickPhotos,
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 14, color: Colors.black),
                label: const Text("Pick Photos", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  elevation: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Arrangement Mode Pills
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.canvasDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                _buildModePill(context, "Sequential", "sequential"),
                _buildModePill(context, "Beat-Matched", "beat_matched"),
                _buildModePill(context, "Story Arc", "story_arc"),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Photo Reel with Numbered Badges & Delete
          SizedBox(
            height: 90,
            child: photos.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == photos.length) {
                        // Add more snap tile
                        return GestureDetector(
                          onTap: onPickPhotos,
                          child: Container(
                            width: 68,
                            height: 90,
                            decoration: BoxDecoration(
                              color: AppColors.canvasDark.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4), style: BorderStyle.solid),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, color: AppColors.goldBright, size: 24),
                                SizedBox(height: 2),
                                Text(
                                  "ADD",
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.goldBright),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final item = photos[index];
                      return Container(
                        width: 68,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: index == 0 ? AppColors.goldPrimary : AppColors.borderSubtle, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(item.path),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.cardSurfaceHigh,
                                  child: const Icon(Icons.image_outlined, color: AppColors.textDim),
                                ),
                              ),
                              // Numbered Badge
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.goldBright.withOpacity(0.6), width: 0.8),
                                  ),
                                  child: Text(
                                    "#${(index + 1).toString().padLeft(2, '0')}",
                                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.goldBright),
                                  ),
                                ),
                              ),
                              // Delete Button
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => onDelete(item.id),
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded, size: 10, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill(BuildContext context, String label, String value) {
    final isSelected = arrangementMode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onArrangementChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.goldPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap: onPickPhotos,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.canvasDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: AppColors.goldPrimary, size: 20),
            SizedBox(width: 8),
            Text(
              "Tap to load your snaps (Photos)",
              style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
