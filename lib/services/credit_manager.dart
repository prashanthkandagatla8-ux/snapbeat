import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class CreditManager with ChangeNotifier {
  static const String keyCredits = "snapbeat_credits_balance";
  static const String keyWatermark = "snapbeat_watermark_removed_v4";
  static const String keyProMode = "snapbeat_pro_mode_enabled";
  static const String keyRegion = "snapbeat_active_region";
  static const String keyWelcomeGiven = "snapbeat_welcome_credits_given";
  static const String keyClosedTestingGranted = "snapbeat_closed_testing_granted_v1";

  static final CreditManager instance = CreditManager._internal();
  CreditManager._internal();

  int _credits = 50;
  bool _watermarkRemoved = false;
  bool _proModeEnabled = true;
  String _activeRegion = "IN";

  int get credits => _credits;
  bool get isWatermarkRemoved => _watermarkRemoved;
  bool get isProModeEnabled => _proModeEnabled;
  String get activeRegion => _activeRegion;
  RegionPricing get pricing => RegionPricing.regions[_activeRegion] ?? RegionPricing.regions["US"]!;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final closedTestingGranted = prefs.getBool(keyClosedTestingGranted) ?? false;
    if (!closedTestingGranted) {
      _credits = 50;
      _watermarkRemoved = false;
      _proModeEnabled = true;
      await prefs.setInt(keyCredits, 50);
      await prefs.setBool(keyWatermark, false);
      await prefs.setBool(keyProMode, true);
      await prefs.setBool(keyClosedTestingGranted, true);
      await prefs.setBool(keyWelcomeGiven, true);
    } else {
      _credits = prefs.getInt(keyCredits) ?? 50;
      _watermarkRemoved = prefs.getBool(keyWatermark) ?? false;
      _proModeEnabled = prefs.getBool(keyProMode) ?? true;
    }
    final deviceCountry = ui.PlatformDispatcher.instance.locale.countryCode ?? 'US';
    _activeRegion = prefs.getString(keyRegion) ?? deviceCountry;
  }

  Future<void> addCredits(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    _credits += amount;
    await prefs.setInt(keyCredits, _credits);
    notifyListeners();
  }

  Future<bool> deductCredit() async {
    if (_credits <= 0) return false;
    final prefs = await SharedPreferences.getInstance();
    _credits -= 1;
    await prefs.setInt(keyCredits, _credits);
    notifyListeners();
    return true;
  }

  Future<void> refundCredit() async {
    _credits += 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyCredits, _credits);
    notifyListeners();
  }

  Future<void> setWatermarkRemoved(bool removed) async {
    final prefs = await SharedPreferences.getInstance();
    _watermarkRemoved = removed;
    await prefs.setBool(keyWatermark, removed);
    notifyListeners();
  }

  Future<void> toggleWatermarkRemoved() async {
    await setWatermarkRemoved(!_watermarkRemoved);
  }

  Future<void> setProModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    _proModeEnabled = enabled;
    await prefs.setBool(keyProMode, enabled);
    notifyListeners();
  }

  Future<void> setActiveRegion(String regionCode) async {
    final prefs = await SharedPreferences.getInstance();
    _activeRegion = regionCode;
    await prefs.setString(keyRegion, regionCode);
    notifyListeners();
  }

  bool shouldWatermark(bool isInstant) {
    if (_watermarkRemoved || _proModeEnabled) return false;
    return true;
  }
}
