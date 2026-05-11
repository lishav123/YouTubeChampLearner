import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../components/player/video_player_widget.dart';
import '../../components/lists/module_list_item.dart';
import '../../theme/app_theme.dart';

class ProjectDetailView extends StatelessWidget {
  final Project project;

  const ProjectDetailView({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectViewModel(project),
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Update home viewmodel when leaving
              context.read<HomeViewModel>().loadProjects();
              Navigator.pop(context);
            },
          ),
        ),
        body: Consumer<ProjectViewModel>(
          builder: (context, viewModel, child) {
            return Row(
              children: [
                // Video Player Section
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.black,
                          child: Center(
                            child: VideoPlayerWidget(
                              videoUrl: viewModel.project.videoUrl,
                              startTime: viewModel.currentModule.startTime,
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
                                  onPressed: () => viewModel.toggleModuleCompletion(viewModel.currentModuleIndex),
                                  icon: Icon(viewModel.isCurrentModuleCompleted ? Icons.check : Icons.done),
                                  label: Text(viewModel.isCurrentModuleCompleted ? 'Completed' : 'Mark as Done'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: viewModel.isCurrentModuleCompleted ? AppTheme.forestGreen : AppTheme.navyBlue,
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
                // Module List Sidebar
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
                              onToggleDone: () => viewModel.toggleModuleCompletion(index),
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
    );
  }
}
