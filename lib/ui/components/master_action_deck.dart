import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MasterActionDeck extends StatelessWidget {
  final VoidCallback onMasterTap;
  final bool isRendering;
  final double progress;

  const MasterActionDeck({
    super.key,
    required this.onMasterTap,
    this.isRendering = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.canvasDark.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppColors.borderGold, width: 1.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isRendering ? null : onMasterTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.goldBright, AppColors.goldPrimary, AppColors.goldDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isRendering
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.black),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "COMPOSING REEL (${(progress * 100).toInt()}%)",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("✨", style: TextStyle(fontSize: 16)),
                              SizedBox(width: 8),
                              Text(
                                "MASTER REEL (FREE OR INSTANT)",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("🚫 Clean Renders: ₹99", style: TextStyle(fontSize: 9, color: AppColors.textDim)),
                Text("👑 Full Studio Pro: ₹199", style: TextStyle(fontSize: 9, color: AppColors.textDim)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
