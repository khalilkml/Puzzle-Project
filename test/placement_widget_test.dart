import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:block_puzzle/game/board.dart';
import 'package:block_puzzle/state/game_controller.dart';
import 'package:block_puzzle/ui/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('placing a tray piece updates score and clears the slot',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = GameController(random: Random(42));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: GameScreen()),
      ),
    );
    await controller.init();
    await tester.pumpAndSettle();

    final shape = controller.tray[0]!;
    expect(controller.tryPlaceAt(0, 0, 0), isTrue);
    await tester.pumpAndSettle();

    expect(controller.tray[0], isNull);
    expect(controller.score, shape.blockCount);
    expect(find.text('${shape.blockCount}'), findsWidgets);
    expect(find.text('Ad Banner Slot'), findsOneWidget);
  });
}
