import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'ads/ad_service.dart';
import 'services/feedback_service.dart';
import 'state/game_controller.dart';
import 'ui/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final ads = AdService();
  await ads.initialize();
  final feedback = FeedbackService();
  await feedback.init();
  runApp(BlockPuzzleApp(adService: ads, feedback: feedback));
}

class BlockPuzzleApp extends StatelessWidget {
  const BlockPuzzleApp({
    super.key,
    required this.adService,
    required this.feedback,
  });

  final AdService adService;
  final FeedbackService feedback;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameController()),
        ChangeNotifierProvider<AdService>.value(value: adService),
        Provider<FeedbackService>.value(value: feedback),
      ],
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
