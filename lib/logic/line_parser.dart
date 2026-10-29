class LineParseResult {
  const LineParseResult({
    required this.names,
    required this.newNames,
    required this.alreadyInRoster,
    required this.duplicatesInPaste,
  });

  final List<String> names;
  final List<String> newNames;
  final List<String> alreadyInRoster;
  final List<String> duplicatesInPaste;
}

final _numberPrefix = RegExp(r'^\s*(?:\d+\s*[\.\)\-:]\s*|\d+\s+)');
final _plusCount = RegExp(r'\+\s*(\d+)\s*$');
final _emojiOrSymbol = RegExp(
  r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]',
  unicode: true,
);

const _chatter = {
  'ใครมาบ้าง',
  'ใครมา',
  'มาครับ',
  'มาค่ะ',
  'ครับ',
  'ค่ะ',
  'ok',
  'okay',
  'list',
  'รายชื่อ',
};

LineParseResult parseLineSignup(
  String text, {
  Iterable<String> existingNames = const [],
}) {
  final existing = {
    for (final name in existingNames) _key(name),
  };
  final seen = <String>{};
  final names = <String>[];
  final duplicatesInPaste = <String>[];

  for (final rawLine in text.split(RegExp(r'\r?\n'))) {
    for (final extracted in _extractNames(rawLine)) {
      final key = _key(extracted);
      if (seen.contains(key)) {
        if (!duplicatesInPaste.contains(extracted)) {
          duplicatesInPaste.add(extracted);
        }
        continue;
      }
      seen.add(key);
      names.add(extracted);
    }
  }

  final already = <String>[];
  final fresh = <String>[];
  for (final name in names) {
    if (existing.contains(_key(name))) {
      already.add(name);
    } else {
      fresh.add(name);
    }
  }

  return LineParseResult(
    names: names,
    newNames: fresh,
    alreadyInRoster: already,
    duplicatesInPaste: duplicatesInPaste,
  );
}

Iterable<String> _extractNames(String rawLine) sync* {
  var line = rawLine.trim();
  if (line.isEmpty) {
    return;
  }
  line = line.replaceAll(_emojiOrSymbol, '').trim();
  line = line.replaceFirst(_numberPrefix, '').trim();
  if (line.isEmpty || _isChatter(line)) {
    return;
  }

  final plus = _plusCount.firstMatch(line);
  var base = line;
  var extras = 0;
  if (plus != null) {
    extras = int.parse(plus.group(1)!);
    base = line.substring(0, plus.start).trim();
  }
  if (base.isEmpty || _isChatter(base)) {
    return;
  }
  yield base;
  for (var i = 1; i <= extras; i++) {
    yield '$base +$i';
  }
}

bool _isChatter(String line) {
  final compact = line.replaceAll(RegExp(r'\s+'), '').toLowerCase();
  if (_chatter.contains(compact) || _chatter.contains(line.toLowerCase())) {
    return true;
  }
  if (line.length > 24 && line.contains(' ')) {
    return true;
  }
  return false;
}

String _key(String name) => name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
