import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MasterActionDeck extends StatefulWidget {
  final int photoCount;
  final VoidCallback onTriggerMaster;

  const MasterActionDeck({
    super.key,
    required this.photoCount,
    required this.onTriggerMaster,
  });

  @override
  State<MasterActionDeck> createState() => _MasterActionDeckState();
}

class _MasterActionDeckState extends State<MasterActionDeck> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.canvasChassis,
        border: const Border(
          top: BorderSide(color: AppColors.chassisBevelLight, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTriggerMaster();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: AppColors.brassKnobGradient,
            border: Border.all(
              color: AppColors.brassHighlight,
              width: 1.5,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      offset: const Offset(2, 5),
                      blurRadius: 8,
                    ),
                    const BoxShadow(
                      color: Color(0x66FFB300),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing Jewel Indicator
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.amberJewel,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amberJewel,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'ENGAGE MASTER REEL',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: AppColors.hardwareGunmetal,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.hardwareGunmetal,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}