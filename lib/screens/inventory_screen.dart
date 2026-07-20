import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List inventory = [];

  final itemNameController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController();
  final priceController = TextEditingController();

  Future<void> getInventory() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/get_inventory.php");

    var response = await http.get(url);

    setState(() {
      inventory = jsonDecode(response.body);
    });
  }

  @override
  void initState() {
    super.initState();
    getInventory();
  }

  Future<void> addInventory() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/add_inventory.php");

    var response = await http.post(
      url,
      body: {
        "item_name": itemNameController.text,
        "quantity": quantityController.text,
        "unit": unitController.text,
        "price": priceController.text,
      },
    );

    if (response.body.trim() == "success") {
      if (!mounted) return;

      Navigator.pop(context);

      itemNameController.clear();
      quantityController.clear();
      unitController.clear();
      priceController.clear();

      getInventory();
    }
  }

  Future<void> updateInventory(String id) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/update_inventory.php",
    );

    var response = await http.post(
      url,
      body: {
        "id": id,
        "item_name": itemNameController.text,
        "quantity": quantityController.text,
        "unit": unitController.text,
        "price": priceController.text,
      },
    );

    if (response.body.trim() == "success") {
      if (!mounted) return;

      Navigator.pop(context);

      getInventory();
    }
  }

  void addInventoryForm() {
    itemNameController.clear();
    quantityController.clear();
    unitController.clear();
    priceController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Inventory"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemNameController,
                  decoration: const InputDecoration(labelText: "Item Name"),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quantity"),
                ),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: "Unit (kg, bags...)",
                  ),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(onPressed: addInventory, child: const Text("Save")),
          ],
        );
      },
    );
  }

  Future<void> deleteInventory(String id) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/delete_inventory.php",
    );

    var response = await http.post(url, body: {"id": id});

    if (response.body.trim() == "success") {
      if (!mounted) return;

      getInventory();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inventory deleted successfully")),
      );
    }
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                deleteInventory(id);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void editInventoryForm(dynamic item) {
    itemNameController.text = item["item_name"];
    quantityController.text = item["quantity"].toString();
    unitController.text = item["unit"];
    priceController.text = item["price"].toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Inventory"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemNameController,
                  decoration: const InputDecoration(labelText: "Item Name"),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quantity"),
                ),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: "Unit"),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                updateInventory(item["id"].toString());
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: inventory.length,
        itemBuilder: (context, index) {
          final item = inventory[index];
          return Card(
            child: ListTile(
              title: Text(item["item_name"].toString()),
              subtitle: Text(
                "Qty: ${item["quantity"]} ${item["unit"]}\nPrice: ${item["price"]}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      editInventoryForm(item);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      confirmDelete(item["id"].toString());
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: addInventoryForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
