enum SkillLevel {
  a('A', 6),
  aMinus('A-', 5),
  bPlus('B+', 4),
  b('B', 3),
  bMinus('B-', 2),
  cPlus('C+', 1),
  c('C', 0);

  const SkillLevel(this.label, this.rank);
  final String label;
  final int rank;

  static SkillLevel? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final key = raw.trim().toUpperCase();
    for (final level in SkillLevel.values) {
      if (level.label.toUpperCase() == key) {
        return level;
      }
    }
    return null;
  }
}
