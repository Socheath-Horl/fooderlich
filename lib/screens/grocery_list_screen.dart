import 'package:flutter/material.dart';
import '../components/grocery_tile.dart';
import '../models/models.dart';
import './grocery_item_screen.dart';

class GroceryListScreen extends StatelessWidget {
  final GroceryManager manager;

  const GroceryListScreen({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groceryItmes = manager.groceryItems;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: groceryItmes.length,
        itemBuilder: (context, index) {
          final item = groceryItmes[index];
          return Dismissible(
            key: Key(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Icon(
                Icons.delete_forever,
                color: Colors.white,
                size: 50.0,
              ),
            ),
            onDismissed: (direction) {
              manager.deleteItem(index);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} dismissed')));
            },
            child: InkWell(
                child: GroceryTile(
                  key: Key(item.id),
                  item: item,
                  onComplete: (change) {
                    if (change != null) {
                      manager.completeItem(index, change);
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroceryItemScreen(
                        orignialItem: item,
                        onUpdate: (item) {
                          manager.updateItem(item, index);
                          Navigator.pop(context);
                        },
                        onCreate: (item) {},
                      ),
                    ),
                  );
                }),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 16.0,
          );
        },
      ),
    );
  }
}
