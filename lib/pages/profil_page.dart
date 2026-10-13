import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/authentification_service.dart';

/// Page profil : affichage du compte et modification du pseudo.
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  static const route = '/profil';

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final AuthentificationService _authService = AuthentificationService();
  late final TextEditingController _pseudoController =
      TextEditingController(text: _authService.getPseudo() ?? '');
  bool _loading = false;

  @override
  void dispose() {
    _pseudoController.dispose();
    super.dispose();
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _enregistrer() async {
    final pseudo = _pseudoController.text.trim();
    if (pseudo.length < 3 || pseudo.length > 30) {
      _snack('Le pseudo doit contenir entre 3 et 30 caractères.',
          Colors.orange);
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.updatePseudo(pseudo);
      if (!mounted) return;
      _snack('Profil mis à jour.', Colors.green);
    } on AuthException catch (e) {
      if (!mounted) return;
      _snack('Erreur durant la mise à jour : ${e.message}', Colors.red);
    } catch (e) {
      if (!mounted) return;
      _snack("Une erreur s'est produite !", Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _expiration() {
    final expiresAt =
        Supabase.instance.client.auth.currentSession?.expiresAt;
    if (expiresAt == null) return '-';
    final expire = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return '${expire.hour.toString().padLeft(2, '0')}:'
        '${expire.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text('Mon profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.account_circle, size: 100, color: Colors.blue),
          const SizedBox(height: 30),
          TextFormField(
            controller: _pseudoController,
            maxLength: 30,
            decoration: const InputDecoration(
              labelText: 'Pseudo',
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (_) => _enregistrer(),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: email ?? 'inconnu',
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text("Session valide jusqu'à : ${_expiration()}",
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _enregistrer,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
