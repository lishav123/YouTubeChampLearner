class Module {
  final String id;
  final String title;
  final Duration startTime;
  final Duration endTime;
  bool isCompleted;

  Module({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.inSeconds,
      'endTime': endTime.inSeconds,
      'isCompleted': isCompleted,
    };
  }

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      title: json['title'],
      startTime: Duration(seconds: json['startTime']),
      endTime: Duration(seconds: json['endTime']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class Project {
  final String id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final List<Module> modules;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.modules,
    required this.createdAt,
  });

  double get progress {
    if (modules.isEmpty) return 0.0;
    int completed = modules.where((m) => m.isCompleted).length;
    return completed / modules.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'modules': modules.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      modules: (json['modules'] as List).map((m) => Module.fromJson(m)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
