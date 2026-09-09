import 'package:flutter/material.dart';
import '../../services/credit_manager.dart';
import '../../theme/app_colors.dart';

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
        color: AppColors.canvasDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.goldPrimary, width: 1.5)),
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
                      color: AppColors.amberBadgeBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4)),
                    ),
                    child: Text(
                      "⚡ ${cm.credits} Passes",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.goldBright),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("SnapBeat Store", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ══════════ PLAN 1: REMOVE WATERMARK (₹99) ══════════
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cyanAccent.withOpacity(0.5), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("🚫 REMOVE WATERMARK", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.cyanAccent)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.cyanGlow, borderRadius: BorderRadius.circular(8)),
                      child: const Text("LIFETIME", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.cyanAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(p.removeWatermarkSubtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: cm.isWatermarkRemoved
                        ? null
                        : () async {
                            await cm.setWatermarkRemoved(true);
                            if (mounted) {
                              setState(() {});
                              widget.onPurchaseComplete();
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyanAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      cm.isWatermarkRemoved ? "ACTIVE ✓ (UNLOCKED)" : "UNLOCK FOR ${p.removeWatermarkPrice}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ══════════ PLAN 2: ENABLE PRO MODE (₹199) ══════════
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.goldPrimary, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("👑 ENABLE PRO MODE", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.goldBright)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.amberBadgeBg, borderRadius: BorderRadius.circular(8)),
                      child: const Text("ALL ACCESS", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.goldBright)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(p.proModeSubtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: cm.isProModeEnabled
                        ? null
                        : () async {
                            await cm.setProModeEnabled(true);
                            if (mounted) {
                              setState(() {});
                              widget.onPurchaseComplete();
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      cm.isProModeEnabled ? "ACTIVE ✓ (PRO UNLOCKED)" : "ENABLE PRO FOR ${p.proModePrice}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Instant Credit Packs Grid (2x2)
          const Text("⚡ Instant Render Credit Packs", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _buildCreditTile("Starter Pack", "10 Credits", p.starterPrice, 10),
              _buildCreditTile("Party Pack", "35 Credits", p.partyPrice, 35),
              _buildCreditTile("Studio Pack", "80 Credits", p.studioPrice, 80),
              _buildCreditTile("Director Pack", "200 Credits", p.directorPrice, 200),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCreditTile(String title, String count, String price, int creditsToAdd) {
    return GestureDetector(
      onTap: () async {
        await cm.addCredits(creditsToAdd);
        setState(() {});
        widget.onPurchaseComplete();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(count, style: const TextStyle(fontSize: 9, color: AppColors.goldBright)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.goldPrimary, borderRadius: BorderRadius.circular(8)),
              child: Text(price, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
