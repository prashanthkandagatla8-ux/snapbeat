import 'package:flutter/material.dart';
import '../../services/subscription_manager.dart';
import '../../theme/app_colors.dart';
import 'retro_subscription_dialog.dart';

/// Graphite Neo v3.0 tactile capsule badge showing Pro subscription status.
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
              color: AppColors.pianoLacquer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPro ? AppColors.vuGreen : AppColors.indicatorAccent.withValues(alpha: 0.5),
                width: 1.0,
              ),
              boxShadow: AppColors.neumorphicBlackRaised,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Backlit LED indicator
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPro ? AppColors.vuGreen : AppColors.indicatorAccent,
                    boxShadow: [
                      BoxShadow(
                        color: (isPro ? AppColors.vuGreen : AppColors.indicatorAccent).withValues(alpha: 0.75),
                        blurRadius: 4,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),
                if (showLabel) ...[
                  const SizedBox(width: 6),
                  Text(
                    isPro ? 'PRO ACTIVE' : 'GET PRO',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: isPro ? AppColors.vuGreen : AppColors.textPrimary,
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
