import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class QueueManager {
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
  }

  Future<void> addJob(QueueJobItem job) async {
    _jobs.insert(0, job);
    await _save();
  }

  Future<void> updateJob(String id, {String? status, String? videoPath}) async {
    final idx = _jobs.indexWhere((j) => j.id == id);
    if (idx != -1) {
      final old = _jobs[idx];
      _jobs[idx] = QueueJobItem(
        id: old.id,
        templateName: old.templateName,
        status: status ?? old.status,
        videoPath: videoPath ?? old.videoPath,
        createdAt: old.createdAt,
        quality: old.quality,
      );
      await _save();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _jobs.map((j) => jsonEncode(j.toJson())).toList();
    await prefs.setStringList(keyJobs, list);
  }
}
