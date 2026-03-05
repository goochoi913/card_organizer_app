import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';
import '../widgets/card_image.dart';
import 'card_form_screen.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;
  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepository = CardRepository();
  List<PlayingCard> _cards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _loading = true);
    }
    final cards = await _cardRepository.getCardsByFolderId(widget.folder.id!);
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  Future<void> _deleteCard(PlayingCard card) async {
    await _cardRepository.deleteCard(card.id!);
    await _loadCards(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.folderName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CardFormScreen(
                folderId: widget.folder.id!,
                initialSuit: widget.folder.folderName,
              ),
            ),
          );
          await _loadCards(showLoading: false);
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView.builder(
              itemCount: _cards.length,
              onReorder: (oldIndex, newIndex) async {
                // BONUS: DRAG AND DROP LOGIC
                if (newIndex > oldIndex) newIndex -= 1;
                final card = _cards.removeAt(oldIndex);
                _cards.insert(newIndex, card);

                for (int i = 0; i < _cards.length; i++) {
                  _cards[i] = _cards[i].copyWith(orderIndex: i);
                }
                setState(() {});
                await _cardRepository.updateCardOrders(_cards);
              },
              itemBuilder: (_, index) {
                final card = _cards[index];
                return ListTile(
                  key: ValueKey(card.id), // CRUCIAL FOR DRAG AND DROP
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CardImage(card: card),
                    ),
                  ),
                  title: Text(card.cardName),
                  subtitle: Text(card.suit),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CardFormScreen(
                                folderId: widget.folder.id!,
                                initialSuit: widget.folder.folderName,
                                existing: card,
                              ),
                            ),
                          );
                          await _loadCards(showLoading: false);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteCard(card),
                      ),
                      const Icon(Icons.drag_handle, color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
