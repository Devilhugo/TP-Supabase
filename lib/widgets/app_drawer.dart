import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/carte_page.dart';
import '../pages/client_page.dart';
import '../pages/datagrid_page.dart';
import '../pages/login_page.dart';
import '../pages/picture_page.dart';
import '../pages/qrcode_page.dart';
import '../services/authentification_service.dart';

/// Drawer menu commun.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, String route) {
    Navigator.pop(context); // ferme le drawer
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _showCompte(BuildContext context) async {
    final email = await AuthentificationService().getEmail();
    final session = Supabase.instance.client.auth.currentSession;
    final expire = session?.expiresAt != null
        ? DateTime.fromMillisecondsSinceEpoch(session!.expiresAt! * 1000)
        : null;
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mon compte'),
        content: Text(
          'Email : ${email ?? 'inconnu'}\n'
          'Session valide jusqu\'à : '
          '${expire != null ? '${expire.hour.toString().padLeft(2, '0')}:${expire.minute.toString().padLeft(2, '0')}' : '-'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deconnexion(BuildContext context) async {
    final navigator = Navigator.of(context);
    await AuthentificationService().logout();
    // retour sur la route login en vidant la pile de navigation
    navigator.pushNamedAndRemoveUntil(LoginPage.route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mon Compte'),
            onTap: () => _showCompte(context),
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
