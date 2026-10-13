import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingApp());
}

class Item {
  Item(this.name);
  final String name;
  bool bought = false;
  int quantity = 1;
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: const HomeScreen(title: 'Jonathan'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final items = [
    Item('Milk'),
    Item('Bread'),
    Item('Rice'),
    Item('Eggs'),
  ];
  final controller = TextEditingController();
  String filter = 'All';

  void showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), action: action),
    );
  }

  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) {
      showMessage('Type an item first');
      return;
    }

    final matches = items.where(
          (item) => item.name.toLowerCase() == text.toLowerCase(),
    );
    if (matches.isNotEmpty) {
      final existing = matches.first;
      setState(() {
        existing.quantity += 1;
      });
      controller.clear();
      showMessage(
        '${existing.name} is already on the list: now ×${existing.quantity}',
      );
      return;
    }

    setState(() {
      items.add(Item(text));
    });
    controller.clear();
  }

  void changeQuantity(Item item, int delta) {
    if (delta < 0 && item.quantity == 1) return;
    setState(() {
      item.quantity += delta;
    });
  }

  void deleteItem(Item item) {
    final index = items.indexOf(item);
    final name = item.name;
    setState(() {
      items.remove(item);
    });
    showMessage(
      '$name removed',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          setState(() {
            items.insert(index, item);
          });
        },
      ),
    );
  }

  List<Item> visibleItems() {
    final toBuy = items.where((item) => !item.bought).toList();
    final bought = items.where((item) => item.bought).toList();
    if (filter == 'To buy') return toBuy;
    if (filter == 'Bought') return bought;
    return [...toBuy, ...bought];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = items.where((item) => !item.bought).length;
    final shown = visibleItems();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} ($left left)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed: () {
              setState(() {
                items.removeWhere((item) => item.bought);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Add an item'),
                    onSubmitted: (_) => addItem(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter == 'All',
                  onSelected: (_) {
                    setState(() {
                      filter = 'All';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('To buy'),
                  selected: filter == 'To buy',
                  onSelected: (_) {
                    setState(() {
                      filter = 'To buy';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bought'),
                  selected: filter == 'Bought',
                  onSelected: (_) {
                    setState(() {
                      filter = 'Bought';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Your list is empty'))
                : shown.isEmpty
                ? const Center(child: Text('Nothing here'))
                : ListView.builder(
              itemCount: shown.length,
              itemBuilder: (context, index) {
                final item = shown[index];
                return ListTile(
                  leading: Icon(
                    item.bought
                        ? Icons.check_circle
                        : Icons.shopping_basket,
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.bought
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      item.bought = !item.bought;
                    });
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => changeQuantity(item, -1),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => changeQuantity(item, 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => deleteItem(item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}