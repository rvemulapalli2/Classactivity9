import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Database',
      home: FoldersScreen(),
    );
  }
}

class FoldersScreen extends StatefulWidget {
  @override
  _FoldersScreenState createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  List<Map<String, dynamic>> folders = [
    {'id': 1, 'folder_name': 'Hearts'},
    {'id': 2, 'folder_name': 'Clubs'},
    {'id': 3, 'folder_name': 'Spades'},
    {'id': 4, 'folder_name': 'Diamonds'},
  ];

  Map<String, dynamic>? selectedFolder;

  @override
  void initState() {
    super.initState();
  }

  void _addFolder() {
    String folderName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Folder'),
          content: TextField(
            onChanged: (value) {
              folderName = value;
            },
            decoration: InputDecoration(hintText: "Folder Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  int newId = folders.length + 1; // Simple ID assignment
                  folders.add({'id': newId, 'folder_name': folderName});
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _updateFolder(Map<String, dynamic> folder) {
    final TextEditingController controller =
        TextEditingController(text: folder['folder_name']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Folder'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Folder Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  final index =
                      folders.indexWhere((f) => f['id'] == folder['id']);
                  if (index != -1) {
                    folders[index]['folder_name'] = controller.text;
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFolder(Map<String, dynamic> folder) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Folder'),
          content: Text('Are you sure you want to delete this folder?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  folders.removeWhere((f) => f['id'] == folder['id']);
                });
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showFolderOptions(String action) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folder = folders[index];
            return ListTile(
              title: Text(folder['folder_name']),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                if (action == 'edit') {
                  _updateFolder(folder);
                } else if (action == 'delete') {
                  _deleteFolder(folder);
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folders'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addFolder,
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showFolderOptions('edit'),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showFolderOptions('delete'),
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
        ),
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardsScreen(folderId: folder['id']),
                ),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    (folder['folder_name'] == 'Hearts' ||
                            folder['folder_name'] == 'Diamonds')
                        ? 'https://cdn.pixabay.com/photo/2022/02/23/20/25/card-7031432_1280.png'
                        : (folder['folder_name'] == 'Spades' ||
                                folder['folder_name'] == 'Clubs')
                            ? 'https://deckofcardsapi.com/static/img/back.png'
                            : 'https://i.redd.it/look-for-opinions-on-my-2-playing-card-back-designs-look-to-v0-r4rle6ipe3fc1.png?width=816&format=png&auto=webp&s=e5a6eca1e034c45a1221c80a23fe16dbbe6c45db',
                    height: 100,
                  ),
                  SizedBox(height: 10),
                  Text(folder['folder_name'], style: TextStyle(fontSize: 20)),
                  SizedBox(height: 5),
                  FutureBuilder<int>(
                    future: _countCardsInFolder(folder['id']),
                    builder: (context, cardSnapshot) {
                      if (cardSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (cardSnapshot.hasError) {
                        return Text('Error: ${cardSnapshot.error}');
                      } else {
                        return Text('${cardSnapshot.data} cards');
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<int> _countCardsInFolder(int folderId) async {
    const cardCounts = {1: 3, 2: 3, 3: 4, 4: 2};
    return cardCounts[folderId] ?? 0;
  }
}

class CardsScreen extends StatelessWidget {
  final int folderId;

  CardsScreen({required this.folderId});

  final Map<int, List<Map<String, dynamic>>> cardsByFolder = {
    1: [
      {
        'name': 'Heart Ace',
        'image_url': 'https://deckofcardsapi.com/static/img/AH.png'
      },
      {
        'name': 'Heart King',
        'image_url': 'https://deckofcardsapi.com/static/img/KH.png'
      },
      {
        'name': 'Heart Queen',
        'image_url': 'https://deckofcardsapi.com/static/img/QH.png'
      },
    ],
    2: [
      {
        'name': 'Club Ace',
        'image_url': 'https://deckofcardsapi.com/static/img/AC.png'
      },
      {
        'name': 'Club King',
        'image_url': 'https://deckofcardsapi.com/static/img/KC.png'
      },
      {
        'name': 'Club Queen',
        'image_url': 'https://deckofcardsapi.com/static/img/QC.png'
      },
    ],
    3: [
      {
        'name': 'Spade Ace',
        'image_url': 'https://deckofcardsapi.com/static/img/AS.png'
      },
      {
        'name': 'Spade King',
        'image_url': 'https://deckofcardsapi.com/static/img/KS.png'
      },
      {
        'name': 'Spade Queen',
        'image_url': 'https://deckofcardsapi.com/static/img/QS.png'
      },
      {
        'name': 'Spade Jack',
        'image_url': 'https://deckofcardsapi.com/static/img/JS.png'
      },
    ],
    4: [
      {
        'name': 'Diamond Ace',
        'image_url': 'https://deckofcardsapi.com/static/img/AD.png'
      },
      {
        'name': 'Diamond King',
        'image_url': 'https://deckofcardsapi.com/static/img/KD.png'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cards'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Add card logic
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final cards = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return GestureDetector(
                  onTap: () {
                    // Update card logic
                  },
                  onLongPress: () {
                    // Delete card logic
                  },
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(card['image_url'], height: 100),
                        SizedBox(height: 10),
                        Text(card['name']),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCards() async {
    return cardsByFolder[folderId] ?? [];
  }
}
