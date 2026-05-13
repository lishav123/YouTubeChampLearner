import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';
import '../viewmodels/stats_viewmodel.dart';

class ProjectViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final StatsViewModel _statsViewModel;
  final Project _project;
  int _currentModuleIndex = 0;

  ProjectViewModel(this._project, this._statsViewModel);

  Project get project => _project;
  int get currentModuleIndex => _currentModuleIndex;
  Module get currentModule => _project.modules[_currentModuleIndex];
  bool get isCurrentModuleCompleted => _project.modules[_currentModuleIndex].isCompleted;
  bool get isCourseCompleted => _project.modules.every((m) => m.isCompleted);

  void setCurrentModule(int index) {
    _currentModuleIndex = index;
    notifyListeners();
  }

  Future<List<UserBadge>> toggleModuleCompletion(int index) async {
    final wasCompleted = _project.modules[index].isCompleted;
    _project.modules[index].isCompleted = !wasCompleted;
    await _storageService.updateProject(_project);

    List<UserBadge> newBadges = [];
    if (!wasCompleted) {
      newBadges = await _statsViewModel.onModuleCompleted();

      if (isCourseCompleted) {
        final courseBadges = await _statsViewModel.onCourseCompleted();
        newBadges.addAll(courseBadges);
      }
    }

    notifyListeners();
    return newBadges;
  }
}