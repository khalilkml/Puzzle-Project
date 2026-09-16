import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:block_puzzle/state/game_controller.dart';
import 'package:block_puzzle/ui/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GameScreen renders scoreboard board tray and ad slot',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameController()..init(),
        child: const MaterialApp(home: GameScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('Ad Banner Slot'), findsOneWidget);
  });
}
