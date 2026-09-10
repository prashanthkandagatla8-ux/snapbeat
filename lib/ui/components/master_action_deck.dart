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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.canvasChassis,
        border: const Border(
          top: BorderSide(color: AppColors.chassisBevelLight, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Glowing Jewel Indicator beside the button
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.amberJewel,
              boxShadow: [
                BoxShadow(
                  color: AppColors.amberJewel,
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: AppColors.amberGlow,
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                widget.onTriggerMaster();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), // Pill shape
                  gradient: AppColors.ctaButtonGradient,
                  border: Border.all(
                    color: AppColors.brassHighlight,
                    width: 1.5,
                  ),
                  boxShadow: _isPressed
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(2, 5),
                            blurRadius: 8,
                          ),
                          const BoxShadow(
                            color: Color(0x33FFD54F),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      color: AppColors.hardwareGunmetal,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CREATE REEL',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: AppColors.hardwareGunmetal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}