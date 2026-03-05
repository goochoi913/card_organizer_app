import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../repositories/folder_repository.dart';
import '../repositories/card_repository.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FolderRepository _folderRepository = FolderRepository();
  final CardRepository _cardRepository = CardRepository();

  List<Folder> _folders = [];
  Map<int, int> _cardCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _loading = true);
    }

    final results = await Future.wait([
      _folderRepository.getAllFolders(),
      _cardRepository.getCardCountsByFolder(),
    ]);
    final folders = results[0] as List<Folder>;
    final counts = results[1] as Map<int, int>;

    if (!mounted) return;
    setState(() {
      _folders = folders;
      _cardCounts = counts;
      _loading = false;
    });
  }

  Future<void> _deleteFolder(Folder folder) async {
    final folderId = folder.id!;
    final count = _cardCounts[folderId] ?? 0;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // non-dismissible for safety
      builder: (_) => AlertDialog(
        title: const Text('Delete Folder?'),
        content: Text(
          'Delete "${folder.folderName}"?\n'
          'This will also delete $count cards in this folder (CASCADE).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _folderRepository.deleteFolder(folderId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Folder "${folder.folderName}" deleted')),
      );

      await _loadFolders(showLoading: false);
    }
  }

  String _getSuitImagePath(String suitName) {
    switch (suitName) {
      case 'Hearts':
        return 'assets/cards/hearts_ace.png';
      case 'Diamonds':
        return 'assets/cards/diamonds_ace.png';
      case 'Clubs':
        return 'assets/cards/clubs_ace.png';
      case 'Spades':
        return 'assets/cards/spades_ace.png';
      default:
        return 'assets/cards/back.png'; // Make sure you have a back image too!
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Organizer')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 360 ? 1 : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 260,
                  ),
                  itemCount: _folders.length,
                  itemBuilder: (_, index) {
                    final folder = _folders[index];
                    final folderId = folder.id!;
                    final cardCount = _cardCounts[folderId] ?? 0;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CardsScreen(folder: folder),
                            ),
                          );
                          await _loadFolders(
                            showLoading: false,
                          ); // refresh after returning
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                _getSuitImagePath(folder.folderName),
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                folder.folderName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$cardCount cards',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () => _deleteFolder(folder),
                                tooltip: 'Delete folder',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
