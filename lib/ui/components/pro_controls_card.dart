import 'dart:io';
import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../services/subscription_manager.dart';
import 'retro_subscription_dialog.dart';
import 'snapbeat_pink_dot.dart';
import 'retro_metal_panel.dart';

class ProControlsCard extends StatelessWidget {
  final String selectedTemplateId;
  final Function(String id) onSelectTemplate;
  final String selectedAspectRatio;
  final Function(String ratio) onSelectAspectRatio;
  final String selectedQuality;
  final Function(String quality) onSelectQuality;
  
  // Title Intro (kept for backward compatibility)
  final bool? enableTitle;
  final Function(bool enabled)? onToggleTitle;
  final String? titleText;
  final TextEditingController? titleController;
  final Function(String text)? onTitleTextChanged;
  final String? titleBg;
  final Function(String bg)? onSelectTitleBg;
  final int? titleDuration;
  final Function(int dur)? onTitleDurationChanged;
  final String? titleFont;
  final Function(String font)? onSelectTitleFont;
  final String? titleFontSize;
  final Function(String size)? onSelectTitleFontSize;
  final String? titleStyle;
  final Function(String style)? onSelectTitleStyle;
  final String? titleFrame;
  final Function(String frame)? onSelectTitleFrame;
  final String? titleAudio;
  final Function(String audio)? onSelectTitleAudio;
  final File? representativePhoto;
  final bool? isPro;

  // Cult Effects (user-facing toggles only)
  final bool enableBurst;
  final Function(bool) onToggleBurst;
  final bool enableTeaser;
  final Function(bool) onToggleTeaser;
  final bool enableDropIt;
  final Function(bool) onToggleDropIt;
  final bool isAutoMode;

  const ProControlsCard({
    super.key,
    required this.selectedTemplateId,
    required this.onSelectTemplate,
    required this.selectedAspectRatio,
    required this.onSelectAspectRatio,
    required this.selectedQuality,
    required this.onSelectQuality,
    this.enableTitle,
    this.onToggleTitle,
    this.titleText,
    this.titleController,
    this.onTitleTextChanged,
    this.titleBg,
    this.onSelectTitleBg,
    this.titleDuration,
    this.onTitleDurationChanged,
    this.titleFont,
    this.onSelectTitleFont,
    this.titleFontSize = "large",
    this.onSelectTitleFontSize,
    this.titleStyle,
    this.onSelectTitleStyle,
    this.titleFrame,
    this.onSelectTitleFrame,
    this.titleAudio,
    this.onSelectTitleAudio,
    this.representativePhoto,
    this.isPro,
    required this.enableBurst,
    required this.onToggleBurst,
    required this.enableTeaser,
    required this.onToggleTeaser,
    required this.enableDropIt,
    required this.onToggleDropIt,
    this.isAutoMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return RetroMetalPanel(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SnapBeatPinkDot(size: 13, withGlow: true),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07080A),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0x30FFFFFF)),
                    ),
                    child: Text(
                      isAutoMode ? 'AUTO' : 'MANUAL',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAutoMode ? 'REEL SETTINGS & TITLE' : 'MANUAL MODE',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Quality Indicator Lamp
              GestureDetector(
                onTap: () {
                  final userIsPro = isPro ?? SubscriptionManager.instance.isPro;
                  if (!userIsPro) {
                    RetroSubscriptionDialog.show(context);
                    return;
                  }
                  onSelectQuality(selectedQuality == '1080p' ? '720p' : '1080p');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.panelInset,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.chassisBevelDark, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isPro ?? false)
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
                          boxShadow: (isPro ?? false)
                              ? const [BoxShadow(color: Color(0x30FFFFFF), blurRadius: 4, spreadRadius: 1)]
                              : [],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (isPro ?? false)
                            ? (selectedQuality == '1080p' ? '1080p Master' : '720p HD')
                            : '360p Standard (Free)',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDarkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!isAutoMode) ...[
            const SizedBox(height: 14),
            _buildTemplateSelector(context),
          ],
          const SizedBox(height: 14),

          // Render Quality Selector (3-Tier Hardware Rockers)
          Row(
            children: const [
              SnapBeatPinkDot(size: 10),
              SizedBox(width: 6),
              Text(
                'RENDER QUALITY',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQualityRocker(
                context: context,
                label: '360p',
                sublabel: 'Fast Preview',
                value: '360p',
                isProRequired: false,
              ),
              const SizedBox(width: 8),
              _buildQualityRocker(
                context: context,
                label: '720p HD',
                sublabel: 'HD Standard',
                value: '720p',
                isProRequired: false,
              ),
              const SizedBox(width: 8),
              _buildQualityRocker(
                context: context,
                label: '1080p Master',
                sublabel: 'Master 1080p',
                value: '1080p',
                isProRequired: false,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Aspect Ratio Rocker Switches
          Row(
            children: const [
              SnapBeatPinkDot(size: 10),
              SizedBox(width: 6),
              Text(
                'ASPECT RATIO',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildAspectRocker('9:16', 'Story', '9:16'),
              const SizedBox(width: 8),
              _buildAspectRocker('1:1', 'Square', '1:1'),
              const SizedBox(width: 8),
              _buildAspectRocker('16:9', 'Wide', '16:9'),
            ],
          ),
          const SizedBox(height: 14),


          if (!isAutoMode) ...[
            const SizedBox(height: 14),
            _BeatMotionEffectsSection(
              enableBurst: enableBurst,
              onToggleBurst: onToggleBurst,
              enableTeaser: enableTeaser,
              onToggleTeaser: onToggleTeaser,
              enableDropIt: enableDropIt,
              onToggleDropIt: onToggleDropIt,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAspectRocker(String ratio, String label, String value) {
    final isSelected = selectedAspectRatio == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelectAspectRatio(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF07080A) : const Color(0xFF030405),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? const Color(0x30FFFFFF) : const Color(0x10FFFFFF),
              width: 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.12),
                      blurRadius: 1,
                      offset: const Offset(0, -1),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                ratio,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xB3FFFFFF) : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateSelector(BuildContext context) {
    final activeTemplate = BeatTemplate.allTemplates.firstWhere(
      (t) => t.id == selectedTemplateId,
      orElse: () => BeatTemplate.allTemplates.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1218),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x35FFFFFF), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF161A22),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x30FFFFFF), width: 0.8),
            ),
            child: Center(
              child: Icon(activeTemplate.icon, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeTemplate.name.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  activeTemplate.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _showTemplateSelectorModal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.iridescentGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CHANGE STYLE',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTemplateSelectorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF0A0C10),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Color(0x30FFFFFF), width: 1),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SELECT MOTION STYLE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: BeatTemplate.allTemplates.length,
                  itemBuilder: (context, index) {
                    final t = BeatTemplate.allTemplates[index];
                    final isSelected = t.id == selectedTemplateId;
                    return ListTile(
                      leading: Icon(t.icon, color: isSelected ? Colors.white : Colors.white54, size: 24),
                      title: Text(
                        t.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      subtitle: Text(
                        t.subtitle,
                        style: const TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20)
                          : null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      tileColor: isSelected ? const Color(0xFF141720) : null,
                      onTap: () {
                        onSelectTemplate(t.id);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// The quality the render will actually use.
  ///
  /// `selectedQuality` defaults to '1080p' for everyone, but `home_screen`
  /// overrides it to '360p' for non-subscribers when it builds the request. The
  /// rocker used to highlight `selectedQuality` directly, so a free user saw
  /// "1080p Master" lit up while the app rendered 360p.
  String get _effectiveQuality => isPro == true ? selectedQuality : '360p';

  Widget _buildQualityRocker({
    required BuildContext context,
    required String label,
    required String sublabel,
    required String value,
    required bool isProRequired,
  }) {
    final isSelected = _effectiveQuality == value;
    // Upscales above the free 360p standard require a subscription. This used to
    // be enforced in onTap but never shown, so locked tiers were indistinguishable
    // from available ones.
    final isLocked = isPro != true && value != '360p';

    final Color labelColor = isLocked
        ? const Color(0xFF6B7280)
        : (isSelected ? Colors.white : const Color(0xFFCBD5E1));
    final Color sublabelColor = isLocked
        ? const Color(0xFF4B5563)
        : (isSelected ? const Color(0xB3FFFFFF) : const Color(0xFF94A3B8));

    return Expanded(
      child: Semantics(
        button: true,
        enabled: true,
        selected: isSelected,
        label: isLocked
            ? '$label, $sublabel, requires Pro subscription'
            : '$label, $sublabel',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (isLocked) {
              RetroSubscriptionDialog.show(
                context,
                reason: '$label export is part of SnapBeat Pro. '
                    'Free renders are 360p.',
              );
              return;
            }
            onSelectQuality(value);
          },
          child: Container(
            padding: isSelected ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.5),
              gradient: isSelected ? AppColors.iridescentGradient : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFB026FF).withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF07080A)
                    : const Color(0xFF030405),
                borderRadius: BorderRadius.circular(6),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isLocked
                            ? const Color(0x08FFFFFF)
                            : const Color(0x10FFFFFF),
                        width: 1.0,
                      ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLocked) ...[
                        Icon(Icons.lock_rounded, size: 9, color: labelColor),
                        const SizedBox(width: 3),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: labelColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLocked ? 'PRO' : sublabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                      color: sublabelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Beat Motion Effects Section (Open & Default Enabled) ───────────────────────────

class _BeatMotionEffectsSection extends StatelessWidget {
  final bool enableBurst;
  final Function(bool) onToggleBurst;
  final bool enableTeaser;
  final Function(bool) onToggleTeaser;
  final bool enableDropIt;
  final Function(bool) onToggleDropIt;

  const _BeatMotionEffectsSection({
    required this.enableBurst,
    required this.onToggleBurst,
    required this.enableTeaser,
    required this.onToggleTeaser,
    required this.enableDropIt,
    required this.onToggleDropIt,
  });

  @override
  Widget build(BuildContext context) {
    final activeCount = [enableBurst, enableTeaser, enableDropIt].where((v) => v).length;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelInset,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.chassisBevelDark, width: 1),
      ),
      // ExpansionTile paints its ink splashes on the nearest Material ancestor.
      // Without this, that ancestor sits behind the Container background above,
      // and the framework asserts the splashes will be invisible.
      child: Material(
        type: MaterialType.transparency,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            title: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.iridescentGradient,
                    boxShadow: [
                      BoxShadow(color: Color(0x4000E5FF), blurRadius: 5, spreadRadius: 1),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'BEAT MOTION EFFECTS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF141720),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x30FFFFFF)),
              ),
              child: Text(
                '$activeCount ACTIVE',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            children: [
              Container(
                height: 1,
                color: AppColors.chassisBevelDark,
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildToggleRow(
                      icon: Icons.flash_on_rounded,
                      label: 'Burst Effects',
                      hint: 'Rapid slice reveals on fast beats',
                      value: enableBurst,
                      onChanged: onToggleBurst,
                    ),
                    _buildToggleRow(
                      icon: Icons.center_focus_strong_rounded,
                      label: 'Beat Teaser',
                      hint: 'Face and crop punch zoom on quiet beats',
                      value: enableTeaser,
                      onChanged: onToggleTeaser,
                    ),
                    _buildToggleRow(
                      icon: Icons.vertical_align_bottom_rounded,
                      label: 'Drop Impact',
                      hint: 'Atmospheric gap before bass drops',
                      value: enableDropIt,
                      onChanged: onToggleDropIt,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required String hint,
    required bool value,
    required Function(bool) onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: value
                    ? const Color(0xFF141720)
                    : AppColors.panelCreamDark,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? const Color(0x30FFFFFF) : AppColors.chassisBevelDark,
                  width: 1,
                ),
              ),
              child: Icon(icon,
                  size: 15,
                  color: value ? Colors.white : AppColors.textMuted),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: value ? AppColors.textEngraved : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    hint,
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF252936),
              inactiveThumbColor: const Color(0xFF64748B),
              inactiveTrackColor: const Color(0xFF1E212B),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        if (!isLast)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.chassisBevelDark.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

