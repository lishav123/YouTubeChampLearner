import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/stats_viewmodel.dart';
import '../../models/user_stats.dart';
import '../../theme/app_theme.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  void _showBadgesDialog(BuildContext context, List<UserBadge> badges) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🏅 Your Badges'),
        content: badges.isEmpty
            ? const Text('No badges yet. Complete modules to earn badges!')
            : SizedBox(
                width: 400,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: badges.map((badge) => _BadgeTile(badge: badge)).toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppTheme.navyBlue,
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                '${vm.stats.totalPoints} pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.military_tech, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                '${vm.stats.badges.length} badges',
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(width: 4),
              if (vm.stats.badges.isNotEmpty)
                GestureDetector(
                  onTap: () => _showBadgesDialog(context, vm.stats.badges),
                  child: const Text(
                    'View',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.amber,
                    ),
                  ),
                ),
              const Spacer(),
              const Icon(Icons.check_circle_outline, color: Colors.white70, size: 18),
              const SizedBox(width: 4),
              Text(
                '${vm.stats.modulesCompleted} modules done',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.school_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 4),
              Text(
                '${vm.stats.coursesCompleted} courses done',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final UserBadge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: badge.description,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.softGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.navyBlue.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.navyBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}