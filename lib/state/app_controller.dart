import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/app_repository.dart';
import '../logic/line_parser.dart';
import '../logic/matcher.dart';
import '../models/app_state.dart';
import '../models/player.dart';
import '../models/session.dart';
import '../models/skill_level.dart';

final appRepositoryProvider = Provider<AppRepository>((ref) => AppRepository());

final appControllerProvider =
    StateNotifierProvider<AppController, AppState>((ref) {
  return AppController(ref.watch(appRepositoryProvider));
});

class AppController extends StateNotifier<AppState> {
  AppController(this._repository) : super(AppState.empty()) {
    hydrate();
  }

  final AppRepository _repository;
  final _uuid = const Uuid();

  Future<void> hydrate() async {
    final loaded = await _repository.load();
    state = (loaded ?? _seeded()).copyWith(hydrated: true);
    await _persist();
  }

  AppState _seeded() {
    const names = <(String, SkillLevel?)>[
      ('ต้น', SkillLevel.a),
      ('บอล', SkillLevel.bPlus),
      ('มิ้นท์', SkillLevel.bPlus),
      ('โอ๋', SkillLevel.b),
      ('แพรว', SkillLevel.aMinus),
      ('ดรีม', SkillLevel.aMinus),
      ('นัท', SkillLevel.b),
      ('เมลล์', SkillLevel.cPlus),
      ('กานต์', SkillLevel.bPlus),
      ('แพร', SkillLevel.bPlus),
      ('เดียร์', SkillLevel.b),
      ('ซู', SkillLevel.cPlus),
      ('แนท', SkillLevel.b),
      ('ฟอง', SkillLevel.c),
      ('อมร', SkillLevel.bMinus),
      ('เจ', SkillLevel.b),
      ('เก่ง', SkillLevel.aMinus),
      ('เบนซ์', SkillLevel.bPlus),
    ];
    final players = [
      for (final entry in names)
        Player(id: _uuid.v4(), name: entry.$1, skill: entry.$2),
    ];
    return AppState.empty().copyWith(
      players: players,
      session: SessionConfig.initial(),
    );
  }

  Future<void> _persist() async {
    if (!state.hydrated) {
      return;
    }
    await _repository.save(state);
  }

  Future<void> updateSession(SessionConfig session) async {
    state = state.copyWith(session: session);
    if (state.deal != null) {
      reshuffle();
      return;
    }
    await _persist();
  }

  Future<void> addPlayer(String name, {SkillLevel? skill}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    state = state.copyWith(
      players: [
        ...state.players,
        Player(id: _uuid.v4(), name: trimmed, skill: skill),
      ],
    );
    await _persist();
  }

  Future<void> editPlayer(String id, {required String name, SkillLevel? skill}) async {
    state = state.copyWith(
      players: [
        for (final player in state.players)
          if (player.id == id)
            player.copyWith(name: name.trim(), skill: skill, clearSkill: skill == null)
          else
            player,
      ],
    );
    await _persist();
  }

  Future<void> deletePlayer(String id) async {
    state = state.copyWith(
      players: state.players.where((p) => p.id != id).toList(),
      deal: state.deal == null
          ? null
          : Deal(
              courts: [
                for (final court in state.deal!.courts)
                  CourtMatch(
                    courtNumber: court.courtNumber,
                    sideA: court.sideA.where((pid) => pid != id).toList(),
                    sideB: court.sideB.where((pid) => pid != id).toList(),
                  ),
              ],
              waitingIds: state.deal!.waitingIds.where((pid) => pid != id).toList(),
            ),
    );
    await _persist();
  }

  LineParseResult previewImport(String text) {
    return parseLineSignup(
      text,
      existingNames: state.players.map((p) => p.name),
    );
  }

  Future<void> importNames(Iterable<String> names) async {
    final existing = {for (final p in state.players) p.name.trim().toLowerCase()};
    final additions = <Player>[];
    for (final name in names) {
      final trimmed = name.trim();
      if (trimmed.isEmpty || existing.contains(trimmed.toLowerCase())) {
        continue;
      }
      existing.add(trimmed.toLowerCase());
      additions.add(Player(id: _uuid.v4(), name: trimmed));
    }
    if (additions.isEmpty) {
      return;
    }
    state = state.copyWith(players: [...state.players, ...additions]);
    await _persist();
  }

  Future<void> setMode(MatchMode mode) async {
    state = state.copyWith(mode: mode);
    if (state.deal != null) {
      reshuffle();
      return;
    }
    await _persist();
  }

  Future<void> reshuffle() async {
    if (state.players.isEmpty) {
      state = state.copyWith(clearDeal: true);
      await _persist();
      return;
    }
    state = state.copyWith(
      deal: dealCourts(
        players: state.players,
        courtCount: state.session.courtCount,
        mode: state.mode,
        seed: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await _persist();
  }

  Future<void> finishCourt(int courtNumber) async {
    final deal = state.deal;
    if (deal == null) {
      return;
    }
    final result = finishGame(
      players: state.players,
      deal: deal,
      courtNumber: courtNumber,
      mode: state.mode,
      historyId: _uuid.v4(),
    );
    state = state.copyWith(
      players: result.updatedPlayers,
      deal: result.deal,
      history: [result.history, ...state.history],
    );
    await _persist();
  }

  Player? playerById(String id) {
    for (final player in state.players) {
      if (player.id == id) {
        return player;
      }
    }
    return null;
  }
}
