import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';

class StorageService {
  static const String _projectsKey = 'yt_champ_projects';

  Future<void> saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(projects.map((p) => p.toJson()).toList());
    await prefs.setString(_projectsKey, encodedData);
  }

  Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_projectsKey);
    if (encodedData == null) return [];

    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((p) => Project.fromJson(p)).toList();
  }

  Future<void> addProject(Project project) async {
    final projects = await loadProjects();
    projects.add(project);
    await saveProjects(projects);
  }

  Future<void> updateProject(Project project) async {
    final projects = await loadProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
      await saveProjects(projects);
    }
  }

  Future<void> deleteProject(String projectId) async {
    final projects = await loadProjects();
    projects.removeWhere((p) => p.id == projectId);
    await saveProjects(projects);
  }
}
