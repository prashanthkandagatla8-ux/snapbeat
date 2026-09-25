import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  final bool isEula;
  const PrivacyPolicyDialog({super.key, this.isEula = false});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => const PrivacyPolicyDialog(isEula: false),
    );
  }

  static Future<void> showEula(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => const PrivacyPolicyDialog(isEula: true),
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
                    child: Text(widget.isEula ? '' : '', style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEula ? 'Terms of Service (EULA)' : 'Privacy & Data Safety',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppColors.textEngraved,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isEula
                              ? 'Apple Standard End User License Agreement'
                              : (Platform.isIOS ? 'App Store & Privacy Compliant' : 'Google Play Policy Compliant'),
                          style: const TextStyle(
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
                      if (widget.isEula) ...[
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
                              Icon(Icons.gavel_rounded, size: 14, color: AppColors.brassGold),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'SnapBeat is licensed subject to the Apple Standard EULA.',
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
                        GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                          },
                          child: _buildSectionItem(
                            icon: '',
                            title: 'Apple Standard Terms of Use (EULA)',
                            description:
                                'By downloading or using SnapBeat, you agree to Apple\'s Standard Licensed Application End User License Agreement:\nhttps://www.apple.com/legal/internet-services/itunes/dev/stdeula/ (Tap to open)',
                          ),
                        ),
                        _buildSectionItem(
                          icon: '',
                          title: 'Subscription & Auto-Renewal',
                          description:
                              'Payment will be charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current billing period. Your account will be charged for renewal within 24 hours prior to the end of the period. Manage or cancel subscriptions in App Store account settings.',
                        ),
                        _buildSectionItem(
                          icon: '',
                          title: 'User Content Ownership',
                          description:
                              'You retain full copyright and ownership of all photos, music, and assembled video reels you select or create with SnapBeat.',
                        ),
                        _buildSectionItem(
                          icon: '',
                          title: 'Refunds & In-App Purchases',
                          description:
                              'All subscriptions and purchases are processed directly by Apple StoreKit. Refund requests are subject to Apple Media Services Terms and Conditions.',
                        ),
                      ] else ...[
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
                              icon: '',
                              title: 'Ephemeral Media Processing',
                              description:
                                  'User-selected photos and audio tracks are transmitted over encrypted HTTPS/TLS exclusively to the cloud rendering engine to detect musical beats and assemble your video reel.',
                            ),

                            _buildSectionItem(
                              icon: '',
                              title: 'Instant File Deletion',
                              description:
                                  'Input files are processed in volatile temporary storage and purged permanently immediately upon render completion. No user images or songs are ever archived on servers.',
                            ),

                            _buildSectionItem(
                              icon: '',
                              title: 'Advertising & Consent',
                              description:
                                  'Free users see a full-screen ad before a reel plays. Subscribers see no ads at all. Ads come from Google AdMob, which may use a device advertising identifier to serve them. Consent is handled through Google\'s UMP form where local law requires it. As always, there is no sale of personal media, no cross-app tracking for profiling, and no AI/ML training on user photos or music.',
                            ),

                            _buildSectionItem(
                              icon: '',
                              title: 'No AI Training & Zero Data Sales',
                              description:
                                  'Your personal media is never sold, rented, or shared with third parties. Your photos and music are strictly prohibited from being used to train AI or machine learning models.',
                            ),

                            _buildSectionItem(
                              icon: '',
                              title: 'Minimal Scoped Permissions',
                              description:
                                  'System photo picker and audio file access are requested solely when you select media for your reel. We cannot access your full library or unselected private files.',
                            ),

                            _buildSectionItem(
                              icon: '',
                              title: 'COPPA & GDPR Compliance',
                              description:
                                  'Because no personal identifiers or media are permanently retained, SnapBeat complies with COPPA and GDPR regulations for user privacy.',
                            ),
                          ],

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

