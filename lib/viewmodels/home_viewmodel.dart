import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/storage_service.dart';

class HomeViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  List<Project> _projects = [];
  int _selectedIndex = 0;
  bool _isLoading = false;

  List<Project> get projects => _projects;
  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;

  HomeViewModel() {
    loadProjects();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();
    
    _projects = await _storageService.loadProjects();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    await _storageService.deleteProject(id);
    await loadProjects();
  }

  Future<void> updateProject(Project project) async {
    await _storageService.updateProject(project);
    await loadProjects();
  }
}
