import 'skill_level.dart';

class Player {
  const Player({
    required this.id,
    required this.name,
    this.skill,
    this.sessionGames = 0,
    this.lifetimeGames = 0,
  });

  final String id;
  final String name;
  final SkillLevel? skill;
  final int sessionGames;
  final int lifetimeGames;

  Player copyWith({
    String? id,
    String? name,
    SkillLevel? skill,
    bool clearSkill = false,
    int? sessionGames,
    int? lifetimeGames,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      skill: clearSkill ? null : (skill ?? this.skill),
      sessionGames: sessionGames ?? this.sessionGames,
      lifetimeGames: lifetimeGames ?? this.lifetimeGames,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'skill': skill?.label,
        'sessionGames': sessionGames,
        'lifetimeGames': lifetimeGames,
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      skill: SkillLevel.tryParse(json['skill'] as String?),
      sessionGames: (json['sessionGames'] as num?)?.toInt() ?? 0,
      lifetimeGames: (json['lifetimeGames'] as num?)?.toInt() ?? 0,
    );
  }
}
