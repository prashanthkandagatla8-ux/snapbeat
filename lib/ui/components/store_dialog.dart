import 'package:flutter/material.dart';
import '../../services/credit_manager.dart';
import '../../theme/app_colors.dart';
import 'privacy_policy_dialog.dart';

class StoreBottomSheet extends StatefulWidget {
  final VoidCallback onPurchaseComplete;

  const StoreBottomSheet({super.key, required this.onPurchaseComplete});

  static void show(BuildContext context, {required VoidCallback onPurchaseComplete}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StoreBottomSheet(onPurchaseComplete: onPurchaseComplete),
    );
  }

  @override
  State<StoreBottomSheet> createState() => _StoreBottomSheetState();
}

class _StoreBottomSheetState extends State<StoreBottomSheet> {
  final cm = CreditManager.instance;

  @override
  Widget build(BuildContext context) {
    final p = cm.pricing;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvasChassis,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.chassisBevelLight, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.brassKnobGradient,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 2),
                      ],
                    ),
                    child: Text(
                      '⚡ ${cm.credits} Credits',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.hardwareGunmetal,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Store',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textEngraved,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Plan 1: Watermark Removal
          _buildPlanTile(
            title: 'Remove Watermark',
            price: p.removeWatermarkPrice,
            subtitle: p.removeWatermarkSubtitle,
            isActive: cm.isWatermarkRemoved,
            onBuy: () {
              cm.setWatermarkRemoved(true);
              widget.onPurchaseComplete();
              setState(() {});
            },
          ),
          const SizedBox(height: 10),

          // Plan 2: Enable Pro Mode
          _buildPlanTile(
            title: 'Unlock Pro Mode',
            price: p.proModePrice,
            subtitle: p.proModeSubtitle,
            isActive: cm.isProModeEnabled,
            isFeatured: true,
            onBuy: () {
              cm.setProModeEnabled(true);
              widget.onPurchaseComplete();
              setState(() {});
            },
          ),
          const SizedBox(height: 14),

          // Credit Bundles
          const Text(
            'Credit Packs',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildCreditTile('5 Credits', p.starterPrice, 5),
              const SizedBox(width: 8),
              _buildCreditTile('15 Credits', p.partyPrice, 15, isPopular: true),
              const SizedBox(width: 8),
              _buildCreditTile('50 Credits', p.studioPrice, 50),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => PrivacyPolicyDialog.show(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text(
                'Privacy Policy & Data Safety',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPlanTile({
    required String title,
    required String price,
    required String subtitle,
    required bool isActive,
    required VoidCallback onBuy,
    bool isFeatured = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelCream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFeatured ? AppColors.brassGold : AppColors.chassisBevelDark,
          width: isFeatured ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textEngraved,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isFeatured) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.amberJewel,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isActive ? null : onBuy,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isActive ? null : AppColors.brassKnobGradient,
                  color: isActive ? Colors.grey.shade400 : null,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isActive
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            offset: const Offset(1, 2),
                            blurRadius: 3,
                          ),
                        ],
                ),
                child: Text(
                  isActive ? '✓ Active' : price,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : AppColors.hardwareGunmetal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditTile(String label, String price, int passes, {bool isPopular = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          cm.addCredits(passes);
          widget.onPurchaseComplete();
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.panelCream,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPopular ? AppColors.brassGold : AppColors.chassisBevelDark,
              width: isPopular ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textEngraved,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textFoilGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}