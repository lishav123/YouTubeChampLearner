class UserBadge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final DateTime earnedAt;

  UserBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'emoji': emoji,
        'earnedAt': earnedAt.toIso8601String(),
      };

  factory UserBadge.fromJson(Map<String, dynamic> json) => UserBadge(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        emoji: json['emoji'],
        earnedAt: DateTime.parse(json['earnedAt']),
      );
}

class UserStats {
  int totalPoints;
  int modulesCompleted;
  int coursesCompleted;
  List<UserBadge> badges;

  UserStats({
    this.totalPoints = 0,
    this.modulesCompleted = 0,
    this.coursesCompleted = 0,
    List<UserBadge>? badges,
  }) : badges = badges ?? [];

  Map<String, dynamic> toJson() => {
        'totalPoints': totalPoints,
        'modulesCompleted': modulesCompleted,
        'coursesCompleted': coursesCompleted,
        'badges': badges.map((b) => b.toJson()).toList(),
      };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        totalPoints: json['totalPoints'] ?? 0,
        modulesCompleted: json['modulesCompleted'] ?? 0,
        coursesCompleted: json['coursesCompleted'] ?? 0,
        badges: (json['badges'] as List? ?? [])
            .map((b) => UserBadge.fromJson(b))
            .toList(),
      );
}