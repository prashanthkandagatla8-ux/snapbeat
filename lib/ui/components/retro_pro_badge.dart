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
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isPro ? AppColors.iridescentGradient : null,
              color: isPro ? null : AppColors.indicatorAccent.withValues(alpha: 0.5),
              boxShadow: AppColors.neumorphicBlackRaised,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.pianoLacquer,
                borderRadius: BorderRadius.circular(14.5),
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
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: isPro ? 0.8 : 0.2),
                        blurRadius: isPro ? 6 : 2,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (showLabel) ...[
                  const SizedBox(width: 6),
                  Text(
                    isPro ? 'PRO ACTIVE' : 'GET PRO',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
      },
    );
  }
}
