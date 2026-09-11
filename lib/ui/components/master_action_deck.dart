import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'snapbeat_pink_dot.dart';
import 'splash_master_red_button.dart';

class MasterActionDeck extends StatelessWidget {
  final String currentMode;
  final Function(String mode) onSelectMode;
  final int photoCount;
  final VoidCallback onTriggerMaster;
  final int activeJobsCount;

  const MasterActionDeck({
    super.key,
    required this.currentMode,
    required this.onSelectMode,
    required this.photoCount,
    required this.onTriggerMaster,
    this.activeJobsCount = 0,
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
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Lower Mode Rocker Bar (Easy Thumb Navigation)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFC0B8AA),
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
                    _buildTab('auto', 'AUTO', Icons.auto_awesome_rounded),
                    const SizedBox(width: 4),
                    _buildTab('pro', 'PRO', Icons.tune_rounded),
                    const SizedBox(width: 4),
                    _buildTab('vault', 'MY REELS', Icons.movie_filter_rounded, badgeCount: activeJobsCount),
                  ],
                ),
              ),
            ),

            // 2. Action Area
            if (currentMode != 'vault')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Pink Dot + RENDER
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SnapBeatPinkDot(size: 13, withGlow: true),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'RENDER',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Color(0xFF222020),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.2,
                                    shadows: [
                                      Shadow(color: Color(0x99FFFFFF), offset: Offset(0, 1), blurRadius: 1),
                                    ],
                                  ),
                                ),
                                Text(
                                  photoCount > 0 ? '$photoCount SNAPS' : 'READY',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: photoCount > 0 ? const Color(0xFFC92A2A) : const Color(0xFF7A756D),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Center: Red Splash Trigger Button (compact diameter 58)
                    SplashMasterRedButton(
                      size: 58,
                      onTap: onTriggerMaster,
                    ),

                    const SizedBox(width: 14),

                    // Right: NOW + Pink Dot
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'NOW',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Color(0xFF222020),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.2,
                                    shadows: [
                                      Shadow(color: Color(0x99FFFFFF), offset: Offset(0, 1), blurRadius: 1),
                                    ],
                                  ),
                                ),
                                Text(
                                  photoCount > 0 ? 'BEAT SYNC' : 'TAP TO ADD',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF7A756D),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SnapBeatPinkDot(size: 13, withGlow: true),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              // Compact helper row in My Reels mode
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelectMode('auto'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SnapBeatPinkDot(size: 11, withGlow: true),
                      SizedBox(width: 8),
                      Text(
                        'TAP AUTO OR PRO ABOVE TO SCHEDULE ANOTHER REEL',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Color(0xFF4A463F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String mode, String label, IconData icon, {int badgeCount = 0}) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelectMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding: const EdgeInsets.symmetric(vertical: 7),
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
                const SnapBeatPinkDot(size: 9, withGlow: true),
                const SizedBox(width: 4),
              ],
              Icon(
                icon,
                size: 13,
                color: isSelected ? const Color(0xFF1E1A10) : const Color(0xFF5A554D),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: isSelected ? const Color(0xFF1E1A10) : const Color(0xFF4A463F),
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3366),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
