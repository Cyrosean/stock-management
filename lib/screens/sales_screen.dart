import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List sales = [];
  List clients = [];
  final productController = TextEditingController();
  final quantityController = TextEditingController();
  final unitPriceController = TextEditingController();
  final totalController = TextEditingController();
  final dateController = TextEditingController();
  String? selectedClientId;
  @override
  void initState() {
    super.initState();
    getSales();
    getClients();
  }

  Future<void> getSales() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/get_sales.php");
    var response = await http.get(url);
    setState(() {
      sales = jsonDecode(response.body);
    });
  }

  Future<void> getClients() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/get_clients.php");
    var response = await http.get(url);
    setState(() {
      clients = jsonDecode(response.body);
    });
  }

  void calculateTotal() {
    final qty = double.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(unitPriceController.text) ?? 0;
    totalController.text = (qty * price).toStringAsFixed(2);
  }

  Future<void> addSale() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/add_sale.php");
    var response = await http.post(
      url,
      body: {
        "client_id": selectedClientId ?? "",
        "product_name": productController.text,
        "quantity": quantityController.text,
        "unit_price": unitPriceController.text,
        "total": totalController.text,
        "sale_date": dateController.text,
      },
    );
    debugPrint(response.body);
    if (response.body.trim() == "success") {
      if (!mounted) return;
      Navigator.pop(context);
      productController.clear();
      quantityController.clear();
      unitPriceController.clear();
      totalController.clear();
      dateController.clear();
      selectedClientId = null;
      getSales();
    }
  }

  Future<void> updateSale(String id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/update_sale.php");
    var response = await http.post(
      url,
      body: {
        "id": id,
        "client_id": selectedClientId ?? "",
        "product_name": productController.text,
        "quantity": quantityController.text,
        "unit_price": unitPriceController.text,
        "total": totalController.text,
        "sale_date": dateController.text,
      },
    );
    if (response.body.trim() == "success") {
      if (!mounted) return;
      Navigator.pop(context);
      getSales();
    }
  }

  Future<void> deleteSale(String id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/delete_sale.php");
    var response = await http.post(url, body: {"id": id});
    if (response.body.trim() == "success") {
      if (!mounted) return;
      Navigator.pop(context);
      getSales();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sale deleted successfully")),
      );
    }
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Sale"),
          content: const Text("Are you sure you want to delete this sale?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                deleteSale(id);
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

  void addSaleForm() {
    productController.clear();
    quantityController.clear();
    unitPriceController.clear();
    totalController.clear();
    dateController.clear();
    selectedClientId = null;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Sale"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedClientId,
                      decoration: const InputDecoration(labelText: "Client"),
                      items: clients.map<DropdownMenuItem<String>>((client) {
                        return DropdownMenuItem<String>(
                          value: client["id"].toString(),
                          child: Text(client["name"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedClientId = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: productController,
                      decoration: const InputDecoration(
                        labelText: "Product Name",
                      ),
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
                      controller: unitPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Unit Price",
                      ),
                      onChanged: (_) => setDialogState(calculateTotal),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: totalController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: "Total"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: "Sale Date"),
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
                ElevatedButton(onPressed: addSale, child: const Text("Save")),
              ],
            );
          },
        );
      },
    );
  }

  void editSaleForm(dynamic sale) {
    productController.text = sale["product_name"] ?? "";
    quantityController.text = sale["quantity"]?.toString() ?? "";
    unitPriceController.text = sale["unit_price"]?.toString() ?? "";
    totalController.text = sale["total"]?.toString() ?? "";
    dateController.text = sale["sale_date"] ?? "";
    selectedClientId = sale["client_id"].toString();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Sale"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedClientId,
                      decoration: const InputDecoration(labelText: "Client"),
                      items: clients.map<DropdownMenuItem<String>>((client) {
                        return DropdownMenuItem<String>(
                          value: client["id"].toString(),
                          child: Text(client["name"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedClientId = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: productController,
                      decoration: const InputDecoration(
                        labelText: "Product Name",
                      ),
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
                      controller: unitPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Unit Price",
                      ),
                      onChanged: (_) => setDialogState(calculateTotal),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: totalController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: "Total"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: "Sale Date"),
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
                    updateSale(sale["id"].toString());
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
        title: const Text("Sales"),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: sales.length,
        itemBuilder: (context, index) {
          final sale = sales[index];
          String clientName = "Unknown";
          for (var client in clients) {
            if (client["id"].toString() == sale["client_id"].toString()) {
              clientName = client["name"];
              break;
            }
          }
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(sale["product_name"] ?? ""),
              subtitle: Text(
                "Client: $clientName\n"
                "Qty: ${sale["quantity"]} @ ${sale["unit_price"]}\n"
                "Total: ${sale["total"]}\n"
                "Date: ${sale["sale_date"]}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      editSaleForm(sale);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      confirmDelete(sale["id"].toString());
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
        onPressed: addSaleForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
