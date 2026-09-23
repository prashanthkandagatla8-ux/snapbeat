import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

class MasterActionDeck extends StatelessWidget {
  final String currentMode; // 'music', 'photos', 'render', 'queue'
  final Function(String mode) onSelectMode;
  final bool isPhotosEnabled;
  final bool isRenderEnabled;
  final int activeJobsCount;
  final Function(String mode)? onDisabledTabTap;

  const MasterActionDeck({
    super.key,
    required this.currentMode,
    required this.onSelectMode,
    required this.isPhotosEnabled,
    required this.isRenderEnabled,
    this.activeJobsCount = 0,
    this.onDisabledTabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.graphiteSubstrate,
        border: const Border(
          top: BorderSide(color: Color(0x0AFFFFFF), width: 1.0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x75000000),
            offset: Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: AppColors.graphiteRecess,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0x08FFFFFF),
                width: 1.0,
              ),
              boxShadow: AppColors.innerRecess,
            ),
            child: Row(
              children: [
                _buildTab(
                  mode: 'music',
                  label: 'MUSIC',
                  icon: Icons.library_music_rounded,
                  isEnabled: true,
                ),
                const SizedBox(width: 3),
                _buildTab(
                  mode: 'photos',
                  label: 'PHOTOS',
                  icon: Icons.photo_library_rounded,
                  isEnabled: true,
                ),
                const SizedBox(width: 3),
                _buildTab(
                  mode: 'render',
                  label: 'RENDER',
                  icon: Icons.movie_creation_rounded,
                  isEnabled: isRenderEnabled,
                ),
                const SizedBox(width: 3),
                _buildTab(
                  mode: 'queue',
                  label: 'QUEUE',
                  icon: Icons.video_collection_rounded,
                  isEnabled: true,
                  badgeCount: activeJobsCount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required String mode,
    required String label,
    required IconData icon,
    required bool isEnabled,
    int badgeCount = 0,
  }) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isEnabled) {
            HapticFeedback.heavyImpact();
            if (onDisabledTabTap != null) onDisabledTabTap!(mode);
          } else {
            HapticFeedback.selectionClick();
            onSelectMode(mode);
          }
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isEnabled ? 1.0 : 0.4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: isSelected ? AppColors.ctaButtonGradient : null,
              border: isSelected
                  ? Border.all(color: const Color(0x1AFFFFFF), width: 1.0)
                  : null,
              boxShadow: isSelected ? AppColors.contactSubtle : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.indicatorAccent,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.indicatorGlow,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Icon(
                  isEnabled ? icon : Icons.lock_outline_rounded,
                  size: 13,
                  color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: 0.5,
                        color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.indicatorAccent : AppColors.graphiteDeep,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.graphiteSubstrate : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
