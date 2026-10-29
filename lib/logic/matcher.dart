import '../models/history.dart';
import '../models/player.dart';
import '../models/skill_level.dart';

enum MatchMode { singles, doubles }

class CourtMatch {
  const CourtMatch({
    required this.courtNumber,
    required this.sideA,
    required this.sideB,
  });

  final int courtNumber;
  final List<String> sideA;
  final List<String> sideB;

  List<String> get playerIds => [...sideA, ...sideB];

  Map<String, dynamic> toJson() => {
        'courtNumber': courtNumber,
        'sideA': sideA,
        'sideB': sideB,
      };

  factory CourtMatch.fromJson(Map<String, dynamic> json) {
    return CourtMatch(
      courtNumber: (json['courtNumber'] as num).toInt(),
      sideA: List<String>.from(json['sideA'] as List),
      sideB: List<String>.from(json['sideB'] as List),
    );
  }
}

class Deal {
  const Deal({
    required this.courts,
    required this.waitingIds,
  });

  final List<CourtMatch> courts;
  final List<String> waitingIds;

  Map<String, dynamic> toJson() => {
        'courts': courts.map((c) => c.toJson()).toList(),
        'waitingIds': waitingIds,
      };

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      courts: (json['courts'] as List)
          .map((e) => CourtMatch.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      waitingIds: List<String>.from(json['waitingIds'] as List),
    );
  }
}

class FinishResult {
  const FinishResult({
    required this.deal,
    required this.updatedPlayers,
    required this.history,
  });

  final Deal deal;
  final List<Player> updatedPlayers;
  final GameRecord history;
}

int playersPerCourt(MatchMode mode) => mode == MatchMode.singles ? 2 : 4;

Deal dealCourts({
  required List<Player> players,
  required int courtCount,
  required MatchMode mode,
  int? seed,
}) {
  final ordered = _byFairness(players, seed: seed);
  final capacity = playersPerCourt(mode);
  final courts = <CourtMatch>[];
  var index = 0;
  for (var court = 1; court <= courtCount; court++) {
    if (index + capacity > ordered.length) {
      break;
    }
    final group = ordered.sublist(index, index + capacity);
    index += capacity;
    courts.add(_balanceCourt(court, group, mode));
  }
  return Deal(
    courts: courts,
    waitingIds: ordered.skip(index).map((p) => p.id).toList(),
  );
}

FinishResult finishGame({
  required List<Player> players,
  required Deal deal,
  required int courtNumber,
  required MatchMode mode,
  DateTime? playedAt,
  String? historyId,
}) {
  final court = deal.courts.firstWhere((c) => c.courtNumber == courtNumber);
  final finishedIds = court.playerIds;
  final updated = players
      .map((player) {
        if (!finishedIds.contains(player.id)) {
          return player;
        }
        return player.copyWith(
          sessionGames: player.sessionGames + 1,
          lifetimeGames: player.lifetimeGames + 1,
        );
      })
      .toList();

  final remainingCourts =
      deal.courts.where((c) => c.courtNumber != courtNumber).toList();
  final busy = remainingCourts.expand((c) => c.playerIds).toSet();
  final pool = updated.where((p) => !busy.contains(p.id)).toList();
  final next = dealCourts(
    players: pool,
    courtCount: 1,
    mode: mode,
  );
  final replacement = next.courts.isEmpty
      ? CourtMatch(courtNumber: courtNumber, sideA: const [], sideB: const [])
      : CourtMatch(
          courtNumber: courtNumber,
          sideA: next.courts.first.sideA,
          sideB: next.courts.first.sideB,
        );
  final newCourts = [...remainingCourts, replacement]
    ..sort((a, b) => a.courtNumber.compareTo(b.courtNumber));

  return FinishResult(
    deal: Deal(courts: newCourts, waitingIds: next.waitingIds),
    updatedPlayers: updated,
    history: GameRecord(
      id: historyId ?? 'game-${playedAt?.millisecondsSinceEpoch ?? courtNumber}',
      playedAt: playedAt ?? DateTime.now(),
      mode: mode.name,
      courtNumber: courtNumber,
      playerIds: finishedIds,
      sideA: court.sideA,
      sideB: court.sideB,
    ),
  );
}

List<Player> _byFairness(List<Player> players, {int? seed}) {
  final copy = [...players];
  copy.sort((a, b) {
    final games = a.sessionGames.compareTo(b.sessionGames);
    if (games != 0) {
      return games;
    }
    return a.id.compareTo(b.id);
  });
  if (seed == null) {
    return copy;
  }
  // Stable shuffle within equal sessionGames buckets.
  final buckets = <int, List<Player>>{};
  for (final player in copy) {
    buckets.putIfAbsent(player.sessionGames, () => []).add(player);
  }
  final result = <Player>[];
  var salt = seed;
  for (final key in buckets.keys.toList()..sort()) {
    final bucket = buckets[key]!;
    for (var i = bucket.length - 1; i > 0; i--) {
      salt = (salt * 1103515245 + 12345) & 0x7fffffff;
      final j = salt % (i + 1);
      final tmp = bucket[i];
      bucket[i] = bucket[j];
      bucket[j] = tmp;
    }
    result.addAll(bucket);
  }
  return result;
}

CourtMatch _balanceCourt(int courtNumber, List<Player> group, MatchMode mode) {
  if (mode == MatchMode.singles) {
    return CourtMatch(
      courtNumber: courtNumber,
      sideA: [group[0].id],
      sideB: [group[1].id],
    );
  }
  final ranked = [...group]..sort((a, b) => _rank(b).compareTo(_rank(a)));
  if (ranked.length < 4) {
    final ids = ranked.map((p) => p.id).toList();
    return CourtMatch(
      courtNumber: courtNumber,
      sideA: ids.take((ids.length / 2).ceil()).toList(),
      sideB: ids.skip((ids.length / 2).ceil()).toList(),
    );
  }
  return CourtMatch(
    courtNumber: courtNumber,
    sideA: [ranked[0].id, ranked[3].id],
    sideB: [ranked[1].id, ranked[2].id],
  );
}

int _rank(Player player) => player.skill?.rank ?? SkillLevel.b.rank;
