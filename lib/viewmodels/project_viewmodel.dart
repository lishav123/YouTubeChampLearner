import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/storage_service.dart';

class ProjectViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final Project _project;
  int _currentModuleIndex = 0;

  ProjectViewModel(this._project);

  Project get project => _project;
  int get currentModuleIndex => _currentModuleIndex;
  Module get currentModule => _project.modules[_currentModuleIndex];

  void setCurrentModule(int index) {
    _currentModuleIndex = index;
    notifyListeners();
  }

  Future<void> toggleModuleCompletion(int index) async {
    _project.modules[index].isCompleted = !_project.modules[index].isCompleted;
    await _storageService.updateProject(_project);
    notifyListeners();
  }

  bool get isCurrentModuleCompleted => _project.modules[_currentModuleIndex].isCompleted;
}
