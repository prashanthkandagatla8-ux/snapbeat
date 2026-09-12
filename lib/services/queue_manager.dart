import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class QueueManager with ChangeNotifier {
  static const String keyJobs = "snapbeat_queue_ledger_jobs";

  static final QueueManager instance = QueueManager._internal();
  QueueManager._internal();

  final List<QueueJobItem> _jobs = [];
  final Set<String> _cancelledJobIds = {};

  List<QueueJobItem> get jobs => List.unmodifiable(_jobs);
  List<QueueJobItem> get activeJobs => _jobs.where((j) {
    final s = j.status.toLowerCase();
    return s == 'processing' || s == 'rendering' || s == 'queued';
  }).toList();

  bool isCancelled(String id) => _cancelledJobIds.contains(id);

  void markCancelled(String id) {
    _cancelledJobIds.add(id);
  }

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
    for (int i = 0; i < _jobs.length; i++) {
      final s = _jobs[i].status.toUpperCase();
      if (s == 'PROCESSING' || s == 'RENDERING' || s == 'QUEUED' || s == 'UPLOADING') {
        _jobs[i] = _jobs[i].copyWith(
          status: 'FAILED',
          error: 'Render interrupted when app was closed. Please retry.',
        );
      }
    }
    await _save();
    notifyListeners();
  }

  Future<void> addJob(QueueJobItem job) async {
    _jobs.insert(0, job);
    notifyListeners();
    await _save();
  }

  void updateJobProgress(String id, double progress) {
    if (_cancelledJobIds.contains(id)) return;
    final idx = _jobs.indexWhere((j) => j.id == id);
    if (idx != -1) {
      _jobs[idx] = _jobs[idx].copyWith(progress: progress);
      notifyListeners();
    }
  }

  Future<void> updateJob(String id, {String? status, String? videoPath, double? progress, String? error}) async {
    if (_cancelledJobIds.contains(id)) return;
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
    _cancelledJobIds.add(id);
    final matches = _jobs.where((j) => j.id == id);
    if (matches.isNotEmpty) {
      final job = matches.first;
      if (job.videoPath != null) {
        try {
          final f = File(job.videoPath!);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    }
    _jobs.removeWhere((j) => j.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> cancelJob(String id) async {
    await deleteJob(id);
  }

  Future<void> clearAll() async {
    for (final j in _jobs) {
      _cancelledJobIds.add(j.id);
      if (j.videoPath != null) {
        try {
          final f = File(j.videoPath!);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    }
    _jobs.clear();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _jobs.map((j) => jsonEncode(j.toJson())).toList();
    await prefs.setStringList(keyJobs, list);
  }
}
