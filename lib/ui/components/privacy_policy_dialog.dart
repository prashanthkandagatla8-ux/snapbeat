import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => const PrivacyPolicyDialog(),
    );
  }

  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        decoration: BoxDecoration(
          color: AppColors.panelCream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderBrass, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: const Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Industrial Beveled Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.canvasChassis,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                border: Border(
                  bottom: BorderSide(color: AppColors.chassisBevelLight, width: 1.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.panelInset,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderBrass, width: 1),
                    ),
                    child: const Text('🛡️', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy & Data Safety',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppColors.textEngraved,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Google Play Policy Compliant',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: AppColors.textFoilGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    splashRadius: 18,
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: Scrollbar(
                thumbVisibility: true,
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Note
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.panelInset,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.chassisBevelLight, width: 1),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.brassGold),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'SnapBeat is engineered with a strict privacy-by-design architecture.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      _buildSectionItem(
                        icon: '⚡',
                        title: 'Ephemeral Media Processing',
                        description:
                            'User-selected photos and audio tracks are transmitted over encrypted HTTPS/TLS exclusively to the cloud rendering engine to detect musical beats and assemble your video reel.',
                      ),

                      _buildSectionItem(
                        icon: '🗑️',
                        title: 'Instant File Deletion',
                        description:
                            'Input files are processed in volatile temporary storage and purged permanently immediately upon render completion. No user images or songs are ever archived on servers.',
                      ),

                      _buildSectionItem(
                        icon: '🚫',
                        title: 'Zero Tracking & No Advertisements',
                        description:
                            'SnapBeat contains zero ad networks, zero third-party analytics SDKs, and zero device fingerprinting. We do not track your activity across apps.',
                      ),

                      _buildSectionItem(
                        icon: '🛡️',
                        title: 'No AI Training & Zero Data Sales',
                        description:
                            'Your personal media is never sold, rented, or shared with third parties. Your photos and music are strictly prohibited from being used to train AI or machine learning models.',
                      ),

                      _buildSectionItem(
                        icon: '📱',
                        title: 'Minimal Scoped Permissions',
                        description:
                            'System photo picker and audio file access are requested solely when you select media for your reel. We cannot access your full library or unselected private files.',
                      ),

                      _buildSectionItem(
                        icon: '⚖️',
                        title: 'COPPA & GDPR Compliance',
                        description:
                            'Because no personal identifiers or media are permanently retained, SnapBeat complies with COPPA and GDPR regulations for user privacy.',
                      ),

                      const SizedBox(height: 8),
                      // Support Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.panelInset,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderBrass, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Developer Contact',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textFoilGold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'For inquiries, reach out to support@snapbeat.app. Deletion is instantaneous upon render completion.',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer / Action Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.canvasChassis,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                border: Border(
                  top: BorderSide(color: AppColors.chassisBevelLight, width: 1.2),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.brassKnobGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: AppColors.hardwareGunmetal,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'GOT IT',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionItem({
    required String icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.panelInset,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.chassisBevelLight, width: 1),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textEngraved,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
