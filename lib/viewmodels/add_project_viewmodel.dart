import 'package:flutter/material.dart';
import '../services/youtube_service.dart';
import '../services/storage_service.dart';

class AddProjectViewModel extends ChangeNotifier {
  final YoutubeService _youtubeService = YoutubeService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> addVideoProject(String url) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final project = await _youtubeService.createProjectFromVideo(url);
      await _storageService.addProject(project);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addPlaylistProject(String url) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final projects = await _youtubeService.createProjectsFromPlaylist(url);
      for (var project in projects) {
        await _storageService.addProject(project);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
