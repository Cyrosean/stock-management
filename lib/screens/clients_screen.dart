import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List clients = [];

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Load clients from database
  Future<void> getClients() async {
    var url = Uri.parse("${ApiConfig.baseUrl}/get_clients.php");

    var response = await http.get(url);

    setState(() {
      clients = jsonDecode(response.body);
    });
  }

  // Add client to database
  Future<void> addClient() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/add_client.php");
    var response = await http.post(
      url,
      body: {"name": nameController.text, "phone": phoneController.text},
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.body.trim() == "success") {
      if (!mounted) return;
      Navigator.pop(context);
      getClients();
    }
  }

  @override
  void initState() {
    super.initState();

    getClients();
  }

  void addClientForm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Client"),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Client Name"),
              ),

              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
            ],
          ),

          actions: [
            ElevatedButton(onPressed: addClient, child: const Text("Save")),
          ],
        );
      },
    );
  }

  void editClientForm(dynamic client) {
    nameController.text = client["name"];
    phoneController.text = client["phone"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Client"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                updateClient(client["id"]);
              },
              child: const Text("update"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateClient(String id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/update_client.php");

    var response = await http.post(
      url,

      body: {
        "id": id,
        "name": nameController.text,
        "phone": phoneController.text,
      },
    );

    debugPrint(response.body);

    if (response.body.trim() == "success") {
      if (!mounted) return;
      Navigator.pop(context);

      getClients();
    }
  }

  Future<void> deleteClient(String id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/delete_client.php");

    var response = await http.post(url, body: {"id": id});

    if (response.body.trim() == "success") {
      if (!mounted) return;

      getClients();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Client deleted successfully")),
      );
    }
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Client"),
          content: const Text("Are you sure you want to delete this client?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                deleteClient(id);
              },
              child: const Text("Delete"),
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
        title: const Text("Clients"),
        backgroundColor: Colors.orange,
      ),

      body: ListView.builder(
        itemCount: clients.length,

        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(clients[index]["name"]),

              subtitle: Text(clients[index]["phone"]),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      editClientForm(clients[index]);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      confirmDelete(clients[index]["id"]);
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

        onPressed: addClientForm,

        child: const Icon(Icons.add),
      ),
    );
  }
}
