import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_organizer_app/models/card.dart';
import 'package:card_organizer_app/widgets/card_image.dart';

void main() {
  testWidgets('CardImage shows fallback icon for empty image path', (
    WidgetTester tester,
  ) async {
    final card = PlayingCard(
      cardName: 'Ace',
      suit: 'Spades',
      imageUrl: '',
      folderId: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CardImage(card: card)),
      ),
    );

    expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
  });
}
