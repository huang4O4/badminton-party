import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player.dart';
import '../models/skill_level.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/player_avatar.dart';

class PlayersScreen extends ConsumerStatefulWidget {
  const PlayersScreen({super.key});

  @override
  ConsumerState<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends ConsumerState<PlayersScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(appControllerProvider).players;
    final query = _search.text.trim().toLowerCase();
    final visible = query.isEmpty
        ? players
        : players.where((p) => p.name.toLowerCase().contains(query)).toList();

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'ค้นหาชื่อผู้เล่น...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                  filled: true,
                  fillColor: AppColors.chip,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 88),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
                itemBuilder: (context, index) {
                  final player = visible[index];
                  return ListTile(
                    leading: const PlayerAvatar(),
                    title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: player.skill == null
                        ? const Text('ยังไม่ระบุระดับ', style: TextStyle(color: AppColors.muted, fontSize: 12))
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (player.skill != null) SkillChip(label: player.skill!.label),
                        IconButton(
                          tooltip: 'แก้ไข',
                          onPressed: () => _edit(player),
                          icon: const Icon(Icons.edit_outlined, color: AppColors.muted),
                        ),
                        IconButton(
                          tooltip: 'ลบ',
                          onPressed: () => _confirmDelete(player),
                          icon: const Icon(Icons.delete_outline, color: AppColors.muted),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            onPressed: () => _edit(null),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _edit(Player? player) async {
    final name = TextEditingController(text: player?.name ?? '');
    SkillLevel? skill = player?.skill;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(player == null ? 'เพิ่มผู้เล่น' : 'แก้ไขชื่อผู้เล่น'),
          content: StatefulBuilder(
            builder: (context, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'ชื่อ'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<SkillLevel?>(
                    initialValue: skill,
                    decoration: const InputDecoration(labelText: 'ระดับฝีมือ (ไม่บังคับ)'),
                    items: [
                      const DropdownMenuItem<SkillLevel?>(value: null, child: Text('ไม่ระบุ')),
                      for (final level in SkillLevel.values)
                        DropdownMenuItem(value: level, child: Text(level.label)),
                    ],
                    onChanged: (value) => setModal(() => skill = value),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('บันทึก')),
          ],
        );
      },
    );
    if (saved != true || !mounted) {
      name.dispose();
      return;
    }
    final trimmed = name.text.trim();
    name.dispose();
    if (trimmed.isEmpty) {
      return;
    }
    final controller = ref.read(appControllerProvider.notifier);
    if (player == null) {
      await controller.addPlayer(trimmed, skill: skill);
    } else {
      await controller.editPlayer(player.id, name: trimmed, skill: skill);
    }
  }

  Future<void> _confirmDelete(Player player) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบผู้เล่น?'),
        content: Text('ต้องการลบ «${player.name}» ออกจากรายชื่อหรือไม่'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(appControllerProvider.notifier).deletePlayer(player.id);
    }
  }
}
