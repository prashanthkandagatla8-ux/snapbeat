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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("👑", style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    "Studio Master Controls",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13, color: AppColors.goldBright),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.amberBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
                ),
                child: const Text(
                  "14 TEMPLATES",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.goldBright),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Templates Horizontal Reel (All 14)
          Text(
            "Motion Beat Template",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: BeatTemplate.allTemplates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final t = BeatTemplate.allTemplates[index];
                final isSelected = selectedTemplateId == t.id;
                return GestureDetector(
                  onTap: () => onSelectTemplate(t.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(colors: [AppColors.goldPrimary, AppColors.goldBright])
                          : null,
                      color: isSelected ? null : AppColors.canvasDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.goldBright : AppColors.borderSubtle,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(t.emoji, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        Text(
                          t.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.black : AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 2. Aspect Ratio & Quality Grid
          Row(
            children: [
              // Aspect Ratios
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Aspect Ratio", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildRatioBtn("9:16", "9:16"),
                        const SizedBox(width: 4),
                        _buildRatioBtn("1:1", "1:1"),
                        const SizedBox(width: 4),
                        _buildRatioBtn("16:9", "16:9"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Video Quality
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quality", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildQualityBtn("720p", "720p"),
                        const SizedBox(width: 4),
                        _buildQualityBtn("1080p 60fps", "1080p"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Title Card Intro Suite
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.canvasDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text("🎬", style: TextStyle(fontSize: 12)),
                        SizedBox(width: 6),
                        Text("Reel Title Intro", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                      ],
                    ),
                    Switch(
                      value: enableTitle,
                      activeColor: AppColors.goldPrimary,
                      activeTrackColor: AppColors.goldPrimary.withOpacity(0.3),
                      onChanged: onToggleTitle,
                    ),
                  ],
                ),
                if (enableTitle) ...[
                  const SizedBox(height: 6),
                  TextField(
                    onChanged: onTitleTextChanged,
                    decoration: InputDecoration(
                      hintText: "Enter title text (e.g. Summer Moments)",
                      hintStyle: const TextStyle(fontSize: 11, color: AppColors.textDim),
                      filled: true,
                      fillColor: AppColors.cardSurface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(fontSize: 11, color: AppColors.textWhite),
                  ),
                  const SizedBox(height: 8),
                  // Background Mode Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBgOption("Black", "black"),
                      _buildBgOption("Gold", "gold"),
                      _buildBgOption("Over Video", "video"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Live Preview Box
                  Container(
                    height: 38,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: titleBg == "gold"
                          ? AppColors.goldDark
                          : titleBg == "video"
                              ? Colors.purple.withOpacity(0.4)
                              : Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.goldPrimary.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        titleText.isEmpty ? "✦ REEL TITLE PREVIEW ✦" : "✦ ${titleText.toUpperCase()} ✦",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.goldBright,
                          letterSpacing: 1.2,
                        ),
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

  Widget _buildRatioBtn(String label, String value) {
    final isSelected = selectedAspectRatio == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelectAspectRatio(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.goldPrimary : AppColors.canvasDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.goldBright : AppColors.borderSubtle),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : AppColors.textWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQualityBtn(String label, String value) {
    final isSelected = selectedQuality == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelectQuality(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.goldPrimary : AppColors.canvasDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.goldBright : AppColors.borderSubtle),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : AppColors.textWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBgOption(String label, String value) {
    final isSelected = titleBg == value;
    return GestureDetector(
      onTap: () => onSelectTitleBg(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldPrimary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.goldPrimary : AppColors.borderSubtle),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.goldBright : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
