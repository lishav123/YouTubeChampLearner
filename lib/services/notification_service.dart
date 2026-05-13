import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import '../models/project.dart';

class NotificationService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await localNotifier.setup(appName: 'YT Champ Learner');
    _initialized = true;
  }

  static Future<void> showReminderNotification(Project project) async {
    await init();
    final completed = project.modules.where((m) => m.isCompleted).length;
    final total = project.modules.length;

    final notification = LocalNotification(
      title: '📚 Continue Learning!',
      body:
          '"${project.title}" — $completed/$total modules done. Keep going!',
    );
    await notification.show();
  }

  static Future<void> showBadgeNotification(String badgeEmoji, String badgeTitle) async {
    await init();
    final notification = LocalNotification(
      title: '$badgeEmoji Badge Earned!',
      body: 'You earned the "$badgeTitle" badge. Keep it up!',
    );
    await notification.show();
  }

  static Future<void> checkAndRemindIncompleteProjects(
      List<Project> projects) async {
    final incomplete = projects.where((p) => p.progress < 1.0 && p.progress > 0).toList();
    if (incomplete.isEmpty) return;

    // Remind about the most progressed incomplete project
    incomplete.sort((a, b) => b.progress.compareTo(a.progress));
    await showReminderNotification(incomplete.first);
  }
}