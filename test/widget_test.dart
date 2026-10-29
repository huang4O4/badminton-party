import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwan_bad/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders home title', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: KwanBadApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('ก๊วนวันนี้'), findsWidgets);
  });
}
