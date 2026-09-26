import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/subscription_manager.dart';
import '../../theme/app_colors.dart';
import 'privacy_policy_dialog.dart';
import 'retro_subscription_dialog.dart';

/// SnapBeat Account & Activation Plan Inspector
/// Displays user's current subscription tier, credits / daily quota remaining,
/// plan expiry or auto-renewal date, restore purchases action, and option to replay
/// the interactive feature showcase tour.
class AccountPlanDialog extends StatefulWidget {
  final VoidCallback? onReplayShowcase;

  const AccountPlanDialog({
    super.key,
    this.onReplayShowcase,
  });

  /// Presents the Account & Activation Plan sheet.
  static Future<void> show(BuildContext context, {VoidCallback? onReplayShowcase}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(color: Colors.transparent, child: AccountPlanDialog(onReplayShowcase: onReplayShowcase)),
    );
  }

  @override
  State<AccountPlanDialog> createState() => _AccountPlanDialogState();
}

class _AccountPlanDialogState extends State<AccountPlanDialog> {
  final SubscriptionManager _sm = SubscriptionManager.instance;
  int _freeRendersUsed = 0;
  bool _isLoadingQuota = true;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _loadDailyQuota();
  }

  Future<void> _loadDailyQuota() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDate = prefs.getString('free_render_date') ?? '';
      int count = prefs.getInt('free_render_count') ?? 0;
      if (lastDate != todayStr) {
        count = 0;
      }
      if (mounted) {
        setState(() {
          _freeRendersUsed = count;
          _isLoadingQuota = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingQuota = false);
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isRestoring = true);
    try {
      await _sm.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _sm.isPro ? "Purchases restored successfully! Pro VIP is active." : "No active subscription found to restore.",
            ),
            backgroundColor: _sm.isPro ? AppColors.statusGreen : AppColors.pianoBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Restore failed: $e"),
            backgroundColor: AppColors.pianoBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  void _triggerReplayShowcase() {
    Navigator.of(context).pop();
    widget.onReplayShowcase?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sm,
      builder: (context, _) {
        final isPro = _sm.isPro;
        final activeTier = _sm.activeTier;
        final expiresAt = _sm.expiresAt;
        final txId = _sm.originalTransactionId;
        final freeRemaining = (3 - _freeRendersUsed).clamp(0, 3);

        return Material(
          color: Colors.transparent,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'Montserrat',
              decoration: TextDecoration.none,
              color: AppColors.primaryDarkText,
            ),
            child: Container(
              constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          decoration: const BoxDecoration(
            color: AppColors.ceramicWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x60000000),
                offset: Offset(0, -6),
                blurRadius: 24,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Drag Handle & Header Nameplate
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.chipBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: AppColors.pianoBlack,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(color: const Color(0x35FFFFFF), width: 1),
                              boxShadow: AppColors.darkHardwareShadow,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'ACCOUNT & PLAN',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: AppColors.primaryDarkText,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Subscription, Quota & App Settings',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.mutedDarkText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.chipSurface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.chipBorder, width: 1),
                          ),
                          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.primaryDarkText),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.chipBorder),

                // 2. Scrollable Status & Controls Body
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                    children: [
                      // A. ACTIVATION PLAN CARD (High-gloss Piano Black)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.pianoBlackGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isPro ? Colors.transparent : const Color(0x25FFFFFF),
                            width: 1.2,
                          ),
                          boxShadow: isPro ? AppColors.deepFloatingShadow : AppColors.darkHardwareShadow,
                        ),
                        child: Stack(
                          children: [
                            if (isPro)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Status Pill with Live Diode
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF141720),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isPro ? AppColors.statusGreen.withValues(alpha: 0.5) : const Color(0x30FFFFFF),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isPro ? AppColors.statusGreen : AppColors.mutedSilver,
                                              boxShadow: isPro
                                                  ? [
                                                      BoxShadow(
                                                        color: AppColors.statusGreen.withValues(alpha: 0.8),
                                                        blurRadius: 6,
                                                        spreadRadius: 1,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isPro ? 'PRO ACTIVATED' : 'FREE TIER',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.0,
                                              color: isPro ? AppColors.statusGreen : Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Action to switch / upgrade plan
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        RetroSubscriptionDialog.show(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          gradient: isPro ? null : AppColors.iridescentGradient,
                                          color: isPro ? const Color(0xFF1E2430) : null,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isPro ? const Color(0x35FFFFFF) : Colors.transparent,
                                          ),
                                        ),
                                        child: Text(
                                          isPro ? 'CHANGE PLAN' : 'UPGRADE TO PRO',
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Plan Name
                                Text(
                                  isPro
                                      ? (activeTier?.displayName ?? 'SnapBeat Pro VIP')
                                      : 'Free Creator Plan',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Plan Summary
                                Text(
                                  isPro
                                      ? 'Full access to 1080p Master Renders, zero watermark, and priority serverless processing.'
                                      : 'Standard 360p Fast Renders with SnapBeat watermark. Limited to 3 renders per day.',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // B. CREDITS & QUOTA DETAILS CARD
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.panelCream,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.chipBorder, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'DAILY QUOTA & CREDITS',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: AppColors.primaryDarkText,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.chipSurface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.chipBorder),
                                  ),
                                  child: Text(
                                    isPro ? 'UNLIMITED' : '3 RENDERS / DAY',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDarkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Quota Indicator Row
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.pianoBlack,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0x20FFFFFF)),
                                  ),
                                  child: Icon(
                                    isPro ? Icons.all_inclusive_rounded : Icons.pie_chart_outline_rounded,
                                    color: isPro ? const Color(0xFF00E5FF) : Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isPro
                                            ? 'Unlimited 1080p Master Exports'
                                            : _isLoadingQuota
                                                ? 'Loading quota...'
                                                : '$freeRemaining of 3 free renders remaining',
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryDarkText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isPro
                                            ? 'Priority Cloud Run dispatch active · Zero wait time'
                                            : 'Free quota resets daily at 00:00 midnight local time',
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.mutedDarkText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (!isPro) ...[
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _freeRendersUsed / 3.0,
                                  backgroundColor: AppColors.chipSurface,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    freeRemaining == 0 ? AppColors.pianoBlack : const Color(0xFF10B981),
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // C. PLAN EXPIRY & STORE DETAILS
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.panelCream,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.chipBorder, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PLAN EXPIRY & RENEWAL',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: AppColors.primaryDarkText,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.event_available_rounded, size: 16, color: AppColors.primaryDarkText),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isPro
                                        ? (expiresAt != null
                                            ? 'Active until ${DateFormat('MMMM d, yyyy').format(expiresAt)}'
                                            : 'Auto-renews via ${Platform.isIOS ? 'App Store' : 'Google Play'}')
                                        : 'Permanent Free Tier (Daily Renewing)',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDarkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (txId != null && txId.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.verified_outlined, size: 14, color: AppColors.mutedDarkText),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Transaction ID: ...${txId.length > 8 ? txId.substring(txId.length - 8) : txId}',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.mutedDarkText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // D. ENABLE SHOWCASE BACK (USER FEATURE TOUR REPLAY)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.panelCream,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.chipBorder, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primaryDarkText),
                                SizedBox(width: 8),
                                Text(
                                  'APP SHOWCASE & FEATURE TOUR',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: AppColors.primaryDarkText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Re-enable the interactive showcase tour anytime to explore the music visualizer, photo curation, vertical reel canvas, and pro export controls.',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                                color: AppColors.mutedDarkText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _triggerReplayShowcase,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.pianoBlack,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0x30FFFFFF), width: 1),
                                  boxShadow: AppColors.darkHardwareShadow,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.visibility_rounded, size: 14, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'REPLAY SHOWCASE TOUR',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // E. MAINTENANCE & STORE ACTIONS
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _isRestoring ? null : _handleRestore,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.chipSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.chipBorder),
                                ),
                                child: Center(
                                  child: _isRestoring
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDarkText),
                                        )
                                      : const Text(
                                          'RESTORE PURCHASES',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                            color: AppColors.primaryDarkText,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // F. FOOTER CONTACT & LEGAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => PrivacyPolicyDialog.show(context),
                            child: const Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedDarkText,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('·', style: TextStyle(color: AppColors.mutedDarkText)),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse("mailto:support@snapbeat.app?subject=SnapBeat%20Account%20Inquiry");
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            },
                            child: const Text(
                              'support@snapbeat.app',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedDarkText,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          'SnapBeat Studio v1.0.7+42 · Pro Neumorphic Edition',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedDarkText,
                          ),
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
    );
  },
);
  }
}
