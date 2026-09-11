import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class QueueManager with ChangeNotifier {
  static const String keyJobs = "snapbeat_queue_ledger_jobs";

  static final QueueManager instance = QueueManager._internal();
  QueueManager._internal();

  final List<QueueJobItem> _jobs = [];
  List<QueueJobItem> get jobs => List.unmodifiable(_jobs);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(keyJobs) ?? [];
    _jobs.clear();
    for (final str in jsonList) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        _jobs.add(QueueJobItem.fromJson(map));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> addJob(QueueJobItem job) async {
    _jobs.insert(0, job);
    notifyListeners();
    await _save();
  }

  void updateJobProgress(String id, double progress) {
    final idx = _jobs.indexWhere((j) => j.id == id);
    if (idx != -1) {
      _jobs[idx] = _jobs[idx].copyWith(progress: progress);
      notifyListeners();
    }
  }

  Future<void> updateJob(String id, {String? status, String? videoPath, double? progress, String? error}) async {
    final idx = _jobs.indexWhere((j) => j.id == id);
    if (idx != -1) {
      _jobs[idx] = _jobs[idx].copyWith(
        status: status,
        videoPath: videoPath,
        progress: progress,
        error: error,
      );
      notifyListeners();
      await _save();
    }
  }

  Future<void> deleteJob(String id) async {
    _jobs.removeWhere((j) => j.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _jobs.map((j) => jsonEncode(j.toJson())).toList();
    await prefs.setStringList(keyJobs, list);
  }
}
