import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';

class StatsService {
  static const String _statsKey = 'yt_champ_user_stats';

  static const int pointsPerModule = 10;
  static const int pointsPerCourse = 50;
  static const int pointsPerQuizCorrect = 5;

  Future<UserStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_statsKey);
    if (data == null) return UserStats();
    return UserStats.fromJson(jsonDecode(data));
  }

  Future<void> saveStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  // Returns list of newly earned badges
  Future<List<UserBadge>> onModuleCompleted(UserStats stats) async {
    stats.totalPoints += pointsPerModule;
    stats.modulesCompleted += 1;

    final newBadges = <UserBadge>[];
    newBadges.addAll(_checkBadges(stats));

    await saveStats(stats);
    return newBadges;
  }

  Future<List<UserBadge>> onCourseCompleted(UserStats stats) async {
    stats.totalPoints += pointsPerCourse;
    stats.coursesCompleted += 1;

    final newBadges = <UserBadge>[];
    newBadges.addAll(_checkBadges(stats));

    await saveStats(stats);
    return newBadges;
  }

  Future<List<UserBadge>> onQuizAnswered(UserStats stats, int correctAnswers) async {
    stats.totalPoints += pointsPerQuizCorrect * correctAnswers;
    final newBadges = _checkBadges(stats);
    await saveStats(stats);
    return newBadges;
  }

  List<UserBadge> _checkBadges(UserStats stats) {
    final newBadges = <UserBadge>[];
    final existingIds = stats.badges.map((b) => b.id).toSet();

    final allBadges = [
      // Module badges
      if (stats.modulesCompleted >= 1 && !existingIds.contains('first_module'))
        UserBadge(
          id: 'first_module',
          title: 'First Step',
          description: 'Completed your first module',
          emoji: '🎯',
          earnedAt: DateTime.now(),
        ),
      if (stats.modulesCompleted >= 10 && !existingIds.contains('ten_modules'))
        UserBadge(
          id: 'ten_modules',
          title: 'On a Roll',
          description: 'Completed 10 modules',
          emoji: '🔥',
          earnedAt: DateTime.now(),
        ),
      if (stats.modulesCompleted >= 50 && !existingIds.contains('fifty_modules'))
        UserBadge(
          id: 'fifty_modules',
          title: 'Module Master',
          description: 'Completed 50 modules',
          emoji: '⚡',
          earnedAt: DateTime.now(),
        ),
      // Course badges
      if (stats.coursesCompleted >= 1 && !existingIds.contains('first_course'))
        UserBadge(
          id: 'first_course',
          title: 'Course Crusher',
          description: 'Finished your first full course',
          emoji: '🏆',
          earnedAt: DateTime.now(),
        ),
      if (stats.coursesCompleted >= 5 && !existingIds.contains('five_courses'))
        UserBadge(
          id: 'five_courses',
          title: 'Knowledge Seeker',
          description: 'Finished 5 full courses',
          emoji: '🎓',
          earnedAt: DateTime.now(),
        ),
      // Points badges
      if (stats.totalPoints >= 100 && !existingIds.contains('100_points'))
        UserBadge(
          id: '100_points',
          title: 'Century',
          description: 'Earned 100 points',
          emoji: '💯',
          earnedAt: DateTime.now(),
        ),
      if (stats.totalPoints >= 500 && !existingIds.contains('500_points'))
        UserBadge(
          id: '500_points',
          title: 'High Scorer',
          description: 'Earned 500 points',
          emoji: '🌟',
          earnedAt: DateTime.now(),
        ),
      if (stats.totalPoints >= 1000 && !existingIds.contains('1000_points'))
        UserBadge(
          id: '1000_points',
          title: 'Legend',
          description: 'Earned 1000 points',
          emoji: '👑',
          earnedAt: DateTime.now(),
        ),
    ];

    for (final badge in allBadges) {
      stats.badges.add(badge);
      newBadges.add(badge);
    }

    return newBadges;
  }
}