import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'splash_master_red_button.dart';
import 'hardware_accents.dart';

class MasterActionDeck extends StatelessWidget {
  final int photoCount;
  final VoidCallback onTriggerMaster;

  const MasterActionDeck({
    super.key,
    required this.photoCount,
    required this.onTriggerMaster,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.metalBase,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2DDD5), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, -5),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Console Row: [Left Vent Slots] [3D Splash Red Button] [Right Speaker Grill]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: 5 stamped horizontal vents
              const HardwareVentPlate(width: 36, height: 80),

              // Center: 3D Master Red Button from splash screen
              SplashMasterRedButton(
                size: 92,
                label: photoCount > 0
                    ? "SYNC & RENDER ($photoCount SNAPS)"
                    : "SELECT SNAPS TO RENDER",
                onTap: onTriggerMaster,
              ),

              // Right: 9-hole acoustic countersunk speaker grill
              const HardwareSpeakerGrill(size: 50),
            ],
          ),
          const SizedBox(height: 8),

          // Stamped bottom label from splash screen
          const Text(
            'AI POWERED VIDEO CREATOR',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
              color: AppColors.textSecondary,
              shadows: [
                Shadow(
                  color: Color(0x99FFFFFF),
                  offset: Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
