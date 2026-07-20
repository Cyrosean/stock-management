import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  List purchases = [];
  List suppliers = [];

  final itemNameController = TextEditingController();
  final quantityController = TextEditingController();
  final unitCostController = TextEditingController();
  final totalController = TextEditingController();
  final dateController = TextEditingController();

  String? selectedSupplierId;

  @override
  void initState() {
    super.initState();
    getPurchases();
    getSuppliers();
  }

  Future<void> getPurchases() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/get_purchases.php");

    var response = await http.get(url);

    setState(() {
      purchases = jsonDecode(response.body);
    });
  }

  Future<void> getSuppliers() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/get_suppliers.php");

    var response = await http.get(url);

    setState(() {
      suppliers = jsonDecode(response.body);
    });
  }

  void calculateTotal() {
    final qty = double.tryParse(quantityController.text) ?? 0;
    final cost = double.tryParse(unitCostController.text) ?? 0;
    totalController.text = (qty * cost).toStringAsFixed(2);
  }

  Future<void> addPurchase() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/add_purchase.php");

    var response = await http.post(
      url,
      body: {
        "supplier_id": selectedSupplierId ?? "",
        "item_name": itemNameController.text,
        "quantity": quantityController.text,
        "unit_cost": unitCostController.text,
        "total_cost": totalController.text,
        "purchase_date": dateController.text,
      },
    );

    debugPrint(response.body);

    if (response.body.trim() == "success") {
      if (!mounted) return;
      Navigator.pop(context);

      itemNameController.clear();
      quantityController.clear();
      unitCostController.clear();
      totalController.clear();
      dateController.clear();
      selectedSupplierId = null;

      getPurchases();
    }
  }

  Future<void> updatePurchase(String id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/update_purchase.php");

    var response = await http.post(
      url,
      body: {
        "id": id,
        "supplier_id": selectedSupplierId ?? "",
        "item_name": itemNameController.text,
        "quantity": quantityController.text,
        "unit_cost": unitCostController.text,
        "total_cost": totalController.text,
        "purchase_date": dateController.text,
      },
    );

    if (response.body.trim() == "success") {
      if (!mounted) return;
      Navigator.pop(context);

      getPurchases();
    }
  }

  Future<void> deletePurchase(String id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/delete_purchase.php");

    var response = await http.post(url, body: {"id": id});

    if (response.body.trim() == "success") {
      if (!mounted) return;

      getPurchases();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Purchase deleted successfully")),
      );
    }
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Purchase"),
          content: const Text("Are you sure you want to delete this purchase?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                deletePurchase(id);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void addPurchaseForm() {
    itemNameController.clear();
    quantityController.clear();
    unitCostController.clear();
    totalController.clear();
    dateController.clear();
    selectedSupplierId = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Purchase"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedSupplierId,
                      decoration: const InputDecoration(labelText: "Supplier"),
                      items: suppliers.map<DropdownMenuItem<String>>((
                        supplier,
                      ) {
                        return DropdownMenuItem<String>(
                          value: supplier["id"].toString(),
                          child: Text(supplier["name"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedSupplierId = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: itemNameController,
                      decoration: const InputDecoration(labelText: "Item Name"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Quantity"),
                      onChanged: (_) => setDialogState(calculateTotal),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: unitCostController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Unit Cost",
                      ),
                      onChanged: (_) => setDialogState(calculateTotal),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: totalController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Total Cost",
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Purchase Date",
                      ),
                      onTap: pickDate,
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
                  onPressed: addPurchase,
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void editPurchaseForm(dynamic purchase) {
    itemNameController.text = purchase["item_name"] ?? "";
    quantityController.text = purchase["quantity"]?.toString() ?? "";
    unitCostController.text = purchase["unit_cost"]?.toString() ?? "";
    totalController.text = purchase["total_cost"]?.toString() ?? "";
    dateController.text = purchase["purchase_date"] ?? "";
    selectedSupplierId = purchase["supplier_id"].toString();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Purchase"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedSupplierId,
                      decoration: const InputDecoration(labelText: "Supplier"),
                      items: suppliers.map<DropdownMenuItem<String>>((
                        supplier,
                      ) {
                        return DropdownMenuItem<String>(
                          value: supplier["id"].toString(),
                          child: Text(supplier["name"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedSupplierId = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: itemNameController,
                      decoration: const InputDecoration(labelText: "Item Name"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Quantity"),
                      onChanged: (_) => setDialogState(calculateTotal),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: unitCostController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Unit Cost",
                      ),
                      onChanged: (_) => setDialogState(calculateTotal),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: totalController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Total Cost",
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Purchase Date",
                      ),
                      onTap: pickDate,
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
                    updatePurchase(purchase["id"].toString());
                  },
                  child: const Text("Update"),
                ),
              ],
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
        title: const Text("Purchases"),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: purchases.length,
        itemBuilder: (context, index) {
          final purchase = purchases[index];
          String supplierName = "Unknown";
          for (var supplier in suppliers) {
            if (supplier["id"].toString() ==
                purchase["supplier_id"].toString()) {
              supplierName = supplier["name"];
              break;
            }
          }
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.shopping_cart, color: Colors.white),
              ),
              title: Text(purchase["item_name"] ?? ""),
              subtitle: Text(
                "Supplier: $supplierName\n"
                "Qty: ${purchase["quantity"]} @ ${purchase["unit_cost"]}\n"
                "Total: ${purchase["total_cost"]}\n"
                "Date: ${purchase["purchase_date"]}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      editPurchaseForm(purchase);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      confirmDelete(purchase["id"].toString());
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
        onPressed: addPurchaseForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
