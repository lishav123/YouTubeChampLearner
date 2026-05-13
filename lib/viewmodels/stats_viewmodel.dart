import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../services/stats_service.dart';

class StatsViewModel extends ChangeNotifier {
  final StatsService _statsService = StatsService();
  UserStats _stats = UserStats();
  bool _isLoading = true;

  UserStats get stats => _stats;
  bool get isLoading => _isLoading;

  StatsViewModel() {
    loadStats();
  }

  Future<void> loadStats() async {
    _stats = await _statsService.loadStats();
    _isLoading = false;
    notifyListeners();
  }

  Future<List<UserBadge>> onModuleCompleted() async {
    final newBadges = await _statsService.onModuleCompleted(_stats);
    notifyListeners(); // this triggers StatsBar to rebuild with new points
    return newBadges;
  }

  Future<List<UserBadge>> onCourseCompleted() async {
    final newBadges = await _statsService.onCourseCompleted(_stats);
    notifyListeners();
    return newBadges;
  }

  Future<List<UserBadge>> onQuizAnswered(int correctAnswers) async {
    final newBadges = await _statsService.onQuizAnswered(_stats, correctAnswers);
    notifyListeners();
    return newBadges;
  }
}