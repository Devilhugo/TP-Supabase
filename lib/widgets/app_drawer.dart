import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/carte_page.dart';
import '../pages/client_page.dart';
import '../pages/datagrid_page.dart';
import '../pages/login_page.dart';
import '../pages/picture_page.dart';
import '../pages/profil_page.dart';
import '../pages/qrcode_page.dart';
import '../services/authentification_service.dart';

/// Drawer menu commun.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, String route) {
    Navigator.pop(context); // ferme le drawer
    Navigator.pushReplacementNamed(context, route);
  }

  void _ouvrirProfil(BuildContext context) {
    Navigator.pop(context); // ferme le drawer
    // push (et non pushReplacement) : la flèche retour ramène à la page courante
    Navigator.pushNamed(context, ProfilPage.route);
  }

  Future<void> _deconnexion(BuildContext context) async {
    final navigator = Navigator.of(context);
    await AuthentificationService().logout();
    // retour sur la route login en vidant la pile de navigation
    navigator.pushNamedAndRemoveUntil(LoginPage.route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthentificationService();
    final user = Supabase.instance.client.auth.currentUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40),
            ),
            accountName: Text(authService.getPseudo() ?? 'Sans pseudo'),
            accountEmail: Text(user?.email ?? ''),
            onDetailsPressed: () => _ouvrirProfil(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mon profil'),
            onTap: () => _ouvrirProfil(context),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Carte'),
            onTap: () => _go(context, CartePage.route),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galerie'),
            onTap: () => _go(context, PicturePage.route),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Photo'),
            onTap: () => _go(context, PicturePage.route),
          ),
          ListTile(
            leading: const Icon(Icons.document_scanner),
            title: const Text('Scanner'),
            onTap: () => _go(context, PicturePage.route),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clients'),
            onTap: () => _go(context, ClientPage.route),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Datagrid clients'),
            onTap: () => _go(context, DatagridPage.route),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('QrCode'),
            onTap: () => _go(context, QrPage.route),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () => _deconnexion(context),
          ),
        ],
      ),
    );
  }
}
