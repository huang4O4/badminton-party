import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../util/thai_date.dart';
import '../widgets/app_chrome.dart';
import '../widgets/player_avatar.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final ranked = [...state.players]..sort((a, b) {
        final byLife = b.lifetimeGames.compareTo(a.lifetimeGames);
        if (byLife != 0) {
          return byLife;
        }
        return a.name.compareTo(b.name);
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('จำนวนเกมต่อคน', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 4),
              const Text(
                'นับทั้งก๊วนนี้และสะสม',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 8),
              for (final player in ranked.take(20))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const PlayerAvatar(size: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(player.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              'ก๊วนนี้ ${player.sessionGames} เกม',
                              style: const TextStyle(color: AppColors.muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${player.lifetimeGames}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('เกมที่ผ่านมา', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        if (state.history.isEmpty)
          const SoftCard(
            child: Text('ยังไม่มีประวัติเกม — กด «จบเกม» ในหน้าจัดคู่', style: TextStyle(color: AppColors.muted)),
          )
        else
          for (final game in state.history)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          game.mode == 'singles' ? 'เดี่ยว' : 'คู่',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.green),
                        ),
                        const SizedBox(width: 8),
                        Text('คอร์ท ${game.courtNumber}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(
                          formatThaiDateTimeShort(game.playedAt),
                          style: const TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      [
                        game.sideA.map((id) => controller.playerById(id)?.name ?? id).join(' / '),
                        'VS',
                        game.sideB.map((id) => controller.playerById(id)?.name ?? id).join(' / '),
                      ].join('  '),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
