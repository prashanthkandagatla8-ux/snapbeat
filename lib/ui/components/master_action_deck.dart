import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'snapbeat_pink_dot.dart';

class MasterActionDeck extends StatelessWidget {
  final String currentMode; // 'music', 'photos', 'render', 'queue'
  final Function(String mode) onSelectMode;
  final bool hasMusic;
  final bool isPhotosEnabled;
  final bool isRenderEnabled;
  final int activeJobsCount;
  final Function(String mode)? onDisabledTabTap;

  const MasterActionDeck({
    super.key,
    required this.currentMode,
    required this.onSelectMode,
    required this.hasMusic,
    required this.isPhotosEnabled,
    required this.isRenderEnabled,
    this.activeJobsCount = 0,
    this.onDisabledTabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.metalBase,
        border: const Border(
          top: BorderSide(color: Color(0xFFE8E3DA), width: 1.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Container(
            height: 42,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFB8AE9F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDED8CE), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 1),
                  blurRadius: 2,
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
                  isEnabled: isPhotosEnabled,
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
            if (onDisabledTabTap != null) onDisabledTabTap!(mode);
          } else {
            onSelectMode(mode);
          }
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isEnabled ? 1.0 : 0.42,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFE082),
                        Color(0xFFFFC72C),
                      ],
                    )
                  : null,
              border: isSelected ? Border.all(color: const Color(0xFFBF8A00), width: 1) : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 3,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  const SnapBeatPinkDot(size: 8, withGlow: true),
                  const SizedBox(width: 3),
                ],
                Icon(
                  isEnabled ? icon : Icons.lock_outline_rounded,
                  size: 12,
                  color: isSelected ? const Color(0xFF1E1A10) : const Color(0xFF5A554D),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: isSelected ? const Color(0xFF1E1A10) : const Color(0xFF4A463F),
                    ),
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1E1A10) : const Color(0xFFFF3366),
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
