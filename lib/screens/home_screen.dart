import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../util/thai_date.dart';
import '../widgets/app_chrome.dart';
import '../widgets/shuttlecock_icon.dart';
import 'import_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.onStartMatch});

  final VoidCallback? onStartMatch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final session = state.session;
    final count = state.players.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: AppColors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(context, ref),
                      child: Text(
                        formatThaiDate(session.date),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ),
                  _CourtBadge(count: session.courtCount, onTap: () => _editCourts(context, ref)),
                ],
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _pickTimes(context, ref),
                child: Text(
                  'เวลา ${formatClock(session.startMinutes)} – ${formatClock(session.endMinutes)} น.',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 210,
                  height: 210,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CustomPaint(painter: _CourtRingPainter()),
                      ),
                      const Positioned(top: 10, child: ShuttlecockIcon(size: 22, color: Colors.white)),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green,
                              height: 1,
                            ),
                          ),
                          const Text(
                            'คน',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'ผู้ตีทั้งหมด',
                  style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SoftCard(
          onTap: () => _editCourts(context, ref),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6EE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.grid_view_rounded, color: AppColors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'คอร์ท ${session.courtCount} แห่ง',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'แตะเพื่อแก้ไขจำนวนคอร์ท',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SoftCard(
          onTap: () => Navigator.of(context).push(ImportScreen.route()),
          child: const Row(
            children: [
              Icon(Icons.group_add_outlined, color: AppColors.green),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('นำเข้าจาก LINE', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('วางข้อความจากแชท', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SoftCard(
          onTap: onStartMatch,
          child: const Row(
            children: [
              Icon(Icons.groups_outlined, color: AppColors.green),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('เริ่มจัดคู่ / คู่', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('สุ่มคอร์ทและคิวรอ', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final session = ref.read(appControllerProvider).session;
    final picked = await showDatePicker(
      context: context,
      initialDate: session.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked == null) {
      return;
    }
    await ref.read(appControllerProvider.notifier).updateSession(session.copyWith(date: picked));
  }

  Future<void> _pickTimes(BuildContext context, WidgetRef ref) async {
    final session = ref.read(appControllerProvider).session;
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: session.startMinutes ~/ 60, minute: session.startMinutes % 60),
      helpText: 'เวลาเริ่ม',
    );
    if (start == null || !context.mounted) {
      return;
    }
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: session.endMinutes ~/ 60, minute: session.endMinutes % 60),
      helpText: 'เวลาเลิก',
    );
    if (end == null) {
      return;
    }
    await ref.read(appControllerProvider.notifier).updateSession(
          session.copyWith(
            startMinutes: start.hour * 60 + start.minute,
            endMinutes: end.hour * 60 + end.minute,
          ),
        );
  }

  Future<void> _editCourts(BuildContext context, WidgetRef ref) async {
    final session = ref.read(appControllerProvider).session;
    var value = session.courtCount;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('จำนวนคอร์ท', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: value > 1 ? () => setModal(() => value--) : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text('$value', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
                      ),
                      IconButton.filledTonal(
                        onPressed: value < 12 ? () => setModal(() => value++) : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'บันทึก',
                    icon: Icons.check,
                    onPressed: () {
                      ref.read(appControllerProvider.notifier).updateSession(session.copyWith(courtCount: value));
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CourtBadge extends StatelessWidget {
  const _CourtBadge({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.grid_view_rounded, size: 14, color: AppColors.muted),
            const SizedBox(width: 4),
            Text('คอร์ท $count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _CourtRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final fill = Paint()..color = const Color(0xFFF3FBF6);
    canvas.drawCircle(center, radius, fill);

    final ring = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    canvas.drawCircle(center, radius - 10, ring);

    final inner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 28, inner);

    final tick = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 2;
    for (var i = 0; i < 12; i++) {
      final a = i * 30 * math.pi / 180;
      final o = Offset(
        center.dx + (radius - 18) * math.cos(a),
        center.dy + (radius - 18) * math.sin(a),
      );
      canvas.drawCircle(o, 1.4, tick..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
