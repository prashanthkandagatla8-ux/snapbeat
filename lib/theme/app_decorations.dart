import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static BoxDecoration get panelWhite => BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ceramicWhiteRim, width: 1.0),
        boxShadow: AppColors.tactile3DBevel,
      );

  static BoxDecoration get panelDark => BoxDecoration(
        color: AppColors.pianoBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pianoBlackRim, width: 1.0),
        boxShadow: AppColors.darkTactile3DBevel,
      );
}
