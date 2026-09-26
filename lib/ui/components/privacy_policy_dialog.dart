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
    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'Montserrat',
          decoration: TextDecoration.none,
          color: AppColors.primaryDarkText,
        ),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
            decoration: BoxDecoration(
              color: AppColors.ceramicWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.chipBorder, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x60000000),
                  offset: Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Nameplate
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.canvasBg,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(
                      bottom: BorderSide(color: AppColors.chipBorder, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: AppColors.pianoBlack,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0x35FFFFFF), width: 1),
                        ),
                        child: Center(
                          child: Icon(
                            widget.isEula ? Icons.gavel_rounded : Icons.shield_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
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
                                color: AppColors.primaryDarkText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.isEula
                                  ? 'Apple Standard End User License Agreement'
                                  : (Platform.isIOS ? 'App Store & Privacy Compliant' : 'Google Play Policy Compliant'),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: AppColors.secondaryDarkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.primaryDarkText, size: 20),
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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isEula) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.chipSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.chipBorder, width: 1),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.gavel_rounded, size: 16, color: AppColors.primaryDarkText),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'SnapBeat is licensed subject to the Apple Standard EULA.',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 11,
                                        color: AppColors.primaryDarkText,
                                        fontWeight: FontWeight.w600,
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
                                icon: Icons.description_outlined,
                                title: 'Apple Standard Terms of Use (EULA)',
                                description:
                                    'By downloading or using SnapBeat, you agree to Apple\'s Standard Licensed Application End User License Agreement:\nhttps://www.apple.com/legal/internet-services/itunes/dev/stdeula/ (Tap to open)',
                              ),
                            ),
                            _buildSectionItem(
                              icon: Icons.autorenew_rounded,
                              title: 'Subscription & Auto-Renewal',
                              description:
                                  'Payment will be charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current billing period. Your account will be charged for renewal within 24 hours prior to the end of the period. Manage or cancel subscriptions in App Store account settings.',
                            ),
                            _buildSectionItem(
                              icon: Icons.copyright_rounded,
                              title: 'User Content Ownership',
                              description:
                                  'You retain full copyright and ownership of all photos, music, and assembled video reels you select or create with SnapBeat.',
                            ),
                            _buildSectionItem(
                              icon: Icons.receipt_long_outlined,
                              title: 'Refunds & In-App Purchases',
                              description:
                                  'All subscriptions and purchases are processed directly by Apple StoreKit. Refund requests are subject to Apple Media Services Terms and Conditions.',
                            ),
                          ] else ...[
                            // Privacy Architecture Note
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.chipSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.chipBorder, width: 1),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.primaryDarkText),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'SnapBeat is engineered with a strict privacy-by-design architecture.',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 11,
                                        color: AppColors.primaryDarkText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            _buildSectionItem(
                              icon: Icons.cloud_sync_outlined,
                              title: 'Ephemeral Media Processing',
                              description:
                                  'User-selected photos and audio tracks are transmitted over encrypted HTTPS/TLS exclusively to the cloud rendering engine to detect musical beats and assemble your video reel.',
                            ),

                            _buildSectionItem(
                              icon: Icons.delete_sweep_outlined,
                              title: 'Instant File Deletion',
                              description:
                                  'Input files are processed in volatile temporary storage and purged permanently immediately upon render completion. No user images or songs are ever archived on servers.',
                            ),

                            _buildSectionItem(
                              icon: Icons.campaign_outlined,
                              title: 'Advertising & Consent',
                              description:
                                  'Free users see a full-screen ad before a reel plays. Subscribers see no ads at all. Ads come from Google AdMob, which may use a device advertising identifier to serve them. Consent is handled through Google\'s UMP form where local law requires it. As always, there is no sale of personal media, no cross-app tracking for profiling, and zero external data harvesting.',
                            ),

                            _buildSectionItem(
                              icon: Icons.shield_outlined,
                              title: 'Zero Data Harvesting & No Data Sales',
                              description:
                                  'Your personal media is never sold, rented, or shared with third parties. Your photos and music are strictly prohibited from being archived or used for external model training.',
                            ),

                            _buildSectionItem(
                              icon: Icons.photo_library_outlined,
                              title: 'Minimal Scoped Permissions',
                              description:
                                  'System photo picker and audio file access are requested solely when you select media for your reel. We cannot access your full library or unselected private files.',
                            ),

                            _buildSectionItem(
                              icon: Icons.verified_user_outlined,
                              title: 'COPPA & GDPR Compliance',
                              description:
                                  'Because no personal identifiers or media are permanently retained, SnapBeat complies with COPPA and GDPR regulations for user privacy.',
                            ),
                          ],

                          const SizedBox(height: 10),
                          // Support Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.chipSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.chipBorder, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'DEVELOPER CONTACT',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: AppColors.primaryDarkText,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'For inquiries, reach out to privacy@snapbeat.app or support@snapbeat.app. Deletion is instantaneous upon render completion.',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 10.5,
                                    color: AppColors.secondaryDarkText,
                                    height: 1.45,
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
                    color: AppColors.ceramicWhite,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    border: Border(
                      top: BorderSide(color: AppColors.chipBorder, width: 1),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pianoBlack,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        side: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'GOT IT',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: AppColors.chipSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.chipBorder, width: 1),
            ),
            child: Center(
              child: Icon(icon, size: 16, color: AppColors.primaryDarkText),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    color: AppColors.secondaryDarkText,
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
