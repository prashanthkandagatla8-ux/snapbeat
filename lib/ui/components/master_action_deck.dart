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
    final bool isVault = currentMode == 'vault';
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
              // 1. Render Button on Top (Centered, No text beside it, disabled in My Reels)
              SplashMasterRedButton(
                size: 58,
                onTap: isVault ? null : onTriggerMaster,
                isEnabled: !isVault,
              ),

              // 2. Small font text below the button
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SnapBeatPinkDot(size: 8, withGlow: !isVault),
                  const SizedBox(width: 6),
                  Text(
                    isVault
                        ? 'DISABLED IN MY REELS'
                        : (photoCount > 0 ? 'RENDER NOW • $photoCount SNAPS' : 'RENDER NOW'),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: isVault ? const Color(0xFF8A857D) : const Color(0xFF2E2B27),
                      shadows: isVault
                          ? null
                          : const [
                              Shadow(color: Color(0x88FFFFFF), offset: Offset(0, 1), blurRadius: 1),
                            ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // 3. Lower Mode Switcher Panel (Exact same height across all modes)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      _buildTab('auto', 'AUTO', Icons.auto_awesome_rounded),
                      const SizedBox(width: 4),
                      _buildTab('pro', 'PRO', Icons.tune_rounded),
                      const SizedBox(width: 4),
                      _buildTab('vault', 'MY REELS', Icons.movie_filter_rounded, badgeCount: activeJobsCount),
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
