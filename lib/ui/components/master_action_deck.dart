import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'splash_master_red_button.dart';

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
      child: Center(
        child: SplashMasterRedButton(
          size: 92,
          label: photoCount > 0
              ? "SYNC & RENDER ($photoCount SNAPS)"
              : "SELECT SNAPS TO RENDER",
          onTap: onTriggerMaster,
        ),
      ),
    );
  }
}
