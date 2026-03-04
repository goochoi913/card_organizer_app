import 'package:flutter/material.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';

class CardFormScreen extends StatefulWidget {
  final int folderId;
  final String initialSuit;
  final PlayingCard? existing;

  const CardFormScreen({
    super.key,
    required this.folderId,
    required this.initialSuit,
    this.existing,
  });

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _repo = CardRepository();
  final _formKey = GlobalKey<FormState>();

  final _suits = const ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
  final _ranks = const [
    'Ace','2','3','4','5','6','7','8','9','10','Jack','Queen','King'
  ];

  late String _cardName;
  late String _suit;
  late String _imagePathOrUrl;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;

    _cardName = ex?.cardName ?? _ranks.first;
    _suit = ex?.suit ?? widget.initialSuit;
    _imagePathOrUrl = ex?.imageUrl ?? '';
  }

  String _defaultAssetPath(String suit, String rank) {
    // must match your actual asset filenames
    return 'assets/cards/${suit.toLowerCase()}_${rank.toLowerCase()}.png';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final finalImage = _imagePathOrUrl.trim().isEmpty
        ? _defaultAssetPath(_suit, _cardName)
        : _imagePathOrUrl.trim();

    try {
      if (widget.existing == null) {
        await _repo.insertCard(
          PlayingCard(
            cardName: _cardName,
            suit: _suit,
            imageUrl: finalImage,
            folderId: widget.folderId,
          ),
        );
      } else {
        await _repo.updateCard(
          widget.existing!.copyWith(
            cardName: _cardName,
            suit: _suit,
            imageUrl: finalImage,
            folderId: widget.folderId,
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Card' : 'Add Card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _cardName,
                decoration: const InputDecoration(labelText: 'Card name'),
                items: _ranks
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _cardName = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _suit,
                decoration: const InputDecoration(labelText: 'Suit'),
                items: _suits
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _suit = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _imagePathOrUrl,
                decoration: const InputDecoration(
                  labelText: 'Image path/URL (optional)',
                  hintText: 'Leave blank to use default asset image',
                ),
                onSaved: (v) => _imagePathOrUrl = v ?? '',
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}