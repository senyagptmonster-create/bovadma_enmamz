import 'package:flutter/material.dart';

import 'app/brand.dart';
import 'app/store.dart';
import 'app/theme.dart';
import 'initial_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const InitialPage(),
    );
  }
}
