import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
  runApp(const ProviderScope(child: KwanBadApp()));
}

class KwanBadApp extends StatelessWidget {
  const KwanBadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'จัดก๊วนตีแบด',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}
