import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/add_project_viewmodel.dart';
import '../../theme/app_theme.dart';

class AddProjectModal extends StatefulWidget {
  const AddProjectModal({super.key});

  @override
  State<AddProjectModal> createState() => _AddProjectModalState();
}

class _AddProjectModalState extends State<AddProjectModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _handleSubmit(AddProjectViewModel viewModel) async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    bool success;
    if (_tabController.index == 0) {
      success = await viewModel.addVideoProject(url);
    } else {
      success = await viewModel.addPlaylistProject(url);
    }

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddProjectViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create New Project',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.navyBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.navyBlue,
                indicatorColor: AppTheme.navyBlue,
                tabs: const [
                  Tab(icon: Icon(Icons.video_library), text: 'Video'),
                  Tab(icon: Icon(Icons.playlist_play), text: 'Playlist'),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'YouTube URL',
                  hintText: 'Paste link here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.link),
                  errorText: viewModel.errorMessage,
                ),
                onChanged: (_) => viewModel.clearError(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : () => _handleSubmit(viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Project', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
