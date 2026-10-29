import 'package:flutter_test/flutter_test.dart';
import 'package:kwan_bad/logic/line_parser.dart';

void main() {
  group('parseLineSignup', () {
    test('parses a numbered Thai list', () {
      const text = '1. ต้น\n2. บอล\n3. มิ้นท์';
      final result = parseLineSignup(text);
      expect(result.names, ['ต้น', 'บอล', 'มิ้นท์']);
    });

    test('accepts several numbering styles', () {
      const text = '1) ต้น\n2- บอล\n3: มิ้นท์\n4 โอ๋';
      expect(parseLineSignup(text).names, ['ต้น', 'บอล', 'มิ้นท์', 'โอ๋']);
    });

    test('accepts a number and dot with no following space', () {
      expect(parseLineSignup('1.ต้น').names, ['ต้น']);
    });

    test('strips emojis and leftover decoration', () {
      const text = '1. ต้น 🏸😊\n2. บอล 🔥';
      expect(parseLineSignup(text).names, ['ต้น', 'บอล']);
    });

    test('expands +1 into an extra unnamed companion', () {
      const text = '1. เจ +1\n2. บอล';
      expect(parseLineSignup(text).names, ['เจ', 'เจ +1', 'บอล']);
    });

    test('expands +2 into two companions', () {
      const text = 'แพรว +2';
      expect(parseLineSignup(text).names, ['แพรว', 'แพรว +1', 'แพรว +2']);
    });

    test('parses names without numbers', () {
      const text = 'ต้น\nบอล\nมิ้นท์';
      expect(parseLineSignup(text).names, ['ต้น', 'บอล', 'มิ้นท์']);
    });

    test('skips blank lines and chatter', () {
      const text = 'ใครมาบ้าง\n\n1. ต้น\nมาครับ\n2. บอล\n';
      expect(parseLineSignup(text).names, ['ต้น', 'บอล']);
    });

    test('deduplicates names within the paste (case-insensitive)', () {
      const text = '1. ต้น\n2. ต้น\n3. ต้น ';
      final result = parseLineSignup(text);
      expect(result.names, ['ต้น']);
      expect(result.duplicatesInPaste, ['ต้น']);
    });

    test('marks names already on the roster as existing', () {
      const text = '1. ต้น\n2. บอล\n3. มิ้นท์';
      final result = parseLineSignup(text, existingNames: ['ต้น', 'โอ๋']);
      expect(result.newNames, ['บอล', 'มิ้นท์']);
      expect(result.alreadyInRoster, ['ต้น']);
    });
  });
}
