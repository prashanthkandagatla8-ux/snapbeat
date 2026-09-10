import 'package:flutter/material.dart';
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
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(3, 4),
            blurRadius: 8,
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
                      gradient: AppColors.brassKnobGradient,
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
                    'STUDIO MASTER CONTROLS',
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
                    color: selectedQuality == '1080p' ? const Color(0xFF1E1A16) : AppColors.panelInset,
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
                          color: selectedQuality == '1080p' ? AppColors.amberJewel : Colors.grey,
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
            'TRANSITION ENGINE PRESET',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),

          // 14 Beat Templates in Retro Selector Chips
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
                      color: isSel ? const Color(0xFF1E1A16) : AppColors.panelCreamDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSel ? AppColors.brassGold : AppColors.chassisBevelDark,
                        width: isSel ? 1.5 : 1.0,
                      ),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: AppColors.brassGold.withValues(alpha: 0.3),
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
                          color: isSel ? AppColors.brassHighlight : AppColors.textSecondary,
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
            'CANVAS FRAME GEOMETRY',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildAspectRocker('9:16', 'Reel / Story', '9:16'),
              const SizedBox(width: 8),
              _buildAspectRocker('1:1', 'Square Post', '1:1'),
              const SizedBox(width: 8),
              _buildAspectRocker('16:9', 'Cinema Wide', '16:9'),
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
                          'OPENING TITLE CARD',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Switch(
                      value: enableTitle,
                      activeThumbColor: AppColors.amberJewel,
                      onChanged: onToggleTitle,
                    ),
                  ],
                ),
                if (enableTitle) ...[
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: onTitleTextChanged,
                    decoration: InputDecoration(
                      hintText: 'e.g. SUMMER RECAP 2026',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.chassisBevelDark),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.chassisBevelDark),
                      ),
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

  Widget _buildAspectRocker(String ratio, String label, String value) {
    final isSelected = selectedAspectRatio == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelectAspectRatio(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E1A16) : AppColors.panelCreamDark,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.brassGold : AppColors.chassisBevelDark,
              width: isSelected ? 1.5 : 1.0,
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
                  color: isSelected ? AppColors.brassHighlight : AppColors.textEngraved,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.textFoilGold : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}