class GameRecord {
  const GameRecord({
    required this.id,
    required this.playedAt,
    required this.mode,
    required this.courtNumber,
    required this.playerIds,
    required this.sideA,
    required this.sideB,
  });

  final String id;
  final DateTime playedAt;
  final String mode;
  final int courtNumber;
  final List<String> playerIds;
  final List<String> sideA;
  final List<String> sideB;

  Map<String, dynamic> toJson() => {
        'id': id,
        'playedAt': playedAt.toIso8601String(),
        'mode': mode,
        'courtNumber': courtNumber,
        'playerIds': playerIds,
        'sideA': sideA,
        'sideB': sideB,
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'] as String,
      playedAt: DateTime.parse(json['playedAt'] as String),
      mode: json['mode'] as String,
      courtNumber: (json['courtNumber'] as num).toInt(),
      playerIds: List<String>.from(json['playerIds'] as List),
      sideA: List<String>.from(json['sideA'] as List? ?? const []),
      sideB: List<String>.from(json['sideB'] as List? ?? const []),
    );
  }
}
