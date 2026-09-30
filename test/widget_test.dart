import 'package:bellapp/features/bell/bell_visual.dart';
import 'package:bellapp/features/pairing/home_screen.dart';
import 'package:bellapp/services/ring_deduper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la campana se pinta en pantalla', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: BellVisual(swing: 0.1)),
        ),
      ),
    );

    expect(find.byType(BellVisual), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('la portada ofrece crear y unirse', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Crear campana'), findsOneWidget);
    expect(find.text('Unirse con código'), findsOneWidget);
  });

  test('RingDeduper ignora el mismo toque dos veces', () {
    RingDeduper.reset();
    expect(RingDeduper.claim('abc'), isTrue);
    expect(RingDeduper.claim('abc'), isFalse);
    expect(RingDeduper.claim('def'), isTrue);
  });
}
