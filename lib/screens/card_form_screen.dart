import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/folder.dart';
import '../repositories/card_repository.dart';
import '../repositories/folder_repository.dart';

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
  final _cardRepo = CardRepository();
  final _folderRepo = FolderRepository();
  final _formKey = GlobalKey<FormState>();

  final _suits = const ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
  final _ranks = const [
    'Ace',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'Jack',
    'Queen',
    'King',
  ];

  late String _cardName;
  late String _suit;
  late String _imagePathOrUrl;

  List<Folder> _folders = [];
  int? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _cardName = ex?.cardName ?? _ranks.first;
    _suit = ex?.suit ?? widget.initialSuit;
    _imagePathOrUrl = ex?.imageUrl ?? '';
    _selectedFolderId = ex?.folderId ?? widget.folderId;
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final f = await _folderRepo.getAllFolders();
    if (mounted) setState(() => _folders = f);
  }

  String _defaultAssetPath(String suit, String rank) {
    return 'assets/cards/${suit.toLowerCase()}_${rank.toLowerCase()}.png';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedFolderId == null) return;
    _formKey.currentState!.save();

    final finalImage = _imagePathOrUrl.trim().isEmpty
        ? _defaultAssetPath(_suit, _cardName)
        : _imagePathOrUrl.trim();

    if (widget.existing == null) {
      await _cardRepo.insertCard(
        PlayingCard(
          cardName: _cardName,
          suit: _suit,
          imageUrl: finalImage,
          folderId: _selectedFolderId!,
          orderIndex: 999,
        ),
      );
    } else {
      await _cardRepo.updateCard(
        widget.existing!.copyWith(
          cardName: _cardName,
          suit: _suit,
          imageUrl: finalImage,
          folderId: _selectedFolderId!,
        ),
      );
    }

    if (!mounted) return;
    Navigator.pop(context, true);
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
                initialValue: _cardName,
                decoration: const InputDecoration(labelText: 'Card Name'),
                items: _ranks
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _cardName = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _suit,
                decoration: const InputDecoration(labelText: 'Suit'),
                items: _suits
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _suit = v!),
              ),
              const SizedBox(height: 12),
              // NEW FOLDER DROPDOWN
              DropdownButtonFormField<int>(
                initialValue: _selectedFolderId,
                decoration: const InputDecoration(
                  labelText: 'Assign to Folder',
                ),
                items: _folders
                    .map(
                      (f) => DropdownMenuItem(
                        value: f.id,
                        child: Text(f.folderName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedFolderId = v),
                validator: (v) => v == null ? 'Please select a folder' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _imagePathOrUrl,
                decoration: const InputDecoration(
                  labelText: 'Image path/URL (optional)',
                ),
                onSaved: (v) => _imagePathOrUrl = v ?? '',
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
