import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/add_project_viewmodel.dart';
import '../../viewmodels/stats_viewmodel.dart';
import '../../models/user_stats.dart';
import '../../components/navigation/custom_navigation_rail.dart';
import '../../components/modals/add_project_modal.dart';
import '../../theme/app_theme.dart';
import '../project/project_detail_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _showAddProjectModal(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => AddProjectViewModel(),
        child: const AddProjectModal(),
      ),
    );

    if (result == true && context.mounted) {
      context.read<HomeViewModel>().loadProjects();
    }
  }

  Widget _buildStatsSection(BuildContext context) {
    return Consumer<StatsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) return const SizedBox.shrink();
        final stats = vm.stats;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.navyBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statTile('⭐', '${stats.totalPoints}', 'Points'),
                  _statTile('🏅', '${stats.badges.length}', 'Badges'),
                  _statTile('✅', '${stats.modulesCompleted}', 'Modules Done'),
                  _statTile('🎓', '${stats.coursesCompleted}', 'Courses Done'),
                ],
              ),
              if (stats.badges.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your Badges',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: stats.badges
                      .map((b) => Tooltip(
                            message: '${b.title}\n${b.description}',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white24, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(b.emoji,
                                      style:
                                          const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  Text(
                                    b.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _statTile(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Consumer<HomeViewModel>(
            builder: (context, viewModel, child) {
              return CustomNavigationRail(
                selectedIndex: viewModel.selectedIndex,
                onDestinationSelected: (index) {
                  if (index == 1) {
                    _showAddProjectModal(context);
                  } else {
                    viewModel.setSelectedIndex(index);
                  }
                },
              );
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Consumer<HomeViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.selectedIndex == 0) {
                  return _buildHomeContent(context, viewModel);
                } else {
                  return _buildAllProjectsContent(context, viewModel);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Add this widget method to HomeView
Widget _buildReminderBanner(BuildContext context, HomeViewModel viewModel) {
  final incomplete = viewModel.projects
      .where((p) => p.progress > 0 && p.progress < 1.0)
      .toList();
  if (incomplete.isEmpty) return const SizedBox.shrink();

  incomplete.sort((a, b) => b.progress.compareTo(a.progress));
  final top = incomplete.first;
  final done = top.modules.where((m) => m.isCompleted).length;
  final total = top.modules.length;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.orange.shade200),
    ),
    child: Row(
      children: [
        const Text('⏰', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Continue where you left off',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              Text(
                '"${top.title}" — $done/$total modules done',
                style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailView(project: top),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Resume'),
        ),
      ],
    ),
  );
}

  Widget _buildHomeContent(BuildContext context, HomeViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'Welcome to YT Champ Learner',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.navyBlue,
            ),
            textAlign: TextAlign.center,
          ),
          _buildReminderBanner(context, viewModel),
          const SizedBox(height: 8),
          Text(
            viewModel.projects.isEmpty
                ? 'Add a YouTube video or playlist to start learning!'
                : 'You have ${viewModel.projects.length} active project${viewModel.projects.length == 1 ? '' : 's'}.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildStatsSection(context),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddProjectModal(context),
            icon: const Icon(Icons.add),
            label: const Text('Create New Project'),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAllProjectsContent(
      BuildContext context, HomeViewModel viewModel) {
    if (viewModel.projects.isEmpty) {
      return const Center(child: Text('No projects found.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.8,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: viewModel.projects.length,
      itemBuilder: (context, index) {
        final project = viewModel.projects[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProjectDetailView(project: project),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    project.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: project.progress,
                        backgroundColor: Colors.grey[300],
                        color: AppTheme.forestGreen,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(project.progress * 100).toInt()}% Completed',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red),
                    onPressed: () =>
                        viewModel.deleteProject(project.id),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}