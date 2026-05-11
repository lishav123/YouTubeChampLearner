import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/project.dart';

class YoutubeService {
  final _yt = YoutubeExplode();

  Future<Project> createProjectFromVideo(String url) async {
    final videoId = VideoId.parseVideoId(url);
    if (videoId == null) throw Exception('Invalid YouTube URL');

    final video = await _yt.videos.get(videoId);
    final manifest = await _yt.videos.closedCaptions.getManifest(videoId);

    if (manifest.tracks.isEmpty) {
      throw Exception('no caption available project can\'t be created');
    }

    // Try to get timestamps from description
    List<Module> modules = _extractTimestamps(video.description, video.duration ?? Duration.zero);

    // If no timestamps found, chunk by 30 minutes if video is long
    if (modules.isEmpty) {
      modules = _chunkByDuration(video.duration ?? Duration.zero);
    }

    return Project(
      id: video.id.value,
      title: video.title,
      videoUrl: url,
      thumbnailUrl: video.thumbnails.highResUrl,
      modules: modules,
      createdAt: DateTime.now(),
    );
  }

  Future<List<Project>> createProjectsFromPlaylist(String url) async {
    final playlistId = PlaylistId.parsePlaylistId(url);
    if (playlistId == null) throw Exception('Invalid Playlist URL');

    final videos = await _yt.playlists.getVideos(playlistId).toList();

    List<Project> projects = [];
    for (var video in videos) {
      try {
        final manifest = await _yt.videos.closedCaptions.getManifest(video.id);
        if (manifest.tracks.isNotEmpty) {
          List<Module> modules = _extractTimestamps(video.description, video.duration ?? Duration.zero);
          if (modules.isEmpty) {
            modules = _chunkByDuration(video.duration ?? Duration.zero);
          }
          projects.add(Project(
            id: video.id.value,
            title: video.title,
            videoUrl: 'https://www.youtube.com/watch?v=${video.id.value}',
            thumbnailUrl: video.thumbnails.highResUrl,
            modules: modules,
            createdAt: DateTime.now(),
          ));
        }
      } catch (e) {
        // Skip videos without captions or errors
        continue;
      }
    }

    if (projects.isEmpty) {
      throw Exception('No videos with captions found in playlist');
    }

    return projects;
  }

  List<Module> _extractTimestamps(String description, Duration totalDuration) {
    final List<Module> modules = [];
    final RegExp regExp = RegExp(r'(\d{1,2}:)?\d{1,2}:\d{2}');
    final matches = regExp.allMatches(description);

    List<Duration> timestamps = [];
    List<String> titles = [];

    for (var match in matches) {
      final timeStr = match.group(0)!;
      final parts = timeStr.split(':').map(int.parse).toList();
      Duration duration;
      if (parts.length == 3) {
        duration = Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
      } else {
        duration = Duration(minutes: parts[0], seconds: parts[1]);
      }
      timestamps.add(duration);

      // Try to find title on the same line
      final lineStart = description.lastIndexOf('\n', match.start) + 1;
      final lineEnd = description.indexOf('\n', match.end);
      final line = description.substring(lineStart, lineEnd != -1 ? lineEnd : description.length);
      titles.add(line.replaceAll(timeStr, '').trim());
    }

    for (int i = 0; i < timestamps.length; i++) {
      final end = (i + 1 < timestamps.length) ? timestamps[i+1] : totalDuration;
      modules.add(Module(
        id: 'module_$i',
        title: titles[i].isEmpty ? 'Part ${i + 1}' : titles[i],
        startTime: timestamps[i],
        endTime: end,
      ));
    }

    return modules;
  }

  List<Module> _chunkByDuration(Duration totalDuration) {
    final List<Module> modules = [];
    const chunkDuration = Duration(minutes: 30);
    int count = (totalDuration.inSeconds / chunkDuration.inSeconds).ceil();

    if (totalDuration.inHours < 3 && totalDuration.inSeconds > 0) {
      // If video is short, just one module
       modules.add(Module(
        id: 'module_0',
        title: 'Full Video',
        startTime: Duration.zero,
        endTime: totalDuration,
      ));
       return modules;
    }

    for (int i = 0; i < count; i++) {
      final start = chunkDuration * i;
      var end = chunkDuration * (i + 1);
      if (end > totalDuration) end = totalDuration;

      modules.add(Module(
        id: 'module_$i',
        title: 'Part ${i + 1}',
        startTime: start,
        endTime: end,
      ));
    }
    return modules;
  }

  void dispose() {
    _yt.close();
  }
}
