import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6EE),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD7EDE0)),
      ),
      child: Icon(
        Icons.person,
        color: AppColors.green,
        size: size * 0.58,
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  const SkillChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'ระดับ $label',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF5C6370),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
