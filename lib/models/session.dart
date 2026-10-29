class SessionConfig {
  const SessionConfig({
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    required this.courtCount,
  });

  final DateTime date;
  final int startMinutes;
  final int endMinutes;
  final int courtCount;

  SessionConfig copyWith({
    DateTime? date,
    int? startMinutes,
    int? endMinutes,
    int? courtCount,
  }) {
    return SessionConfig(
      date: date ?? this.date,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      courtCount: courtCount ?? this.courtCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
        'courtCount': courtCount,
      };

  factory SessionConfig.fromJson(Map<String, dynamic> json) {
    return SessionConfig(
      date: DateTime.parse(json['date'] as String),
      startMinutes: (json['startMinutes'] as num).toInt(),
      endMinutes: (json['endMinutes'] as num).toInt(),
      courtCount: (json['courtCount'] as num).toInt(),
    );
  }

  static SessionConfig initial() {
    final now = DateTime.now();
    return SessionConfig(
      date: DateTime(now.year, now.month, now.day),
      startMinutes: 8 * 60,
      endMinutes: 10 * 60,
      courtCount: 4,
    );
  }
}
