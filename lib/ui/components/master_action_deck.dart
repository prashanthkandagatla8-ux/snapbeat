import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'snapbeat_pink_dot.dart';
import 'splash_master_red_button.dart';

class MasterActionDeck extends StatelessWidget {
  final String currentMode; // 'music', 'photos', 'render', 'queue'
  final Function(String mode) onSelectMode;
  final int photoCount;
  final bool hasMusic;
  final bool isPhotosEnabled;
  final bool isRenderEnabled;
  final VoidCallback onTriggerMaster;
  final int activeJobsCount;
  final Function(String mode)? onDisabledTabTap;

  const MasterActionDeck({
    super.key,
    required this.currentMode,
    required this.onSelectMode,
    required this.photoCount,
    required this.hasMusic,
    required this.isPhotosEnabled,
    required this.isRenderEnabled,
    required this.onTriggerMaster,
    this.activeJobsCount = 0,
    this.onDisabledTabTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isQueue = currentMode == 'queue';
    final bool canRender = isRenderEnabled && !isQueue;

    String statusText;
    if (isQueue) {
      statusText = 'DISABLED IN QUEUE';
    } else if (!hasMusic) {
      statusText = 'SELECT MUSIC FIRST';
    } else if (photoCount == 0) {
      statusText = 'ADD PHOTOS FIRST';
    } else {
      statusText = 'RENDER NOW • $photoCount SNAPS';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.metalBase,
        border: const Border(
          top: BorderSide(color: Color(0xFFE8E3DA), width: 1.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Render Button on Top (Centered, tactile feedback, enabled when ready)
              SplashMasterRedButton(
                size: 58,
                onTap: canRender ? onTriggerMaster : null,
                isEnabled: canRender,
              ),

              // 2. Status text below button
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SnapBeatPinkDot(size: 8, withGlow: canRender),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: canRender ? const Color(0xFF2E2B27) : const Color(0xFF8A857D),
                      shadows: canRender
                          ? const [
                              Shadow(color: Color(0x88FFFFFF), offset: Offset(0, 1), blurRadius: 1),
                            ]
                          : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // 3. Lower 4-Stage Navigation Switcher: [MUSIC, PHOTOS, RENDER, QUEUE]
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  height: 38,
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
                        badgeCount: photoCount > 0 ? photoCount : 0,
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
            ],
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
