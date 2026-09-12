import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import 'snapbeat_pink_dot.dart';

class ProControlsCard extends StatelessWidget {
  final String selectedTemplateId;
  final Function(String id) onSelectTemplate;
  final String selectedAspectRatio;
  final Function(String ratio) onSelectAspectRatio;
  final String selectedQuality;
  final Function(String quality) onSelectQuality;
  
  // Title Intro
  final bool enableTitle;
  final Function(bool enabled) onToggleTitle;
  final String titleText;
  final TextEditingController? titleController;
  final Function(String text) onTitleTextChanged;
  final String titleBg;
  final Function(String bg) onSelectTitleBg;
  final int titleDuration;
  final Function(int dur) onTitleDurationChanged;
  final String titleFont;
  final Function(String font) onSelectTitleFont;
  final String titleStyle;
  final Function(String style) onSelectTitleStyle;
  final String titleFrame;
  final Function(String frame) onSelectTitleFrame;
  final String titleAudio;
  final Function(String audio) onSelectTitleAudio;

  const ProControlsCard({
    super.key,
    required this.selectedTemplateId,
    required this.onSelectTemplate,
    required this.selectedAspectRatio,
    required this.onSelectAspectRatio,
    required this.selectedQuality,
    required this.onSelectQuality,
    required this.enableTitle,
    required this.onToggleTitle,
    required this.titleText,
    this.titleController,
    required this.onTitleTextChanged,
    required this.titleBg,
    required this.onSelectTitleBg,
    required this.titleDuration,
    required this.onTitleDurationChanged,
    required this.titleFont,
    required this.onSelectTitleFont,
    required this.titleStyle,
    required this.onSelectTitleStyle,
    required this.titleFrame,
    required this.onSelectTitleFrame,
    required this.titleAudio,
    required this.onSelectTitleAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.chassisBevelLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(3, 4),
            blurRadius: 10,
          ),
        ],
      ),
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
                      color: AppColors.brassGold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.hardwareGunmetal,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'PRO MODE',
                    style: TextStyle(
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
                onTap: () => onSelectQuality(selectedQuality == '1080p' ? '720p' : '1080p'),
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
                          color: selectedQuality == '1080p' ? AppColors.amberJewel : Colors.grey.withValues(alpha: 0.3),
                          boxShadow: selectedQuality == '1080p' 
                              ? [const BoxShadow(color: AppColors.amberGlow, blurRadius: 4, spreadRadius: 1)]
                              : [],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedQuality == '1080p' ? '1080p 60fps' : '720p Standard',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: selectedQuality == '1080p' ? AppColors.amberJewel : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Templates Selector Label
          Row(
            children: const [
              SnapBeatPinkDot(size: 10),
              SizedBox(width: 6),
              Text(
                'STYLE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Beat Templates in Wrap (all 15 styles directly visible, no hidden scrolling)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: BeatTemplate.allTemplates.map((t) {
              final isSel = t.id == selectedTemplateId;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelectTemplate(t.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.brassGold : AppColors.panelInset,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSel ? AppColors.brassGold : AppColors.chassisBevelLight,
                      width: 1.0,
                    ),
                    boxShadow: isSel
                        ? [
                            const BoxShadow(
                              color: AppColors.amberGlow,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.emoji, style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        t.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isSel ? AppColors.hardwareGunmetal : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
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

          // Title Intro Card Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.panelInset,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.chassisBevelDark, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        SnapBeatPinkDot(size: 11, withGlow: true),
                        SizedBox(width: 6),
                        Text(
                          'INTRO TITLE CARD',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Switch(
                      value: enableTitle,
                      activeThumbColor: AppColors.hardwareGunmetal,
                      activeTrackColor: AppColors.brassGold,
                      inactiveThumbColor: AppColors.textSecondary,
                      inactiveTrackColor: AppColors.panelCreamDark,
                      onChanged: onToggleTitle,
                    ),
                  ],
                ),
                if (enableTitle) ...[
                  const SizedBox(height: 10),
                  // Title Text Field
                  TextFormField(
                    controller: titleController,
                    initialValue: titleController == null ? titleText : null,
                    onChanged: onTitleTextChanged,
                    style: const TextStyle(color: AppColors.textEngraved, fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'e.g. Summer Memories 2026',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.panelCreamDark,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.chassisBevelDark),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.chassisBevelDark),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.brassGold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Live Preview Box
                  _buildTitlePreview(),
                  const SizedBox(height: 12),

                  // 1. Font Family Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FONT FAMILY',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary),
                      ),
                      Text(
                        titleFont.toUpperCase().replaceAll('_', ' '),
                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.brassGold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildChip('great_vibes', 'Great Vibes', titleFont == 'great_vibes', onSelectTitleFont),
                      _buildChip('allura', 'Allura', titleFont == 'allura', onSelectTitleFont),
                      _buildChip('alex_brush', 'Alex Brush', titleFont == 'alex_brush', onSelectTitleFont),
                      _buildChip('bodoni_moda', 'Bodoni Moda', titleFont == 'bodoni_moda', onSelectTitleFont),
                      _buildChip('cormorant_garamond', 'Cormorant', titleFont == 'cormorant_garamond', onSelectTitleFont),
                      _buildChip('cinzel', 'Cinzel', titleFont == 'cinzel', onSelectTitleFont),
                      _buildChip('impact', 'Impact Bold', titleFont == 'impact', onSelectTitleFont),
                      _buildChip('clean', 'Modern Clean', titleFont == 'clean', onSelectTitleFont),
                      _buildChip('serif', 'Editorial Serif', titleFont == 'serif', onSelectTitleFont),
                      _buildChip('typewriter', 'Typewriter', titleFont == 'typewriter', onSelectTitleFont),
                      _buildChip('playful', 'Playful', titleFont == 'playful', onSelectTitleFont),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Title Style Selector
                  const Text('TITLE STYLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildChip('classic', 'Retro Gold 👑', titleStyle == 'classic', onSelectTitleStyle),
                      _buildChip('neon', 'Neon Glow ⚡', titleStyle == 'neon', onSelectTitleStyle),
                      _buildChip('3d_retro', '3D Sunset 🌇', titleStyle == '3d_retro', onSelectTitleStyle),
                      _buildChip('cinematic', 'Cinematic 🎬', titleStyle == 'cinematic', onSelectTitleStyle),
                      _buildChip('badge', 'Badge Pill 🏷️', titleStyle == 'badge', onSelectTitleStyle),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. Frame Style Selector
                  const Text('FRAME BORDER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildChip('none', 'No Frame', titleFrame == 'none', onSelectTitleFrame),
                      _buildChip('viewfinder', 'Viewfinder 🎯', titleFrame == 'viewfinder', onSelectTitleFrame),
                      _buildChip('film_bars', 'Film Bars 🎞️', titleFrame == 'film_bars', onSelectTitleFrame),
                      _buildChip('box', 'Clean Box 🔲', titleFrame == 'box', onSelectTitleFrame),
                      _buildChip('double_line', 'Double Line ═', titleFrame == 'double_line', onSelectTitleFrame),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Title Duration Slider
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.panelCreamDark.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.chassisBevelDark.withValues(alpha: 0.7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.timer_outlined, size: 13, color: AppColors.textSecondary),
                                SizedBox(width: 6),
                                Text(
                                  'TITLE DURATION',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.hardwareGunmetal,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.borderBrass),
                              ),
                              child: Text(
                                '$titleDuration SECONDS',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: AppColors.amberJewel,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4.0,
                            activeTrackColor: AppColors.brassGold,
                            inactiveTrackColor: AppColors.chassisBevelDark,
                            thumbColor: AppColors.brassGold,
                            overlayColor: AppColors.amberGlow.withValues(alpha: 0.25),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                            activeTickMarkColor: AppColors.hardwareGunmetal,
                            inactiveTickMarkColor: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          child: Slider(
                            value: titleDuration.toDouble().clamp(1.0, 6.0),
                            min: 1.0,
                            max: 6.0,
                            divisions: 5,
                            onChanged: (val) => onTitleDurationChanged(val.round()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (i) {
                              final sec = i + 1;
                              final isCurrent = sec == titleDuration;
                              return Text(
                                '${sec}s',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                                  color: isCurrent ? AppColors.amberJewel : AppColors.textMuted,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Audio Timing Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.panelCreamDark.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.chassisBevelDark.withValues(alpha: 0.7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.music_note_rounded, size: 13, color: AppColors.textSecondary),
                            SizedBox(width: 6),
                            Text(
                              'AUDIO TIMING',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildSmallRocker(
                              'before_audio',
                              'Before Music ⏳',
                              titleAudio == 'before_audio',
                              onSelectTitleAudio,
                            ),
                            const SizedBox(width: 8),
                            _buildSmallRocker(
                              'with_audio',
                              'With Music 🎵',
                              titleAudio == 'with_audio',
                              onSelectTitleAudio,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          titleAudio == 'with_audio'
                              ? '• Music starts from 0:00 immediately as the title card appears.'
                              : '• Title plays in cinematic silence for ${titleDuration}s; music starts when photos begin.',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMuted.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 6. Background Selector & Curated Palette
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.panelCreamDark.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.chassisBevelDark.withValues(alpha: 0.7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.palette_outlined, size: 13, color: AppColors.textSecondary),
                                SizedBox(width: 6),
                                Text(
                                  'BACKGROUND',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            Text(
                              titleBg == 'video' ? 'OVER VIDEO' : (titleBg == 'black' ? 'BLACK' : titleBg.toUpperCase()),
                              style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.brassGold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildSmallRocker('black', 'Black', titleBg == 'black', onSelectTitleBg),
                            const SizedBox(width: 6),
                            _buildSmallRocker('video', 'Video Overlay', titleBg == 'video', onSelectTitleBg),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'COLOR TONES',
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildColorSwatch('#000000', 'Black', const Color(0xFF000000)),
                              _buildColorSwatch('#18181B', 'Charcoal', const Color(0xFF18181B)),
                              _buildColorSwatch('#1E1B4B', 'Indigo', const Color(0xFF1E1B4B)),
                              _buildColorSwatch('#3B0764', 'Velvet', const Color(0xFF3B0764)),
                              _buildColorSwatch('#2C1810', 'Sepia', const Color(0xFF2C1810)),
                              _buildColorSwatch('#450A0A', 'Crimson', const Color(0xFF450A0A)),
                              _buildColorSwatch('#064E3B', 'Emerald', const Color(0xFF064E3B)),
                              _buildColorSwatch('#0F172A', 'Navy', const Color(0xFF0F172A)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String id, String label, bool isSelected, Function(String) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(id),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brassGold : AppColors.panelCreamDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.borderBrass : AppColors.chassisBevelLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? AppColors.hardwareGunmetal : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallRocker(String id, String label, bool isSelected, Function(String) onSelect) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brassGold : AppColors.panelCreamDark,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? AppColors.borderBrass : AppColors.chassisBevelLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isSelected ? AppColors.hardwareGunmetal : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSwatch(String hex, String label, Color color) {
    final isSelected = titleBg.toLowerCase() == hex.toLowerCase();
    return GestureDetector(
      onTap: () => onSelectTitleBg(hex),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brassGold.withValues(alpha: 0.2) : AppColors.panelInset,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.brassGold : AppColors.chassisBevelLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 1),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? AppColors.brassGold : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitlePreview() {
    TextStyle baseStyle;
    switch (titleFont) {
      case 'great_vibes':
        baseStyle = GoogleFonts.greatVibes(fontSize: 22, fontWeight: FontWeight.normal);
        break;
      case 'allura':
        baseStyle = GoogleFonts.allura(fontSize: 22, fontWeight: FontWeight.normal);
        break;
      case 'alex_brush':
        baseStyle = GoogleFonts.alexBrush(fontSize: 22, fontWeight: FontWeight.normal);
        break;
      case 'bodoni_moda':
        baseStyle = GoogleFonts.bodoniModa(fontSize: 16, fontWeight: FontWeight.bold);
        break;
      case 'cormorant_garamond':
        baseStyle = GoogleFonts.cormorantGaramond(fontSize: 17, fontWeight: FontWeight.w700);
        break;
      case 'cinzel':
        baseStyle = GoogleFonts.cinzel(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.2);
        break;
      case 'serif':
        baseStyle = GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.bold);
        break;
      case 'clean':
        baseStyle = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700);
        break;
      case 'typewriter':
        baseStyle = GoogleFonts.courierPrime(fontSize: 13, fontWeight: FontWeight.bold);
        break;
      case 'playful':
        baseStyle = GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w600);
        break;
      case 'impact':
        baseStyle = GoogleFonts.oswald(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0);
        break;
      default:
        baseStyle = GoogleFonts.greatVibes(fontSize: 22, fontWeight: FontWeight.normal);
    }

    Color textColor = const Color(0xFFFFE14D);
    List<Shadow> shadows = [];
    BoxDecoration? badgeDecoration;

    switch (titleStyle) {
      case 'neon':
        textColor = Colors.white;
        shadows = const [
          Shadow(color: Color(0xFF00F0FF), blurRadius: 10),
          Shadow(color: Color(0xFF00F0FF), blurRadius: 20),
        ];
        break;
      case 'cinematic':
        textColor = const Color(0xFFFAF6EE);
        shadows = const [
          Shadow(color: Colors.black87, offset: Offset(1, 1), blurRadius: 3),
        ];
        break;
      case '3d_retro':
        textColor = const Color(0xFFFFEB3C);
        shadows = const [
          Shadow(color: Color(0xFF8B1A4A), offset: Offset(2, 2), blurRadius: 0),
          Shadow(color: Color(0xFF5A1030), offset: Offset(3, 3), blurRadius: 0),
        ];
        break;
      case 'badge':
        textColor = const Color(0xFF141414);
        badgeDecoration = BoxDecoration(
          color: const Color(0xFFFFE14D),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black, width: 1.5),
        );
        break;
      case 'classic':
      default:
        textColor = const Color(0xFFFFE14D);
        shadows = const [
          Shadow(color: Colors.black, offset: Offset(1.5, 1.5), blurRadius: 1),
        ];
    }

    final displayText = titleText.trim().isEmpty ? "SNAPBEAT" : titleText.trim();

    Color cardBgColor = Colors.black;
    if (titleBg.startsWith('#') && titleBg.length == 7) {
      final hex = titleBg.substring(1);
      final val = int.tryParse(hex, radix: 16);
      if (val != null) {
        cardBgColor = Color(0xFF000000 | val);
      }
    } else if (titleBg == "video") {
      cardBgColor = const Color(0xFF2C2825);
    }

    return Container(
      height: 84,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.chassisBevelDark),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (titleBg == "video")
            Positioned.fill(
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/images/brushed_metal_background.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          // Top Badges
          Positioned(
            top: 5,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderBrass.withValues(alpha: 0.4), width: 0.8),
              ),
              child: Text(
                titleFont.toUpperCase().replaceAll('_', ' '),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brassGold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderBrass.withValues(alpha: 0.4), width: 0.8),
              ),
              child: Text(
                '${titleDuration}s • ${titleAudio == "with_audio" ? "WITH MUSIC" : "SILENT INTRO"}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.amberJewel,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          // Frame borders
          if (titleFrame == "box")
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFE14D), width: 1.5),
                ),
              ),
            ),
          if (titleFrame == "double_line")
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFE14D), width: 1.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFE14D), width: 1.0),
                  ),
                ),
              ),
            ),
          if (titleFrame == "viewfinder")
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("┌", style: TextStyle(color: Color(0xFFFFE14D), fontSize: 16)),
                        Text("└", style: TextStyle(color: Color(0xFFFFE14D), fontSize: 16)),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("┐", style: TextStyle(color: Color(0xFFFFE14D), fontSize: 16)),
                        Text("┘", style: TextStyle(color: Color(0xFFFFE14D), fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (titleFrame == "film_bars")
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 2, color: const Color(0xFFFFE14D), margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6)),
                Container(height: 2, color: const Color(0xFFFFE14D), margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6)),
              ],
            ),
          // Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44),
            child: Container(
              padding: badgeDecoration != null ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3) : null,
              decoration: badgeDecoration,
              child: Text(
                titleStyle == "cinematic" ? displayText.toUpperCase() : displayText,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: baseStyle.copyWith(
                  color: textColor,
                  shadows: shadows,
                ),
              ),
            ),
          ),
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
            color: isSelected ? AppColors.brassGold : AppColors.panelInset,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.brassGold : AppColors.chassisBevelLight,
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                ratio,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? AppColors.hardwareGunmetal : AppColors.textEngraved,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.hardwareGunmetal.withValues(alpha: 0.7) : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}