import 'package:flutter/material.dart';
import '../models/card.dart'; // <--- Fixed this import!

class CardImage extends StatelessWidget {
  final PlayingCard card;
  const CardImage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final path = card.imageUrl;

    if (path == null || path.trim().isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported, size: 40));
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 40)),
      );
    }

    // optional: network URL support
    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 40)),
    );
  }
}