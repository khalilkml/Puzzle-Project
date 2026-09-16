import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:block_puzzle/state/game_controller.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GameScreen renders scoreboard board tray and ad slot', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(wrapGame(GameController()..init()));
    await tester.pumpAndSettle();

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('Ad Banner Slot'), findsOneWidget);
  });
}
