import 'package:flutter/material.dart';

class AppColors {
  // Chassis & Milled Metal Canvas (Light luxury retro)
  static const Color canvasChassis = Color(0xFFE8E4DC);
  static const Color chassisBevelLight = Color(0xFFFFFFFF);
  static const Color chassisBevelDark = Color(0xFFB8B1A2);
  
  // Analog Faceplate Cream & Parchment
  static const Color panelCream = Color(0xFFF6F3EC);
  static const Color panelCreamDark = Color(0xFFECE7DD);
  static const Color panelInset = Color(0xFFDFD9CE);
  
  // Brushed Metals & Hardware
  static const Color metalBrushedLight = Color(0xFFE4E0D6);
  static const Color metalBrushedDark = Color(0xFFCBC4B6);
  static const Color metalScrewHead = Color(0xFFA8A193);
  static const Color hardwareGunmetal = Color(0xFF2E2B28);
  
  // Champagne Brass & Gold Inlay
  static const Color brassGold = Color(0xFFC8A232);
  static const Color brassHighlight = Color(0xFFF7E493);
  static const Color brassDark = Color(0xFF8E7118);
  
  // Backlit Jewels & VU Indicators
  static const Color amberJewel = Color(0xFFFF8A00);
  static const Color amberGlow = Color(0x55FF8A00);
  static const Color tubeWarmOrange = Color(0xFFFF6A00);
  static const Color vuGreen = Color(0xFF27AE60);
  static const Color vuAmber = Color(0xFFF39C12);
  static const Color vuRed = Color(0xFFD32F2F);
  
  // Engraved Typography & Foil
  static const Color textEngraved = Color(0xFF1E1B18);
  static const Color textSecondary = Color(0xFF565048);
  static const Color textMuted = Color(0xFF888177);
  static const Color textFoilGold = Color(0xFF9E7E1D);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Borders & Grooves
  static const Color grooveLight = Color(0xCCFFFFFF);
  static const Color grooveDark = Color(0x33000000);
  static const Color borderBrass = Color(0x66C8A232);
  static const Color borderSubtle = Color(0x22000000);

  // Metallic Gradients
  static const LinearGradient brushedMetalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEFECE5),
      Color(0xFFDDD7CC),
      Color(0xFFE8E4DB),
      Color(0xFFCFC8BC),
      Color(0xFFE6E2D8),
    ],
  );

  static const LinearGradient brassKnobGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF9ECA5),
      Color(0xFFD4AF37),
      Color(0xFFA3801D),
      Color(0xFFF3DD85),
    ],
  );

  static const LinearGradient chassisPlateGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0ECE4),
      Color(0xFFE4DFD5),
      Color(0xFFDDD7CB),
    ],
  );
}

