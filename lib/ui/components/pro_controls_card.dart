import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';

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
                    'PRO SETTINGS',
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
                        selectedQuality == '1080p' ? '1080p 60fps' : '720p Std',
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
          const Text(
            'STYLE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),

          // Beat Templates in Retro Selector Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: BeatTemplate.allTemplates.length,
              itemBuilder: (context, index) {
                final t = BeatTemplate.allTemplates[index];
                final isSel = t.id == selectedTemplateId;
                return GestureDetector(
                  onTap: () => onSelectTemplate(t.id),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.brassGold : AppColors.panelInset,
                      borderRadius: BorderRadius.circular(20),
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
                    child: Center(
                      child: Text(
                        t.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: isSel ? AppColors.hardwareGunmetal : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Aspect Ratio Rocker Switches
          const Text(
            'ASPECT RATIO',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary),
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
                        Icon(Icons.title_rounded, size: 14, color: AppColors.textSecondary),
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
                  TextField(
                    onChanged: onTitleTextChanged,
                    controller: TextEditingController(text: titleText)..selection = TextSelection.fromPosition(TextPosition(offset: titleText.length)),
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
                  const Text('FONT FAMILY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChip('impact', 'Impact Bold', titleFont == 'impact', onSelectTitleFont),
                        _buildChip('serif', 'Editorial Serif', titleFont == 'serif', onSelectTitleFont),
                        _buildChip('clean', 'Modern Clean', titleFont == 'clean', onSelectTitleFont),
                        _buildChip('typewriter', 'Typewriter', titleFont == 'typewriter', onSelectTitleFont),
                        _buildChip('playful', 'Playful', titleFont == 'playful', onSelectTitleFont),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Title Style Selector
                  const Text('TITLE STYLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChip('classic', 'Retro Gold 👑', titleStyle == 'classic', onSelectTitleStyle),
                        _buildChip('neon', 'Neon Glow ⚡', titleStyle == 'neon', onSelectTitleStyle),
                        _buildChip('3d_retro', '3D Sunset 🌇', titleStyle == '3d_retro', onSelectTitleStyle),
                        _buildChip('cinematic', 'Cinematic 🎬', titleStyle == 'cinematic', onSelectTitleStyle),
                        _buildChip('badge', 'Badge Pill 🏷️', titleStyle == 'badge', onSelectTitleStyle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Frame Style Selector
                  const Text('FRAME BORDER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChip('none', 'No Frame', titleFrame == 'none', onSelectTitleFrame),
                        _buildChip('viewfinder', 'Viewfinder 🎯', titleFrame == 'viewfinder', onSelectTitleFrame),
                        _buildChip('film_bars', 'Film Bars 🎞️', titleFrame == 'film_bars', onSelectTitleFrame),
                        _buildChip('box', 'Clean Box 🔲', titleFrame == 'box', onSelectTitleFrame),
                        _buildChip('double_line', 'Double Line ═', titleFrame == 'double_line', onSelectTitleFrame),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 4. Background & Duration Row
                  Row(
                    children: [
                      // Background Type
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BACKGROUND', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildSmallRocker('black', 'Black', titleBg == 'black', onSelectTitleBg),
                                const SizedBox(width: 4),
                                _buildSmallRocker('video', 'Overlay', titleBg == 'video', onSelectTitleBg),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Duration
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DURATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildSmallRocker('1s', '1s', titleDuration == 1, (_) => onTitleDurationChanged(1)),
                                const SizedBox(width: 4),
                                _buildSmallRocker('2s', '2s', titleDuration == 2, (_) => onTitleDurationChanged(2)),
                                const SizedBox(width: 4),
                                _buildSmallRocker('3s', '3s', titleDuration == 3, (_) => onTitleDurationChanged(3)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

  Widget _buildTitlePreview() {
    TextStyle baseStyle;
    switch (titleFont) {
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
      default:
        baseStyle = GoogleFonts.oswald(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0);
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

    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: titleBg == "video" ? const Color(0xFF2C2825) : Colors.black,
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
          Container(
            padding: badgeDecoration != null ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3) : null,
            decoration: badgeDecoration,
            child: Text(
              titleStyle == "cinematic" ? displayText.toUpperCase() : displayText,
              textAlign: TextAlign.center,
              style: baseStyle.copyWith(
                color: textColor,
                shadows: shadows,
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