import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:royaltrader/const/resource.dart';
import 'package:royaltrader/config/routes/routes_name.dart';

class HomeDrawer extends StatelessWidget {
  final VoidCallback onGeneratePdf;
  final VoidCallback onLogout;

  const HomeDrawer({
    super.key,
    required this.onGeneratePdf,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            accountName: Text(
              user?.displayName ?? "",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            accountEmail: Text(
              user?.email ?? "",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage(R.ASSETS_LOGO_JPG),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(
              "Generate PDF",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () {
              Navigator.pop(context);
              onGeneratePdf();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              "Logout",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: onLogout,
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: Text(
              "Invoice",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RoutesName.invoiceScreen);
            },
          ),
        ],
      ),
    );
  }
}
