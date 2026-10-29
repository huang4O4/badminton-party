import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/line_parser.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_chrome.dart';
import '../widgets/player_avatar.dart';
import '../widgets/shuttlecock_icon.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const ImportScreen());
  }

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _text = TextEditingController();
  LineParseResult? _parsed;
  final _selected = <String>{};

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _reparse() {
    final result = ref.read(appControllerProvider.notifier).previewImport(_text.text);
    setState(() {
      _parsed = result;
      _selected
        ..clear()
        ..addAll(result.newNames);
    });
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parsed;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const BrandMark(size: 30),
                  const SizedBox(width: 8),
                  const Text(
                    'นำเข้าจาก LINE',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  const Text(
                    'วางรายชื่อจาก LINE แล้วกดตรวจล่วงหน้า',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _text,
                    minLines: 4,
                    maxLines: 6,
                    onChanged: (_) => _reparse(),
                    decoration: InputDecoration(
                      hintText: '1. ต้น\n2. บอล\n3. มิ้นท์',
                      filled: true,
                      fillColor: AppColors.chip,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (parsed != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'ตรวจพบ ${parsed.names.length} คน',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    if (parsed.alreadyInRoster.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'ข้ามชื่อที่มีอยู่แล้ว ${parsed.alreadyInRoster.length} คน',
                          style: const TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 8),
                    for (final name in parsed.names)
                      _PreviewRow(
                        name: name,
                        already: parsed.alreadyInRoster.contains(name),
                        checked: _selected.contains(name),
                        onChanged: parsed.alreadyInRoster.contains(name)
                            ? null
                            : (value) {
                                setState(() {
                                  if (value == true) {
                                    _selected.add(name);
                                  } else {
                                    _selected.remove(name);
                                  }
                                });
                              },
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PrimaryButton(
                label: 'เพิ่ม ${_selected.length} คน',
                icon: Icons.group_add,
                onPressed: _selected.isEmpty
                    ? null
                    : () async {
                        await ref.read(appControllerProvider.notifier).importNames(_selected);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.name,
    required this.already,
    required this.checked,
    required this.onChanged,
  });

  final String name;
  final bool already;
  final bool checked;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Checkbox(
              value: already ? false : checked,
              onChanged: onChanged,
              activeColor: AppColors.green,
            ),
          ),
          const SizedBox(width: 8),
          const PlayerAvatar(size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              already ? '$name  (มีอยู่แล้ว)' : name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: already ? AppColors.muted : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
