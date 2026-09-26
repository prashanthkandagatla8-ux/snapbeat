import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../services/subscription_manager.dart';

class MasterActionDeck extends StatelessWidget {
  final String currentMode; // 'home', 'music', 'photos', 'title', 'render', 'queue'
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

  // New features matching reference layout
  final String renderSpeed; // 'instant' vs 'queued'
  final Function(String speed)? onToggleRenderSpeed;
  final String creditBalanceDisplay;
  final VoidCallback? onTapCredits;
  final String? stageTag;
  final VoidCallback? onBackToHome;

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
    this.renderSpeed = 'instant',
    this.onToggleRenderSpeed,
    this.creditBalanceDisplay = '10 CREDITS',
    this.onTapCredits,
    this.stageTag,
    this.onBackToHome,
  });

  bool get isSubStage => currentMode == 'photos' || currentMode == 'audio_deck' || currentMode == 'title' || currentMode == 'render' || currentMode == 'queue';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF161820),
            Color(0xFF090B0F),
            Color(0xFF030406),
          ],
        ),
        border: const Border(
          top: BorderSide(
            color: Color(0x35FFFFFF),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 24,
            offset: const Offset(0, -6),
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
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. TOP UTILITY TIER
              if (!isSubStage)
                _buildHomeUtilityRow(context)
              else
                _buildSubStageUtilityRow(context),

              const SizedBox(height: 10),

              // 2. MASTER FULL-WIDTH PIANO BLACK CTA BUTTON
              _buildMasterCtaButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // Home Utility Row: [ VAULT ] | [ CREDITS BALANCE ] | [ Queue | Insta Render ]
  Widget _buildHomeUtilityRow(BuildContext context) {
    final bool isInstant = renderSpeed == 'instant';

    return Row(
      children: [
        // Left: Vault Button
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelectMode('queue');
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E232E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x35FFFFFF), width: 0.8),
              boxShadow: const [
                BoxShadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 4),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.video_library_rounded, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                const Text(
                  'VAULT',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
                if (activeJobsCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E5FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const Spacer(),

        // Center: Credit Balance Badge (Auto = 0 Credits Free)
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            if (onTapCredits != null) {
              onTapCredits!();
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF12151D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isManualMode ? const Color(0x35FFFFFF) : const Color(0x18FFFFFF),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isManualMode ? Icons.token_rounded : Icons.bolt_rounded,
                  size: 13,
                  color: isManualMode ? const Color(0xFFFFD54F) : const Color(0xFF00E5FF),
                ),
                const SizedBox(width: 5),
                Text(
                  isManualMode ? creditBalanceDisplay : '0 CREDITS (FREE AUTO)',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isManualMode ? const Color(0xFFECEFF1) : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Right: Render Engine Switcher [ Queue | ⚡ Insta Render ]
        Container(
          height: 36,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1117),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x25FFFFFF), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Queue Option
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (onToggleRenderSpeed != null) onToggleRenderSpeed!('queued');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: !isInstant ? const Color(0xFF262C38) : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'Queue',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: !isInstant ? FontWeight.w800 : FontWeight.w500,
                      color: !isInstant ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
              ),

              // Insta Render Option
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (onToggleRenderSpeed != null) onToggleRenderSpeed!('instant');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: isInstant ? AppColors.iridescentGradient : null,
                    color: isInstant ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: isInstant
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 0.5,
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 12,
                        color: isInstant ? Colors.white : Colors.white54,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Insta Render',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isInstant ? FontWeight.w800 : FontWeight.w500,
                          color: isInstant ? Colors.white : Colors.white54,
                        ),
                      ),
                      if (!SubscriptionManager.instance.isPro) ...[
                        const SizedBox(width: 3),
                        const Icon(Icons.lock_rounded, size: 9, color: Colors.white70),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Sub-Stage Utility Row: [ < STUDIO ] | [ STAGE BADGE ] | [ CREDITS ]
  Widget _buildSubStageUtilityRow(BuildContext context) {
    String currentLabel = 'STUDIO';
    IconData stageIcon = Icons.dashboard_customize_rounded;

    if (currentMode == 'photos') {
      currentLabel = stageTag ?? 'PHOTOS STAGE';
      stageIcon = Icons.photo_library_rounded;
    } else if (currentMode == 'audio_deck' || currentMode == 'music') {
      currentLabel = stageTag ?? 'SOUNDTRACK';
      stageIcon = Icons.music_note_rounded;
    } else if (currentMode == 'title') {
      currentLabel = stageTag ?? 'TITLE INTRO';
      stageIcon = Icons.title_rounded;
    } else if (currentMode == 'queue') {
      currentLabel = 'REELS VAULT';
      stageIcon = Icons.video_collection_rounded;
    }

    return Row(
      children: [
        // Return to Studio Button
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            if (onBackToHome != null) {
              onBackToHome!();
            } else {
              onSelectMode('home');
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E232E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x35FFFFFF), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_back_ios_new_rounded, size: 11, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'STUDIO',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Current Stage Pill
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF12151D),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x25FFFFFF), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(stageIcon, size: 13, color: const Color(0xFF00E5FF)),
              const SizedBox(width: 6),
              Text(
                currentLabel.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Credits Pill (Disabled / Free for Auto)
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            if (onTapCredits != null) onTapCredits!();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF12151D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isManualMode ? const Color(0x35FFFFFF) : const Color(0x18FFFFFF),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isManualMode ? Icons.token_rounded : Icons.bolt_rounded,
                  size: 12,
                  color: isManualMode ? const Color(0xFFFFD54F) : const Color(0xFF00E5FF),
                ),
                const SizedBox(width: 5),
                Text(
                  isManualMode ? creditBalanceDisplay : '0 CREDITS (FREE AUTO)',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isManualMode ? const Color(0xFFECEFF1) : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Master Full-Width Piano Black CTA Button with Iridescent Border
  Widget _buildMasterCtaButton(BuildContext context) {
    return Opacity(
      opacity: 1.0,
      child: InkWell(
        onTap: isActionEnabled ? onActionPressed : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: isActionEnabled ? AppColors.iridescentGradient : null,
            boxShadow: isActionEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF007F).withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                    const BoxShadow(color: Color(0x60000000), offset: Offset(0, 4), blurRadius: 10),
                  ]
                : null,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E212B), Color(0xFF0E1015), Color(0xFF050608)],
              ),
              borderRadius: BorderRadius.circular(12.5),
              border: isActionEnabled
                  ? null
                  : Border.all(
                      color: const Color(0x35FFFFFF),
                      width: 1.0,
                    ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Icon
                Icon(
                  actionIcon,
                  size: 18,
                  color: isActionEnabled ? const Color(0xFF00E5FF) : const Color(0xFF6B7280),
                ),

                // Center Label
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActionEnabled) ...[
                      const Icon(Icons.auto_awesome, size: 14, color: Colors.white70),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      actionButtonText,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: isActionEnabled ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),

                // Right Arrow
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: isActionEnabled ? Colors.white : const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
