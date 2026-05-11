import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final Duration startTime;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.startTime = Duration.zero,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  InAppWebViewController? _webViewController;

  String _getVideoId(String url) {
    try {
      RegExp regExp = RegExp(
        r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
        caseSensitive: false,
        multiLine: false,
      );
      Match? match = regExp.firstMatch(url);
      if (match?.group(7) != null && match!.group(7)!.length == 11) {
        return match.group(7)!;
      }
    } catch (e) {
      debugPrint('Error parsing video ID: $e');
    }
    return '';
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startTime != widget.startTime || oldWidget.videoUrl != widget.videoUrl) {
      _loadVideo();
    }
  }

  void _loadVideo() {
    final videoId = _getVideoId(widget.videoUrl);
    if (videoId.isEmpty || _webViewController == null) return;

    final startSeconds = widget.startTime.inSeconds;
    final embedUrl = WebUri('https://www.youtube.com/embed/$videoId?start=$startSeconds&autoplay=1&controls=1&rel=0');
    _webViewController!.loadUrl(urlRequest: URLRequest(url: embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _getVideoId(widget.videoUrl);
    final startSeconds = widget.startTime.inSeconds;
    
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri('https://www.youtube.com/embed/$videoId?start=$startSeconds&autoplay=1&controls=1&rel=0'),
      ),
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        useShouldOverrideUrlLoading: true,
        javaScriptEnabled: true,
        // Set a desktop User Agent to avoid mobile/device restrictions
        userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      onLoadStop: (controller, url) {
        // Force play if possible
        controller.evaluateJavascript(source: 'document.querySelector("video").play();');
      },
    );
  }
}
