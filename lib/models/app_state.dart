import '../logic/matcher.dart';
import 'history.dart';
import 'player.dart';
import 'session.dart';

class AppState {
  const AppState({
    required this.players,
    required this.session,
    required this.mode,
    required this.deal,
    required this.history,
    required this.hydrated,
  });

  final List<Player> players;
  final SessionConfig session;
  final MatchMode mode;
  final Deal? deal;
  final List<GameRecord> history;
  final bool hydrated;

  static AppState empty() => AppState(
        players: const [],
        session: SessionConfig.initial(),
        mode: MatchMode.doubles,
        deal: null,
        history: const [],
        hydrated: false,
      );

  AppState copyWith({
    List<Player>? players,
    SessionConfig? session,
    MatchMode? mode,
    Deal? deal,
    bool clearDeal = false,
    List<GameRecord>? history,
    bool? hydrated,
  }) {
    return AppState(
      players: players ?? this.players,
      session: session ?? this.session,
      mode: mode ?? this.mode,
      deal: clearDeal ? null : (deal ?? this.deal),
      history: history ?? this.history,
      hydrated: hydrated ?? this.hydrated,
    );
  }

  Map<String, dynamic> toJson() => {
        'players': players.map((p) => p.toJson()).toList(),
        'session': session.toJson(),
        'mode': mode.name,
        'deal': deal?.toJson(),
        'history': history.map((h) => h.toJson()).toList(),
      };

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      players: (json['players'] as List? ?? const [])
          .map((e) => Player.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      session: json['session'] == null
          ? SessionConfig.initial()
          : SessionConfig.fromJson(Map<String, dynamic>.from(json['session'] as Map)),
      mode: MatchMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => MatchMode.doubles,
      ),
      deal: json['deal'] == null
          ? null
          : Deal.fromJson(Map<String, dynamic>.from(json['deal'] as Map)),
      history: (json['history'] as List? ?? const [])
          .map((e) => GameRecord.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      hydrated: true,
    );
  }
}
