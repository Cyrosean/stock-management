import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  List suppliers = [];

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final companyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getSuppliers();
  }

  Future<void> getSuppliers() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/get_suppliers.php");

    var response = await http.get(url);

    setState(() {
      suppliers = jsonDecode(response.body);
    });
  }

  Future<void> addSupplier() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/add_supplier.php");

    var response = await http.post(
      url,
      body: {
        "name": nameController.text,
        "phone": phoneController.text,
        "company": companyController.text,
      },
    );

    debugPrint(response.body);

    if (response.body.trim() == "success") {
      if (!mounted) return;
      Navigator.pop(context);

      nameController.clear();
      phoneController.clear();
      companyController.clear();

      getSuppliers();
    }
  }

  Future<void> updateSupplier(String id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/update_supplier.php");

    var response = await http.post(
      url,
      body: {
        "id": id,
        "name": nameController.text,
        "phone": phoneController.text,
        "company": companyController.text,
      },
    );

    debugPrint(response.body);

    if (response.body.trim() == "success") {
      if (!mounted) return;
      Navigator.pop(context);

      getSuppliers();
    }
  }

  Future<void> deleteSupplier(String id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/delete_supplier.php");

    var response = await http.post(url, body: {"id": id});

    if (response.body.trim() == "success") {
      if (!mounted) return;

      getSuppliers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Supplier deleted successfully")),
      );
    }
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Supplier"),
          content: const Text("Are you sure you want to delete this supplier?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                deleteSupplier(id);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void addSupplierForm() {
    nameController.clear();
    phoneController.clear();
    companyController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Supplier"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Supplier Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: "Company"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(onPressed: addSupplier, child: const Text("Save")),
          ],
        );
      },
    );
  }

  void editSupplierForm(dynamic supplier) {
    nameController.text = supplier["name"] ?? "";
    phoneController.text = supplier["phone"] ?? "";
    companyController.text = supplier["company"] ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Supplier"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Supplier Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: "Company"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number"),
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
                updateSupplier(supplier["id"].toString());
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
        title: const Text("Suppliers"),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(supplier["name"] ?? ""),
              subtitle: Text(
                "${supplier["company"] ?? ""}\n${supplier["phone"] ?? ""}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      editSupplierForm(supplier);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      confirmDelete(supplier["id"].toString());
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
        onPressed: addSupplierForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
