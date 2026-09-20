import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/subscription_manager.dart';
import '../../theme/app_colors.dart';
import '../../config/app_config.dart';

/// Production-ready Retro Metal Paywall dialog matching SnapBeat's warm analog chassis.
class RetroSubscriptionDialog extends StatefulWidget {
  const RetroSubscriptionDialog({super.key});

  /// Displays the subscription modal.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const RetroSubscriptionDialog(),
    );
  }

  @override
  State<RetroSubscriptionDialog> createState() => _RetroSubscriptionDialogState();
}

class _RetroSubscriptionDialogState extends State<RetroSubscriptionDialog> {
  final SubscriptionManager _sm = SubscriptionManager.instance;
  ProTier _selectedTier = ProTier.annual; // Default to best value

  @override
  void initState() {
    super.initState();
    if (!SubscriptionManager.availableTiers.contains(_selectedTier)) {
      _selectedTier = SubscriptionManager.availableTiers.first;
    }
    _sm.addListener(_onManagerUpdate);
    if (_sm.products.isEmpty) {
      _sm.loadProducts();
    }
  }

  @override
  void dispose() {
    _sm.removeListener(_onManagerUpdate);
    super.dispose();
  }

  void _onManagerUpdate() {
    if (mounted) setState(() {});
  }

  String _getPriceDisplay(ProTier tier) {
    final product = _sm.products[tier.productId];
    if (product != null && product.price.isNotEmpty) {
      final unit = tier == ProTier.daily
          ? '/day'
          : tier == ProTier.weekly
              ? '/week'
              : tier == ProTier.monthly
                  ? '/mo'
                  : '/yr';
      return '${product.price}$unit';
    }
    return tier.fallbackPriceInr;
  }

  Future<void> _handleSubscribe() async {
    final product = _sm.products[_selectedTier.productId];
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connecting to ${Platform.isIOS ? "App Store" : "Google Play"}... Please verify network.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.hardwareGunmetal,
        ),
      );
      await _sm.loadProducts();
      return;
    }

    final initiated = await _sm.buySubscription(product);
    if (!initiated && mounted && _sm.statusMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_sm.statusMessage!),
          backgroundColor: AppColors.redSurface,
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    final success = await _sm.restorePurchases();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Checking previous purchases...' : 'Failed to restore purchases.',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.hardwareGunmetal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPro = _sm.isPro;
    final isPurchasing = _sm.isPurchasing;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvasChassis,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.chassisBevelLight, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, -6),
            blurRadius: 20,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Pull Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.metalScrewHead.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header with Rivets & Title
            Row(
              children: [
                _buildRivet(),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.metalDeepCavity,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.amberJewel.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.brassGold,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SNAPBEAT PRO',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: AppColors.textEngraved,
                            ),
                          ),
                          Text(
                            'CREATOR PASS & PRIORITY ACCESS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  visualDensity: VisualDensity.compact,
                ),
                _buildRivet(),
              ],
            ),
            const SizedBox(height: 16),

            // Active Pro Banner (if already subscriber)
            if (isPro) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.metalDeepCavity,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.vuGreen, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.vuGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACTIVE: ${_sm.activeTier?.displayName.toUpperCase() ?? "PRO SUBSCRIBER"}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.vuGreen,
                              letterSpacing: 1.0,
                            ),
                          ),
                          if (_sm.expiresAt != null)
                            Text(
                              'Renews / Expires: ${_sm.expiresAt!.toLocal().toString().split(".")[0]}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.panelCream,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Feature Highlights Matrix
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.panelCream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.chassisBevelLight, width: 1.5),
                boxShadow: AppColors.cardInsetShadows,
              ),
              child: Column(
                children: [
                  _buildFeatureRow(
                    icon: Icons.water_drop_outlined,
                    title: 'Remove Watermark',
                    freeText: 'Watermarked',
                    proText: 'Crystal Clean',
                    highlightPro: true,
                  ),
                  const Divider(height: 16, color: Color(0x22000000)),
                  _buildFeatureRow(
                    icon: Icons.rocket_launch_rounded,
                    title: 'Render Queue',
                    freeText: 'Normal Speed',
                    proText: 'Priority Track',
                    highlightPro: true,
                  ),
                  const Divider(height: 16, color: Color(0x22000000)),
                  _buildFeatureRow(
                    icon: Icons.hd_rounded,
                    title: 'Export Quality',
                    freeText: '720p HD',
                    proText: '1080p Master',
                    highlightPro: true,
                  ),
                  const Divider(height: 16, color: Color(0x22000000)),
                  _buildFeatureRow(
                    icon: Icons.auto_awesome_rounded,
                    title: 'All 14 Beat Templates',
                    freeText: '2 Included',
                    proText: 'All 14 Included',
                    highlightPro: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Plan Selection Label
            const Text(
              'SELECT YOUR PASS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: AppColors.textEngraved,
              ),
            ),
            const SizedBox(height: 8),

            // Available Tiers List (Platform-guarded: Daily excluded on iOS)
            Column(
              children: [
                for (int i = 0; i < SubscriptionManager.availableTiers.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _buildPlanCard(SubscriptionManager.availableTiers[i]),
                ],
              ],
            ),
            const SizedBox(height: 18),

            // Status message (if any)
            if (_sm.statusMessage != null) ...[
              Center(
                child: Text(
                  _sm.statusMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amberJewel,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Tactile CTA Subscribe Button
            GestureDetector(
              onTap: (isPurchasing || _sm.products[_selectedTier.productId] == null) ? null : _handleSubscribe,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _sm.products[_selectedTier.productId] == null ? null : AppColors.ctaButtonGradient,
                  color: _sm.products[_selectedTier.productId] == null ? AppColors.metalScrewHead : null,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _sm.products[_selectedTier.productId] == null ? AppColors.chassisBevelLight : AppColors.yellowSpecular, width: 1.5),
                  boxShadow: _sm.products[_selectedTier.productId] == null ? [] : [
                    BoxShadow(
                      color: AppColors.yellowShadow.withValues(alpha: 0.6),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: isPurchasing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.hardwareGunmetal),
                          ),
                        )
                      : Text(
                          _sm.products[_selectedTier.productId] == null 
                              ? 'PRICING UNAVAILABLE — CHECK CONNECTION' 
                              : 'SUBSCRIBE FOR ${_getPriceDisplay(_selectedTier).toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: AppColors.hardwareGunmetal,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Restore Purchases Button
            Center(
              child: TextButton(
                onPressed: isPurchasing ? null : _handleRestore,
                child: const Text(
                  'Restore Previous Purchases',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            // Legal & Terms of Use (App Store Compliance Requirement)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Text(
                    Platform.isIOS
                        ? 'Payment of ${_getPriceDisplay(_selectedTier)} will be charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless canceled in App Store Account Settings at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the period.'
                        : 'Payment of ${_getPriceDisplay(_selectedTier)} will be billed through Google Play at confirmation of purchase. Subscriptions automatically renew unless you manage or cancel in the Play Store before the end of the current period.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9.0,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          launchUrl(Uri.parse(AppConfig.privacyPolicyUrl));
                        },
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Text(
                        '  •  ',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                      GestureDetector(
                        onTap: () {
                          launchUrl(Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                        },
                        child: const Text(
                          'Terms of Service (EULA)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(ProTier tier) {
    final isSelected = _selectedTier == tier;
    final priceStr = _getPriceDisplay(tier);
    final isAnnual = tier == ProTier.annual;
    final isMonthly = tier == ProTier.monthly;

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.panelCream : AppColors.canvasChassis,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.brassGold : AppColors.chassisBevelDark.withValues(alpha: 0.4),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brassGold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Analog Radio Dial Well
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.metalDeepCavity,
                border: Border.all(
                  color: isSelected ? AppColors.brassGold : AppColors.metalScrewHead,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brassGold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Plan Title & Badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tier.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? AppColors.textEngraved : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isAnnual || isMonthly)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAnnual ? AppColors.brassGold : AppColors.amberJewel,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tier.badgeText,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.hardwareGunmetal,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    tier == ProTier.daily
                        ? '24 hours of unlimited watermark-free 1080p renders'
                        : tier == ProTier.weekly
                            ? '7 days full Pro access with fast priority queue'
                            : tier == ProTier.monthly
                                ? 'Full monthly access • Auto-renews monthly'
                                : '1 full year access • Auto-renews yearly (Save ~57%)',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Price Pill
            Text(
              priceStr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isSelected ? AppColors.textEngraved : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String freeText,
    required String proText,
    required bool highlightPro,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.hardwareGunmetal),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textEngraved,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            freeText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: highlightPro
                ? BoxDecoration(
                    color: AppColors.brassGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(
              proText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: highlightPro ? FontWeight.w900 : FontWeight.w500,
                color: highlightPro ? AppColors.hardwareGunmetal : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRivet() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.metalScrewHead,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(1, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 5,
          height: 1,
          color: AppColors.metalShadow,
        ),
      ),
    );
  }
}
