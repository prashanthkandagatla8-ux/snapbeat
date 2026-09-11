import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HardwareVentPlate extends StatelessWidget {
  final double width;
  final double height;

  const HardwareVentPlate({
    super.key,
    this.width = 44,
    this.height = 96,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/images/vent_plate.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class HardwareSpeakerGrill extends StatelessWidget {
  final double size;

  const HardwareSpeakerGrill({
    super.key,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/images/speaker_grill.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class HardwareRotaryKnob extends StatefulWidget {
  final double size;
  final double angle; // In radians
  final ValueChanged<double>? onAngleChanged;

  const HardwareRotaryKnob({
    super.key,
    this.size = 64,
    this.angle = 0.0,
    this.onAngleChanged,
  });

  @override
  State<HardwareRotaryKnob> createState() => _HardwareRotaryKnobState();
}

class _HardwareRotaryKnobState extends State<HardwareRotaryKnob> {
  late double _currentAngle;

  @override
  void initState() {
    super.initState();
    _currentAngle = widget.angle;
  }

  @override
  void didUpdateWidget(covariant HardwareRotaryKnob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.angle != widget.angle) {
      _currentAngle = widget.angle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        HapticFeedback.selectionClick();
        setState(() {
          _currentAngle += details.delta.dy * 0.03;
        });
        widget.onAngleChanged?.call(_currentAngle);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Transform.rotate(
          angle: _currentAngle,
          child: Image.asset(
            'assets/images/rotary_knob.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class HardwareToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;

  const HardwareToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 46,
    this.height = 54,
  });

  @override
  State<HardwareToggleSwitch> createState() => _HardwareToggleSwitchState();
}

class _HardwareToggleSwitchState extends State<HardwareToggleSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onChanged(!widget.value);
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(
          widget.value
              ? 'assets/images/toggle_switch_on.png'
              : 'assets/images/toggle_switch_off.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class HardwareScrew extends StatelessWidget {
  final double size;

  const HardwareScrew({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.2),
          colors: [
            Color(0xFFE8E5DD),
            Color(0xFFB0ABA0),
            Color(0xFF5A564F),
          ],
          stops: [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.7,
          height: 1.5,
          color: const Color(0xFF2B2824),
        ),
      ),
    );
  }
}
