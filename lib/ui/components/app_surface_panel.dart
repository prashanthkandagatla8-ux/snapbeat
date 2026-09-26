import 'package:flutter/material.dart';
import '../../theme/app_decorations.dart';

class AppSurfacePanel extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppSurfacePanel({
    super.key,
    required this.child,
    this.isDark = false,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: isDark ? AppDecorations.panelDark : AppDecorations.panelWhite,
      child: child,
    );
  }
}
