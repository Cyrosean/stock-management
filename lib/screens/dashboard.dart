import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'clients_screen.dart';
import 'suppliers_screen.dart';
import 'purchases_screen.dart';
import 'inventory_screen.dart';
import 'sales_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Widget buildCard(BuildContext context, IconData icon, String title) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (title == "Clients") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ClientsScreen()),
            );
          } else if (title == "Suppliers") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SuppliersScreen()),
            );
          } else if (title == "Purchases") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PurchasesScreen()),
            );
          } else if (title == "Inventory") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InventoryScreen()),
            );
          } else if (title == "Sales") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesScreen()),
            );
          } else if (title == "Profile") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title Screen Coming Soon")),
            );
          }
        },
        child: Container(
          height: 150,
          width: 160,
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFFF8C00),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C00),
        title: const Text("Wholesale Dashboard"),
        centerTitle: true,
      ),

      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFFF8C00),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.warehouse,
                      color: Color(0xFFFF8C00),
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Wholesale Inventory",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(
                Icons.headset_mic_outlined,
                color: Color(0xFFFF8C00),
              ),
              title: const Text('Help'),
              subtitle: const Text('Locate agent, report fraud'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Help & Support'),
                    content: const Text(
                      'Need assistance? Contact us at:\nsupport@yourbusiness.com',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.verified_outlined,
                color: Color(0xFFFF8C00),
              ),
              title: const Text('Recommend'),
              subtitle: const Text('Refer a friend, share this app'),
              onTap: () {
                Navigator.pop(context);
                SharePlus.instance.share(
                  ShareParams(
                    text:
                        'Check out this app I use to manage my wholesale business!',
                  ),
                );
              },
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Sign out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, color: Color(0xFFFF8C00)),
                label: const Text(
                  'Sign',
                  style: TextStyle(color: Color(0xFFFF8C00)),
                ),
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            buildCard(context, Icons.people, "Clients"),
            buildCard(context, Icons.local_shipping, "Suppliers"),
            buildCard(context, Icons.shopping_cart, "Purchases"),
            buildCard(context, Icons.warehouse, "Inventory"),
            buildCard(context, Icons.point_of_sale, "Sales"),
            buildCard(context, Icons.person, "Profile"),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF8C00),
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
