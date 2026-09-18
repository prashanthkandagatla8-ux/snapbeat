import 'package:flutter/material.dart';
import '../../services/subscription_manager.dart';
import '../../theme/app_colors.dart';
import 'retro_subscription_dialog.dart';

/// Compact analog indicator badge showing Pro subscription status.
class RetroProBadge extends StatelessWidget {
  final bool showLabel;
  final VoidCallback? onTap;

  const RetroProBadge({
    super.key,
    this.showLabel = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sm = SubscriptionManager.instance;

    return AnimatedBuilder(
      animation: sm,
      builder: (context, child) {
        final isPro = sm.isPro;

        return GestureDetector(
          onTap: onTap ?? () => RetroSubscriptionDialog.show(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.metalDeepCavity,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPro ? AppColors.vuGreen : AppColors.brassGold,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isPro ? AppColors.vuGreen : AppColors.amberJewel).withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Backlit LED jewel
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPro ? AppColors.vuGreen : AppColors.amberJewel,
                    boxShadow: [
                      BoxShadow(
                        color: (isPro ? AppColors.vuGreen : AppColors.amberJewel).withOpacity(0.8),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (showLabel) ...[
                  const SizedBox(width: 6),
                  Text(
                    isPro ? 'PRO ACTIVE' : 'GET PRO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: isPro ? AppColors.vuGreen : AppColors.brassGold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
