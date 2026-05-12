import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

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
  HttpServer? _server;
  int _serverPort = 8765;
  String _currentVideoId = '';
  int _currentStartSeconds = 0;

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

  String _buildEmbedHtml(String videoId, int startSeconds) {
    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { background: #000; width: 100vw; height: 100vh; overflow: hidden; }
  iframe { width: 100%; height: 100%; border: none; }
</style>
</head>
<body>
<iframe
  src="https://www.youtube-nocookie.com/embed/$videoId?start=$startSeconds&autoplay=1&controls=1&rel=0&playsinline=1"
  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
  allowfullscreen>
</iframe>
</body>
</html>''';
  }

  Future<void> _startServer() async {
    final handler = (shelf.Request request) {
      final html = _buildEmbedHtml(_currentVideoId, _currentStartSeconds);
      return shelf.Response.ok(
        html,
        headers: {'Content-Type': 'text/html'},
      );
    };

    try {
      _server = await shelf_io.serve(handler, '127.0.0.1', _serverPort);
    } catch (e) {
      // Port taken, try next one
      _serverPort = 8766;
      _server = await shelf_io.serve(handler, '127.0.0.1', _serverPort);
    }
    debugPrint('Local server running on port $_serverPort');
  }

  @override
  void initState() {
    super.initState();
    _currentVideoId = _getVideoId(widget.videoUrl);
    _currentStartSeconds = widget.startTime.inSeconds;
    _startServer();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startTime != widget.startTime ||
        oldWidget.videoUrl != widget.videoUrl) {
      _currentVideoId = _getVideoId(widget.videoUrl);
      _currentStartSeconds = widget.startTime.inSeconds;
      _loadVideo();
    }
  }

  void _loadVideo() {
    if (_webViewController == null) return;
    _webViewController!.loadUrl(
      urlRequest: URLRequest(
        url: WebUri('http://127.0.0.1:$_serverPort/'),
        headers: {'Referer': 'https://www.youtube-nocookie.com'},
      ),
    );
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri('http://127.0.0.1:$_serverPort/'),
        headers: {'Referer': 'https://www.youtube-nocookie.com'},
      ),
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        javaScriptEnabled: true,
        userAgent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      onLoadStop: (controller, url) {
        debugPrint('Loaded: $url');
      },
    );
  }
}