import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/add_project_viewmodel.dart';
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

  Widget _buildHomeContent(BuildContext context, HomeViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome in YT Champ Learner',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.navyBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (viewModel.projects.isEmpty)
            const Text(
              'Your project list is currently empty.\nAdd a YouTube video or playlist to start learning!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            )
          else
            Text(
              'You have ${viewModel.projects.length} active projects.',
              style: const TextStyle(fontSize: 18),
            ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => _showAddProjectModal(context),
            icon: const Icon(Icons.add),
            label: const Text('Create New Project'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllProjectsContent(BuildContext context, HomeViewModel viewModel) {
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
                  builder: (context) => ProjectDetailView(project: project),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(project.thumbnailUrl, fit: BoxFit.cover),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => viewModel.deleteProject(project.id),
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
