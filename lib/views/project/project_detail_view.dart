import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/stats_viewmodel.dart';
import '../../components/player/video_player_widget.dart';
import '../../components/lists/module_list_item.dart';
import '../../components/stats/stats_bar.dart';
import '../../components/stats/badge_earned_toast.dart';
import '../../theme/app_theme.dart';
import '../quiz/quiz_screen.dart';

class ProjectDetailView extends StatelessWidget {
  final Project project;
  const ProjectDetailView({super.key, required this.project});

  void _onModuleToggled(BuildContext context, List newBadges) {
    for (final badge in newBadges) {
      BadgeEarnedToast.show(context, badge);
    }
  }

  void _showModuleCompleteDialog(BuildContext context, ProjectViewModel viewModel) {
  final isLast = viewModel.currentModuleIndex >= viewModel.project.modules.length - 1;
  final module = viewModel.currentModule;
  final videoUrl = viewModel.project.videoUrl;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
          SizedBox(width: 8),
          Text('Module Completed!'),
        ],
      ),
      content: Text(
        isLast
            ? 'Amazing work finishing the course! Want to review notes and take a quiz?'
            : 'Great job! Want to review notes and take a quiz before the next module?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Skip'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizScreen(
                  module: module,
                  videoUrl: videoUrl,
                ),
              ),
            );
          },
          icon: const Icon(Icons.quiz_outlined),
          label: const Text('Notes & Quiz'),
        ),
        if (!isLast)
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final newBadges = await viewModel.toggleModuleCompletion(
                  viewModel.currentModuleIndex);
              if (context.mounted) _onModuleToggled(context, newBadges);
              viewModel.setCurrentModule(viewModel.currentModuleIndex + 1);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navyBlue),
            child: const Text('Next Module'),
          ),
        if (isLast)
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final newBadges = await viewModel.toggleModuleCompletion(
                  viewModel.currentModuleIndex);
              if (context.mounted) _onModuleToggled(context, newBadges);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navyBlue),
            child: const Text('Finish'),
          ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectViewModel(project, context.read<StatsViewModel>()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.read<HomeViewModel>().loadProjects();
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            const StatsBar(),
            Expanded(
              child: Consumer<ProjectViewModel>(
                builder: (context, viewModel, child) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.black,
                                child: Center(
                                  child: VideoPlayerWidget(
                                    key: ValueKey(viewModel.currentModuleIndex),
                                    videoUrl: viewModel.project.videoUrl,
                                    startTime: viewModel.currentModule.startTime,
                                    endTime: viewModel.currentModule.endTime,
                                    onModuleComplete: () => _showModuleCompleteDialog(context, viewModel),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              color: AppTheme.offWhite,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    viewModel.currentModule.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.navyBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final newBadges = await viewModel.toggleModuleCompletion(viewModel.currentModuleIndex);
                                          if (context.mounted) _onModuleToggled(context, newBadges);
                                        },
                                        icon: Icon(viewModel.isCurrentModuleCompleted ? Icons.check : Icons.done),
                                        label: Text(viewModel.isCurrentModuleCompleted ? 'Completed' : 'Mark as Done'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: viewModel.isCurrentModuleCompleted
                                              ? AppTheme.forestGreen
                                              : AppTheme.navyBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      if (viewModel.currentModuleIndex < viewModel.project.modules.length - 1)
                                        OutlinedButton(
                                          onPressed: () => viewModel.setCurrentModule(viewModel.currentModuleIndex + 1),
                                          child: const Text('Next Module'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      SizedBox(
                        width: 350,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Learning Modules',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.navyBlue,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: viewModel.project.progress,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey[200],
                                  color: AppTheme.forestGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: viewModel.project.modules.length,
                                itemBuilder: (context, index) {
                                  return ModuleListItem(
                                    module: viewModel.project.modules[index],
                                    isSelected: viewModel.currentModuleIndex == index,
                                    onTap: () => viewModel.setCurrentModule(index),
                                    onToggleDone: () async {
                                      final newBadges = await viewModel.toggleModuleCompletion(index);
                                      if (context.mounted) _onModuleToggled(context, newBadges);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}