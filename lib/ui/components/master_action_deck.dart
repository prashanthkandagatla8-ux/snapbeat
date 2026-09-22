import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import 'snapbeat_pink_dot.dart';

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
        color: const Color(0xFF121418),
        border: const Border(
          top: BorderSide(color: AppColors.chassisBevelLight, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            offset: const Offset(0, -6),
            blurRadius: 18,
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
              color: const Color(0xFF0C0E12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.chassisBevelLight.withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 2),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ],
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
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFF6D28D9),
                      ],
                    )
                  : null,
              border: isSelected
                  ? Border.all(color: const Color(0xFFA78BFA), width: 1.0)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                        offset: const Offset(0, 3),
                        blurRadius: 10,
                        spreadRadius: 0.5,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  const SnapBeatPinkDot(size: 7, withGlow: true),
                  const SizedBox(width: 3),
                ],
                Icon(
                  isEnabled ? icon : Icons.lock_outline_rounded,
                  size: 13,
                  color: isSelected ? Colors.white : const Color(0xFF717682),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFFFF3366),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? const Color(0xFFFFE082) : Colors.white,
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
