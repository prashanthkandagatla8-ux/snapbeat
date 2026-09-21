import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../services/subscription_manager.dart';

/// Configuration for paywall subscription tier cards.
class _PaywallCardConfig {
  final ProTier tier;
  final String title;
  final String? badge;
  final IconData icon;
  final List<String> features;
  final String fallbackPrice;
  final String period;

  const _PaywallCardConfig({
    required this.tier,
    required this.title,
    this.badge,
    required this.icon,
    required this.features,
    required this.fallbackPrice,
    required this.period,
  });
}

/// Production-ready SnapBeat Pro Paywall dialog matching paywall_mockup_new_1789909194554.jpg.
/// Fully compliant with App Store Guideline 3.1.2 and 100% pure ASCII.
class RetroSubscriptionDialog extends StatefulWidget {
  const RetroSubscriptionDialog({super.key});

  /// Displays the subscription modal bottom sheet.
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
  ProTier _selectedTier = ProTier.monthly; // Default to 'Best Value' tier as shown in mockup

  static const List<_PaywallCardConfig> _cards = [
    _PaywallCardConfig(
      tier: ProTier.weekly,
      title: 'Weekly Pass',
      badge: null,
      icon: Icons.calendar_today_outlined,
      features: [
        'Unlimited Exports',
        'No Watermarks',
        '100+ Pro Filters',
      ],
      fallbackPrice: '\u20B9149',
      period: ' / Week',
    ),
    _PaywallCardConfig(
      tier: ProTier.monthly,
      title: 'Monthly VIP',
      badge: 'Best Value',
      icon: Icons.workspace_premium_rounded,
      features: [
        'All Weekly Features',
        'Premium Transitions',
        'Gold Assets & Music',
      ],
      fallbackPrice: '\u20B9349',
      period: ' / Month',
    ),
    _PaywallCardConfig(
      tier: ProTier.annual,
      title: 'Annual VIP',
      badge: 'Save 57%',
      icon: Icons.cloud_outlined,
      features: [
        'Complete Creative Suite',
        'Priority Support',
        'Cloud Sync',
      ],
      fallbackPrice: '\u20B91,799',
      period: ' / Year',
    ),
  ];

  @override
  void initState() {
    super.initState();
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

  String _getPriceAmount(_PaywallCardConfig card) {
    final product = _sm.products[card.tier.productId];
    if (product != null && product.price.isNotEmpty) {
      return product.price;
    }
    return card.fallbackPrice;
  }

  Future<void> _handleSubscribe() async {
    HapticFeedback.mediumImpact();
    final product = _sm.products[_selectedTier.productId];
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connecting to ${Platform.isIOS ? "App Store" : "Google Play"}... Please verify network.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1E1E24),
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
          backgroundColor: const Color(0xFFEF4444),
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
        backgroundColor: const Color(0xFF1E1E24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPro = _sm.isPro;
    final isPurchasing = _sm.isPurchasing;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F13),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0x33FFFFFF), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            offset: Offset(0, -8),
            blurRadius: 28,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: bottomPadding + 20,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pull Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Top Header: Close Button (left) + Center Logo & Title
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Official 3D SnapBeat Studio Logo
                    Image.asset(
                      'assets/images/snapbeat_studio_logo.png',
                      height: 52,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 4),
                        ],
                      ),
                      child: const Text(
                        'STUDIO PRO',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF141518),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Unlock 1080p Master & Zero Watermark',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE2E8F0),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Active Pro Banner (if already subscribed)
            if (isPro) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF141418),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
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
                              color: Color(0xFF10B981),
                              letterSpacing: 1.0,
                            ),
                          ),
                          if (_sm.expiresAt != null)
                            Text(
                              'Renews / Expires: ${_sm.expiresAt!.toLocal().toString().split(".")[0]}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
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

            // 3 Subscription Cards
            for (int i = 0; i < _cards.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _buildTierCard(_cards[i]),
            ],
            const SizedBox(height: 22),

            // Status message (if any error/progress)
            if (_sm.statusMessage != null) ...[
              Center(
                child: Text(
                  _sm.statusMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFB800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Primary Glowing CTA Subscribe Button
            _buildSubscribeButton(isPurchasing),
            const SizedBox(height: 16),

            // App Store Footer Links
            _buildFooterLinks(isPurchasing),
            const SizedBox(height: 12),

            // App Store Guideline 3.1.2 Auto-Renewal Disclaimer
            _buildLegalDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(_PaywallCardConfig card) {
    final isSelected = _selectedTier == card.tier;
    final priceAmount = _getPriceAmount(card);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedTier = card.tier);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C1A14) : const Color(0xFF141418),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFB800) : const Color(0xFF282832),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFB800).withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Leading Icon + Title + Optional Badge
            Row(
              children: [
                Icon(
                  card.icon,
                  color: const Color(0xFFFFB800),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (card.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFB800)
                          : const Color(0x26FFB800),
                      borderRadius: BorderRadius.circular(6),
                      border: isSelected
                          ? null
                          : Border.all(color: const Color(0x66FFB800), width: 1.0),
                    ),
                    child: Text(
                      card.badge!,
                      style: TextStyle(
                        color: isSelected ? Colors.black : const Color(0xFFFFB800),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Feature Checklist + Price Display Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final feature in card.features) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                color: Color(0xFFFFB800),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    color: Color(0xFFD1D1D6),
                                    fontSize: 11.0,
                                    letterSpacing: -0.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                RichText(
                  textAlign: TextAlign.end,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: priceAmount,
                        style: const TextStyle(
                          color: Color(0xFFFFB800),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: card.period,
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(bool isPurchasing) {
    return GestureDetector(
      onTap: isPurchasing ? null : _handleSubscribe,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFCA28),
              Color(0xFFFFA000),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA000).withValues(alpha: 0.45),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : const Text(
                  'Subscribe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks(bool isPurchasing) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 6,
      children: [
        GestureDetector(
          onTap: () {
            launchUrl(Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
          },
          child: const Text(
            'Terms of Service',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            launchUrl(Uri.parse(AppConfig.privacyPolicyUrl));
          },
          child: const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
            ),
          ),
        ),
        GestureDetector(
          onTap: isPurchasing ? null : _handleRestore,
          child: const Text(
            'Restore Purchase',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalDisclaimer() {
    final currentCard = _cards.firstWhere(
      (c) => c.tier == _selectedTier,
      orElse: () => _cards[1],
    );
    final priceStr = '${_getPriceAmount(currentCard)}${currentCard.period}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        Platform.isIOS
            ? 'Payment of $priceStr will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless canceled in App Store Account Settings at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the period.'
            : 'Payment of $priceStr will be billed through Google Play at confirmation of purchase. Subscription automatically renews unless canceled in Google Play Subscriptions before the end of the current period.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 9.5,
          color: Color(0xFF64748B),
          height: 1.35,
        ),
      ),
    );
  }
}
