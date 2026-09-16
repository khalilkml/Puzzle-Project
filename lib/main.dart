import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'state/game_controller.dart';
import 'ui/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const BlockPuzzleApp());
}

class BlockPuzzleApp extends StatelessWidget {
  const BlockPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(),
      child: MaterialApp(
        title: 'Block Puzzle',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4FC3F7),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF121418),
        ),
        home: const GameScreen(),
      ),
    );
  }
}
