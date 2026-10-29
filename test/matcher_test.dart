import 'package:flutter_test/flutter_test.dart';
import 'package:kwan_bad/logic/matcher.dart';
import 'package:kwan_bad/models/player.dart';
import 'package:kwan_bad/models/skill_level.dart';

Player p(String id, {SkillLevel? skill, int games = 0}) {
  return Player(id: id, name: id, skill: skill, sessionGames: games);
}

void main() {
  group('dealCourts', () {
    test('fills doubles courts with 4 players and leaves leftovers waiting', () {
      final players = List.generate(10, (i) => p('p$i'));
      final deal = dealCourts(
        players: players,
        courtCount: 2,
        mode: MatchMode.doubles,
      );
      expect(deal.courts.length, 2);
      expect(deal.courts.every((c) => c.playerIds.length == 4), isTrue);
      expect(deal.waitingIds.length, 2);
      final assigned = deal.courts.expand((c) => c.playerIds).toSet();
      expect(assigned.intersection(deal.waitingIds.toSet()), isEmpty);
    });

    test('fills singles courts with 2 players', () {
      final players = List.generate(5, (i) => p('p$i'));
      final deal = dealCourts(
        players: players,
        courtCount: 2,
        mode: MatchMode.singles,
      );
      expect(deal.courts.every((c) => c.playerIds.length == 2), isTrue);
      expect(deal.waitingIds.length, 1);
    });

    test('prioritizes players who have played the fewest games', () {
      final players = [
        p('a', games: 3),
        p('b', games: 0),
        p('c', games: 2),
        p('d', games: 0),
      ];
      final deal = dealCourts(
        players: players,
        courtCount: 1,
        mode: MatchMode.singles,
      );
      expect(deal.courts.single.playerIds.toSet(), {'b', 'd'});
      expect(deal.waitingIds.toSet(), {'a', 'c'});
    });

    test('balances doubles teams by skill when levels are set', () {
      final players = [
        p('A1', skill: SkillLevel.a),
        p('A2', skill: SkillLevel.a),
        p('C1', skill: SkillLevel.c),
        p('C2', skill: SkillLevel.c),
      ];
      final deal = dealCourts(
        players: players,
        courtCount: 1,
        mode: MatchMode.doubles,
      );
      final court = deal.courts.single;
      expect(court.sideA.length, 2);
      expect(court.sideB.length, 2);
      final sideA = court.sideA.map((id) => id[0]).toSet();
      // Strongest pair should be split across teams.
      expect(sideA, {'A', 'C'});
    });
  });

  group('finishGame', () {
    test('increments games and rotates least-played waiters onto the court', () {
      final players = [
        p('on1', games: 1),
        p('on2', games: 1),
        p('w1', games: 0),
        p('w2', games: 0),
      ];
      var deal = dealCourts(
        players: players,
        courtCount: 1,
        mode: MatchMode.singles,
      );
      expect(deal.courts.single.playerIds.toSet(), {'w1', 'w2'});

      final after = finishGame(
        players: [
          p('on1', games: 1),
          p('on2', games: 1),
          p('w1', games: 0),
          p('w2', games: 0),
        ],
        deal: Deal(
          courts: [
            CourtMatch(
              courtNumber: 1,
              sideA: ['on1'],
              sideB: ['on2'],
            ),
          ],
          waitingIds: ['w1', 'w2'],
        ),
        courtNumber: 1,
        mode: MatchMode.singles,
      );

      expect(after.updatedPlayers.firstWhere((e) => e.id == 'on1').sessionGames, 2);
      expect(after.updatedPlayers.firstWhere((e) => e.id == 'on2').sessionGames, 2);
      expect(after.deal.courts.single.playerIds.toSet(), {'w1', 'w2'});
      expect(after.deal.waitingIds.toSet(), {'on1', 'on2'});
      expect(after.history.playerIds.toSet(), {'on1', 'on2'});
    });
  });
}
