import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:block_puzzle/ads/ad_service.dart';
import 'package:block_puzzle/services/feedback_service.dart';
import 'package:block_puzzle/state/game_controller.dart';
import 'package:block_puzzle/ui/game_screen.dart';

Widget wrapGame(GameController controller, {AdService? ads}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: controller),
      ChangeNotifierProvider<AdService>.value(value: ads ?? AdService()),
      ChangeNotifierProvider<FeedbackService>.value(
        value: FeedbackService.silent(),
      ),
    ],
    child: const MaterialApp(home: GameScreen()),
  );
}
