import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'ads/ad_service.dart';
import 'services/feedback_service.dart';
import 'state/game_controller.dart';
import 'ui/cubex_theme.dart';
import 'ui/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
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
        ChangeNotifierProvider<FeedbackService>.value(value: feedback),
      ],
      child: MaterialApp(
        title: 'Cubex',
        debugShowCheckedModeBanner: false,
        theme: CubexTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
