import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import 'neomorphic_kit.dart';

class MasterActionDeck extends StatelessWidget {
  final String currentMode; // 'music', 'photos', 'title', 'render', 'queue'
  final Function(String mode) onSelectMode;
  final bool isPhotosEnabled;
  final bool isTitleEnabled;
  final bool isRenderEnabled;
  final bool isManualMode;
  final Function(bool isManual) onToggleManualMode;
  final String actionButtonText;
  final String actionButtonSubtitle;
  final IconData actionIcon;
  final bool isActionEnabled;
  final VoidCallback onActionPressed;
  final int activeJobsCount;
  final Function(String mode)? onDisabledTabTap;

  const MasterActionDeck({
    super.key,
    required this.currentMode,
    required this.onSelectMode,
    required this.isPhotosEnabled,
    required this.isTitleEnabled,
    required this.isRenderEnabled,
    required this.isManualMode,
    required this.onToggleManualMode,
    required this.actionButtonText,
    required this.actionButtonSubtitle,
    required this.actionIcon,
    required this.isActionEnabled,
    required this.onActionPressed,
    this.activeJobsCount = 0,
    this.onDisabledTabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1D25),
            Color(0xFF0A0C11),
            Color(0xFF030406),
          ],
        ),
        border: const Border(
          top: BorderSide(
            color: Color(0x40FFFFFF),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
          const BoxShadow(
            color: Color(0x10FFFFFF),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. TOP STEPPER TABS ROW
              Container(
                height: 42,
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF181A22), Color(0xFF0C0D11)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0x25FFFFFF),
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x50000000), offset: Offset(0, 2), blurRadius: 6),
                    BoxShadow(color: Color(0x10FFFFFF), offset: Offset(0, -1), blurRadius: 2),
                  ],
                ),
                child: Row(
                  children: [
                    _buildTab(
                      mode: 'music',
                      label: '1. MUSIC',
                      icon: Icons.library_music_rounded,
                      isEnabled: true,
                    ),
                    const SizedBox(width: 3),
                    _buildTab(
                      mode: 'photos',
                      label: '2. PHOTOS',
                      icon: Icons.photo_library_rounded,
                      isEnabled: isPhotosEnabled,
                    ),
                    const SizedBox(width: 3),
                    _buildTab(
                      mode: 'title',
                      label: '3. TITLE',
                      icon: Icons.title_rounded,
                      isEnabled: isTitleEnabled,
                    ),
                    if (isManualMode) ...[
                      const SizedBox(width: 3),
                      _buildTab(
                        mode: 'render',
                        label: '4. RENDER',
                        icon: Icons.movie_creation_rounded,
                        isEnabled: isRenderEnabled,
                      ),
                    ],
                    const SizedBox(width: 3),
                    _buildTab(
                      mode: 'queue',
                      label: 'VAULT',
                      icon: Icons.video_collection_rounded,
                      isEnabled: true,
                      badgeCount: activeJobsCount,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 2. LOWER ACTION BAR: [ AUTO | MANUAL ] + SHINING PIANO BLACK CTA
              Row(
                children: [
                  // Mode Selector Pill [ AUTO ⚡ | MANUAL ⚙️ ]
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(3.0),
                    decoration: NeumorphicKit.darkSunkenWell(radius: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModeChip(
                          label: 'AUTO',
                          icon: Icons.bolt_rounded,
                          isSelected: !isManualMode,
                          activeColor: Colors.white,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onToggleManualMode(false);
                          },
                        ),
                        const SizedBox(width: 2),
                        _buildModeChip(
                          label: 'MANUAL',
                          icon: Icons.tune_rounded,
                          isSelected: isManualMode,
                          activeColor: Colors.white,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onToggleManualMode(true);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Shining Piano Black CTA Button
                  Expanded(
                    child: Opacity(
                      opacity: isActionEnabled ? 1.0 : 0.45,
                      child: InkWell(
                        onTap: isActionEnabled ? onActionPressed : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13.5),
                            gradient: isActionEnabled ? AppColors.iridescentGradient : null,
                            boxShadow: isActionEnabled
                                ? const [
                                    BoxShadow(
                                      color: Color(0x60B026FF),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(color: Color(0x50000000), offset: Offset(0, 4), blurRadius: 10),
                                  ]
                                : null,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF262832), Color(0xFF14151B), Color(0xFF0A0B0E)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: isActionEnabled ? null : Border.all(
                                color: const Color(0x14FFFFFF),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  actionIcon,
                                  size: 18,
                                  color: isActionEnabled ? const Color(0xFFFFFFFF) : AppColors.textMuted,
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          actionButtonText,
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                            color: isActionEnabled ? const Color(0xFFFFFFFF) : AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                      if (actionButtonSubtitle.isNotEmpty)
                                        Text(
                                          actionButtonSubtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFA6ABB8),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 15,
                                  color: isActionEnabled ? const Color(0xFFFFFFFF) : AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: isSelected ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9.5),
          gradient: isSelected ? AppColors.iridescentGradient : null,
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x60000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF07080A) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 8.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                letterSpacing: 0.6,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
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
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSelected ? const Color(0xFFF2F4F6) : const Color(0xFF0D1015),
              border: Border.all(
                color: isSelected ? const Color(0xB3FFFFFF) : const Color(0x12FFFFFF),
                width: 1.0,
              ),
              boxShadow: isSelected ? AppColors.softRaisedShadow : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 12,
                  color: isSelected ? const Color(0xFF18202B) : const Color(0xFF9AA2AE),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 8.5,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      letterSpacing: 0.4,
                      color: isSelected ? const Color(0xFF18202B) : const Color(0xFF9AA2AE),
                    ),
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0A0D11),
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
