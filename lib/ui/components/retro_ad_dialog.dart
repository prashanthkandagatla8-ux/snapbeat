import 'package:flutter/material.dart';
import '../../services/ad_config.dart';
import '../../services/ad_manager.dart';
import '../../theme/app_colors.dart';
import 'retro_subscription_dialog.dart';

/// Retro brushed-metal modal dialog prompting free users to watch a rewarded ad to unlock clean/HD export.
class RetroAdDialog extends StatefulWidget {
  final VoidCallback onCleanExportUnlocked;
  final VoidCallback onWatermarkedExport;

  const RetroAdDialog({
    super.key,
    required this.onCleanExportUnlocked,
    required this.onWatermarkedExport,
  });

  /// Displays the ad unlock dialog.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCleanExportUnlocked,
    required VoidCallback onWatermarkedExport,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RetroAdDialog(
        onCleanExportUnlocked: onCleanExportUnlocked,
        onWatermarkedExport: onWatermarkedExport,
      ),
    );
  }

  @override
  State<RetroAdDialog> createState() => _RetroAdDialogState();
}

class _RetroAdDialogState extends State<RetroAdDialog> {
  int _remainingPasses = AdConfig.maxDailyAdCleanDownloads;
  bool _isLoadingPasses = true;

  @override
  void initState() {
    super.initState();
    _loadPassCount();
  }

  Future<void> _loadPassCount() async {
    final count = await AdConfig.getRemainingPassesToday();
    if (mounted) {
      setState(() {
        _remainingPasses = count;
        _isLoadingPasses = false;
      });
    }
  }

  Future<void> _handleWatchAd() async {
    Navigator.pop(context);

    await AdManager.instance.showRewardedAd(
      context: context,
      onRewardEarned: () async {
        await AdConfig.consumeDailyPass();
        widget.onCleanExportUnlocked();
      },
      onFallbackGranted: () async {
        // If ad network has no fill or error, never block user!
        await AdConfig.consumeDailyPass();
        widget.onCleanExportUnlocked();
      },
      onDismissed: () {
        // User closed ad early without reward
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Watch the complete sponsor video to unlock clean watermark removal.',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 12),
              ),
              backgroundColor: AppColors.metalDeepCavity,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPasses = _remainingPasses > 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvasChassis,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.chassisBevelLight, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.chassisBevelDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Dialog Header
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brassGold,
                  boxShadow: [
                    BoxShadow(color: AppColors.brassGold, blurRadius: 6, spreadRadius: 1),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'EXPORT OPTIONS',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppColors.brassGold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textEngraved, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Daily Pass Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.metalDeepCavity,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.chassisBevelDark, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  hasPasses ? Icons.bolt_rounded : Icons.info_outline_rounded,
                  color: hasPasses ? AppColors.vuGreen : AppColors.amberJewel,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoadingPasses
                            ? 'Checking passes...'
                            : hasPasses
                                ? '$_remainingPasses of ${AdConfig.maxDailyAdCleanDownloads} Free Clean Passes Remaining'
                                : 'Daily Clean Pass Limit Reached (5/5)',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: hasPasses ? AppColors.vuGreen : AppColors.amberJewel,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasPasses
                            ? 'Watch a quick sponsor video to unlock clean watermark removal.'
                            : 'Watermarked exports remain 100% free and unlimited, or upgrade to Pro.',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Primary Action: Watch Ad (if passes remain)
          if (hasPasses) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brassGold,
                  foregroundColor: Colors.black,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.brassHighlight, width: 1.5),
                  ),
                ),
                icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
                label: const Text(
                  'WATCH AD TO REMOVE WATERMARK',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                    letterSpacing: 0.8,
                  ),
                ),
                onPressed: _handleWatchAd,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Secondary Action: Upgrade to Pro
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.panelCreamDark,
                foregroundColor: AppColors.brassGold,
                side: const BorderSide(color: AppColors.brassGold, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.workspace_premium_rounded, size: 20, color: AppColors.brassGold),
              label: const Text(
                'UPGRADE TO PRO — NEVER SEE ADS',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.5,
                  color: AppColors.brassGold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                RetroSubscriptionDialog.show(context);
              },
            ),
          ),
          const SizedBox(height: 10),

          // Tertiary Action: Free Watermarked Download (Always Available & Unblocked)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onWatermarkedExport();
            },
            child: const Text(
              'Keep Watermark (Free Download)',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textEngraved,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
