import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/project.dart';

class TranscriptService {
  final _yt = YoutubeExplode();

  Future<String> getTranscriptForModule(String videoUrl, Module module) async {
    try {
      final videoId = VideoId.parseVideoId(videoUrl);
      if (videoId == null) throw Exception('Invalid video URL');

      final manifest = await _yt.videos.closedCaptions.getManifest(videoId);
      if (manifest.tracks.isEmpty) throw Exception('No captions available');

      // Prefer English, fallback to first available
      final track = manifest.tracks.firstWhere(
        (t) => t.language.code == 'en',
        orElse: () => manifest.tracks.first,
      );

      final captions = await _yt.videos.closedCaptions.get(track);

      // Filter captions within module time range
      final buffer = StringBuffer();
      for (final caption in captions.captions) {
        final offset = caption.offset;
        if (offset >= module.startTime && offset <= module.endTime) {
          buffer.write('${caption.text} ');
        }
      }

      final transcript = buffer.toString().trim();
      if (transcript.isEmpty) throw Exception('No transcript in this time range');
      return transcript;
    } catch (e) {
      throw Exception('Transcript fetch failed: $e');
    }
  }

  void dispose() => _yt.close();
}