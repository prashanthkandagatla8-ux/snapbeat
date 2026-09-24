import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../services/subscription_manager.dart';
import '../../theme/app_colors.dart';
import '../screens/home_screen.dart';

/// Configuration for paywall subscription tier cards.
class _PaywallCardConfig {
  final ProTier tier;
  final String title;
  final String? badge;
  final IconData icon;
  final List<String> features;
  final String period;

  const _PaywallCardConfig({
    required this.tier,
    required this.title,
    this.badge,
    required this.icon,
    required this.features,
    required this.period,
  });

  String? get badgeText => tier == ProTier.annual ? tier.badgeText : badge;
}

/// SnapBeat Pro Paywall dialog matching watermark_clean.png aesthetic:
/// Ceramic White substrate sheet with floating Shiny Piano Black tier cards,
/// Radiant Amber Gold badges, and authentic watermark squircle emblem.
/// Zero purple, zero olive, fully unified with Master Console.
class RetroSubscriptionDialog extends StatefulWidget {
  final String? reason;
  const RetroSubscriptionDialog({super.key, this.reason});

  /// Displays the subscription modal bottom sheet.
  static Future<void> show(BuildContext context, {String? reason}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RetroSubscriptionDialog(reason: reason),
    );
  }

  @override
  State<RetroSubscriptionDialog> createState() => _RetroSubscriptionDialogState();
}

class _RetroSubscriptionDialogState extends State<RetroSubscriptionDialog> {
  final SubscriptionManager _sm = SubscriptionManager.instance;
  ProTier _selectedTier = ProTier.monthly; // Default to 'Best Value' tier

  static const List<_PaywallCardConfig> _cards = [
    _PaywallCardConfig(
      tier: ProTier.weekly,
      title: 'Weekly Pass',
      badge: null,
      icon: Icons.calendar_today_outlined,
      features: [
        '1080p Master export',
        'No watermark',
        'Priority render queue',
        'Unlimited exports',
      ],
      period: ' / Week',
    ),
    _PaywallCardConfig(
      tier: ProTier.monthly,
      title: 'Monthly VIP',
      badge: 'Best Value',
      icon: Icons.workspace_premium_rounded,
      features: [
        '1080p Master export',
        'No watermark',
        'Priority render queue',
        'Unlimited exports',
      ],
      period: ' / Month',
    ),
    _PaywallCardConfig(
      tier: ProTier.annual,
      title: 'Annual VIP',
      icon: Icons.cloud_outlined,
      features: [
        '1080p Master export',
        'No watermark',
        'Priority render queue',
        'Unlimited exports',
      ],
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
    return _sm.formattedPrice(card.tier);
  }

  Future<void> _handleSubscribe() async {
    HapticFeedback.heavyImpact();
    final product = _sm.products[_selectedTier.productId];
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connecting to ${Platform.isIOS ? "App Store" : "Google Play"}... Please verify network.',
            style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white),
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
          backgroundColor: const Color(0xFFE11D48),
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
          style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white),
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

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
        color: AppColors.ceramicWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x30000000),
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
                  color: const Color(0xFFCBD5E1),
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
                        color: Colors.black.withValues(alpha: 0.06),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF334155),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Authentic Squircle Emblem matching watermark_clean.png
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x30000000),
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: HomeScreen.logoUiImage != null
                            ? RawImage(
                                image: HomeScreen.logoUiImage!,
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                'assets/images/snapbeat_app_icon.png',
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E212B), Color(0xFF0B0D11)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0x25FFFFFF), width: 1.0),
                        boxShadow: const [
                          BoxShadow(color: Color(0x20000000), offset: Offset(0, 2), blurRadius: 4),
                        ],
                      ),
                      child: const Text(
                        'STUDIO PRO',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.amberGold,
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
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informative Notice Banner (if any)
            if (widget.reason != null && widget.reason!.trim().isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B1E26), Color(0xFF0F1116)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.5), width: 1.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_rounded, color: AppColors.amberGold, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.reason!.trim(),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Active Pro Banner (if already subscribed)
            if (isPro) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B1E26), Color(0xFF0F1116)],
                  ),
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
                              fontFamily: 'Montserrat',
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
                                fontFamily: 'Montserrat',
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

            // 3 Floating Shiny Piano Black Tier Cards
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
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amberGold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Primary Shiny Piano Black CTA Subscribe Button
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSelected
                ? const [Color(0xFF242835), Color(0xFF101217), Color(0xFF050608)]
                : const [Color(0xFF1A1C24), Color(0xFF0D0E12), Color(0xFF040507)],
            stops: const [0.0, 0.45, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.amberGold : const Color(0x28FFFFFF),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x28000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.amberGold.withValues(alpha: 0.25),
                    blurRadius: 14,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
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
                  color: isSelected ? AppColors.amberGold : const Color(0xFF94A3B8),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (card.badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.amberGold
                          : const Color(0x25FFB300),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? AppColors.amberGold : const Color(0x60FFB300),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      card.badgeText!,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: isSelected ? const Color(0xFF0A0D11) : AppColors.amberGold,
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
                                color: AppColors.amberGold,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Color(0xFFD1D5DB),
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
                          fontFamily: 'Montserrat',
                          color: AppColors.amberGold,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: card.period,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color(0xFF94A3B8),
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
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF262A36), Color(0xFF13151D), Color(0xFF08090D)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.6), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x35000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x25FFB300),
              blurRadius: 14,
              offset: Offset(0, 0),
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
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.amberGold),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.amberGold,
                        boxShadow: [
                          BoxShadow(color: Color(0x80FFB300), blurRadius: 6, spreadRadius: 1),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'UPGRADE TO PRO',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
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
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        GestureDetector(
          onTap: isPurchasing ? null : _handleRestore,
          child: const Text(
            'Restore Purchase',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
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
        (Platform.isIOS || !Platform.isAndroid)
            ? 'Payment of $priceStr will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless canceled in App Store Account Settings at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the period.'
            : 'Payment of $priceStr will be billed through Google Play at confirmation of purchase. Subscription automatically renews unless canceled in Google Play Subscriptions before the end of the current period.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 9.5,
          color: Color(0xFF94A3B8),
          height: 1.35,
        ),
      ),
    );
  }
}
