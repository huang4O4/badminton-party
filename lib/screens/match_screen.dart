import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/matcher.dart';
import '../models/player.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_chrome.dart';
import '../widgets/player_avatar.dart';

class MatchScreen extends ConsumerWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final deal = state.deal;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.chip,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                _ModeTab(
                  label: 'เดี่ยว',
                  icon: Icons.person_outline,
                  selected: state.mode == MatchMode.singles,
                  onTap: () => controller.setMode(MatchMode.singles),
                ),
                _ModeTab(
                  label: 'ทีม (คู่)',
                  icon: Icons.groups_outlined,
                  selected: state.mode == MatchMode.doubles,
                  onTap: () => controller.setMode(MatchMode.doubles),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: deal == null
              ? _EmptyMatch(onDeal: controller.reshuffle)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    for (final court in deal.courts)
                      _CourtCard(
                        court: court,
                        resolve: controller.playerById,
                        onFinish: () => controller.finishCourt(court.courtNumber),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 18, color: AppColors.muted),
                        const SizedBox(width: 6),
                        Text(
                          'รายชื่อรอ (${deal.waitingIds.length} คน)',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SoftCard(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          for (final id in deal.waitingIds)
                            ListTile(
                              dense: true,
                              leading: const PlayerAvatar(size: 34),
                              title: Text(controller.playerById(id)?.name ?? id),
                              trailing: controller.playerById(id)?.skill == null
                                  ? null
                                  : SkillChip(label: controller.playerById(id)!.skill!.label),
                            ),
                          if (deal.waitingIds.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('ไม่มีคนรอ', style: TextStyle(color: AppColors.muted)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: OutlinedButton.icon(
            onPressed: state.players.isEmpty ? null : controller.reshuffle,
            icon: const Icon(Icons.casino_outlined),
            label: const Text('สุ่มใหม่', style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.green,
              side: const BorderSide(color: AppColors.green, width: 1.4),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyMatch extends StatelessWidget {
  const _EmptyMatch({required this.onDeal});
  final VoidCallback onDeal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ยังไม่ได้จัดคู่', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            const Text(
              'กดสุ่มใหม่เพื่อจัดผู้เล่นลงคอร์ท โดยให้คนที่ตีน้อยที่สุดขึ้นก่อน',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'เริ่มจัดคู่', icon: Icons.groups, onPressed: onDeal),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: selected
                ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? AppColors.green : AppColors.muted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.ink : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  const _CourtCard({
    required this.court,
    required this.resolve,
    required this.onFinish,
  });

  final CourtMatch court;
  final Player? Function(String id) resolve;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.sports_tennis, color: AppColors.green, size: 18),
                const SizedBox(width: 6),
                Text('คอร์ท ${court.courtNumber}', style: const TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                TextButton(
                  onPressed: court.playerIds.isEmpty ? null : onFinish,
                  child: const Text('จบเกม'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _Side(ids: court.sideA, resolve: resolve, alignEnd: false)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(child: _Side(ids: court.sideB, resolve: resolve, alignEnd: true)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({
    required this.ids,
    required this.resolve,
    required this.alignEnd,
  });

  final List<String> ids;
  final Player? Function(String id) resolve;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        for (final id in ids)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!alignEnd) ...[
                  const PlayerAvatar(size: 36),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    resolve(id)?.name ?? id,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (alignEnd) ...[
                  const SizedBox(width: 8),
                  const PlayerAvatar(size: 36),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
